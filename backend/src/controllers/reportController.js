'use strict';

const PDFDocument = require('pdfkit');
const { createObjectCsvWriter } = require('csv-writer');
const path = require('path');
const os = require('os');
const fs = require('fs');
const db = require('../config/db');
const { success, error } = require('../utils/responseHelper');
const { formatMonthLabel } = require('../utils/dateUtils');

/**
 * Get aggregated monthly report data for a given year/month.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getMonthlyReport(req, res, next) {
  const { tenantId } = req;
  const { year, month } = req.query;

  if (!year || !month) {
    return error(res, 'year and month query parameters are required', 400);
  }

  const yearInt = parseInt(year, 10);
  const monthInt = parseInt(month, 10);

  if (isNaN(yearInt) || isNaN(monthInt) || monthInt < 1 || monthInt > 12) {
    return error(res, 'Invalid year or month', 400);
  }

  const cycleMonth = `${yearInt}-${String(monthInt).padStart(2, '0')}-01`;
  const monthStart = cycleMonth;
  const monthEnd = new Date(Date.UTC(yearInt, monthInt, 0)).toISOString().split('T')[0];

  try {
    // Loan payments for this period
    const { rows: loanPayments } = await db.query(
      `SELECT lp.*, b.full_name AS borrower_name, l.principal
       FROM loan_payments lp
       JOIN loans l ON l.id = lp.loan_id
       JOIN borrowers b ON b.id = l.borrower_id
       WHERE lp.tenant_id = $1
         AND lp.payment_date >= $2
         AND lp.payment_date <= $3
       ORDER BY lp.payment_date ASC`,
      [tenantId, monthStart, monthEnd]
    );

    // Rent payments for this cycle month
    const { rows: rentPayments } = await db.query(
      `SELECT rp.*, rt.full_name AS tenant_name, su.unit_name
       FROM rent_payments rp
       JOIN rental_tenants rt ON rt.id = rp.rental_tenant_id
       LEFT JOIN shop_units su ON su.id = rt.unit_id
       WHERE rp.tenant_id = $1 AND rp.cycle_month = $2
       ORDER BY rt.full_name ASC`,
      [tenantId, cycleMonth]
    );

    // Expenses for this period
    const { rows: expenses } = await db.query(
      `SELECT * FROM expenses
       WHERE tenant_id = $1
         AND expense_date >= $2
         AND expense_date <= $3
       ORDER BY expense_date ASC`,
      [tenantId, monthStart, monthEnd]
    );

    // Aggregates
    const { rows: agg } = await db.query(
      `SELECT
         COALESCE(SUM(CASE WHEN lp.type = 'interest' THEN lp.amount ELSE 0 END), '0.0000') AS total_interest_collected,
         COALESCE(SUM(CASE WHEN lp.type = 'principal' THEN lp.amount ELSE 0 END), '0.0000') AS total_principal_collected,
         COALESCE(SUM(lp.amount), '0.0000') AS total_loan_income
       FROM loan_payments lp
       WHERE lp.tenant_id = $1
         AND lp.payment_date >= $2
         AND lp.payment_date <= $3`,
      [tenantId, monthStart, monthEnd]
    );

    const { rows: rentAgg } = await db.query(
      `SELECT COALESCE(SUM(amount_paid), '0.0000') AS total_rent_collected
       FROM rent_payments
       WHERE tenant_id = $1 AND cycle_month = $2`,
      [tenantId, cycleMonth]
    );

    const { rows: expAgg } = await db.query(
      `SELECT COALESCE(SUM(amount), '0.0000') AS total_expenses
       FROM expenses
       WHERE tenant_id = $1
         AND expense_date >= $2
         AND expense_date <= $3`,
      [tenantId, monthStart, monthEnd]
    );

    return success(res, {
      period: { year: yearInt, month: monthInt, cycle_month: cycleMonth },
      summary: {
        total_interest_collected: agg[0].total_interest_collected,
        total_principal_collected: agg[0].total_principal_collected,
        total_loan_income: agg[0].total_loan_income,
        total_rent_collected: rentAgg[0].total_rent_collected,
        total_expenses: expAgg[0].total_expenses,
        net_income: (
          parseFloat(agg[0].total_loan_income) +
          parseFloat(rentAgg[0].total_rent_collected) -
          parseFloat(expAgg[0].total_expenses)
        ).toFixed(4),
      },
      loan_payments: loanPayments,
      rent_payments: rentPayments,
      expenses,
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Export a monthly report as a PDF file streamed to the client.
 * Uses PDFKit to build tables for loan, rent, and expense summaries.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function exportPdf(req, res, next) {
  const { tenantId } = req;
  const { year, month } = req.query;

  if (!year || !month) {
    return error(res, 'year and month are required', 400);
  }

  const yearInt = parseInt(year, 10);
  const monthInt = parseInt(month, 10);
  const cycleMonth = `${yearInt}-${String(monthInt).padStart(2, '0')}-01`;
  const monthStart = cycleMonth;
  const monthEnd = new Date(Date.UTC(yearInt, monthInt, 0)).toISOString().split('T')[0];

  try {
    const [loanRes, rentRes, expRes] = await Promise.all([
      db.query(
        `SELECT lp.amount, lp.type, lp.payment_date, b.full_name AS borrower_name
         FROM loan_payments lp
         JOIN loans l ON l.id = lp.loan_id
         JOIN borrowers b ON b.id = l.borrower_id
         WHERE lp.tenant_id = $1 AND lp.payment_date >= $2 AND lp.payment_date <= $3
         ORDER BY lp.payment_date ASC`,
        [tenantId, monthStart, monthEnd]
      ),
      db.query(
        `SELECT rp.amount_paid, rp.status, rt.full_name AS tenant_name
         FROM rent_payments rp
         JOIN rental_tenants rt ON rt.id = rp.rental_tenant_id
         WHERE rp.tenant_id = $1 AND rp.cycle_month = $2
         ORDER BY rt.full_name ASC`,
        [tenantId, cycleMonth]
      ),
      db.query(
        `SELECT amount, category, expense_date, description
         FROM expenses
         WHERE tenant_id = $1 AND expense_date >= $2 AND expense_date <= $3
         ORDER BY expense_date ASC`,
        [tenantId, monthStart, monthEnd]
      ),
    ]);

    const doc = new PDFDocument({ margin: 50, size: 'A4' });
    const monthLabel = formatMonthLabel(new Date(cycleMonth));

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="report-${year}-${month}.pdf"`);
    doc.pipe(res);

    // ─── Title ──────────────────────────────────────────────────────────────
    doc.fontSize(20).font('Helvetica-Bold').text(`Monthly Report — ${monthLabel}`, { align: 'center' });
    doc.moveDown(0.5);
    doc.fontSize(10).font('Helvetica').text(`Generated on ${new Date().toLocaleDateString()}`, { align: 'center' });
    doc.moveDown(1.5);

    // ─── Loan Payments Section ───────────────────────────────────────────────
    doc.fontSize(14).font('Helvetica-Bold').text('Loan Payments');
    doc.moveDown(0.4);

    if (loanRes.rows.length === 0) {
      doc.fontSize(10).font('Helvetica').text('No loan payments recorded for this period.');
    } else {
      const loanHeaders = ['Borrower', 'Type', 'Amount', 'Date'];
      const loanColWidths = [180, 80, 100, 100];
      renderTableHeader(doc, loanHeaders, loanColWidths);
      for (const row of loanRes.rows) {
        renderTableRow(doc, [row.borrower_name, row.type, `₹${row.amount}`, row.payment_date], loanColWidths);
      }
    }

    doc.moveDown(1);

    // ─── Rent Payments Section ───────────────────────────────────────────────
    doc.fontSize(14).font('Helvetica-Bold').text('Rent Payments');
    doc.moveDown(0.4);

    if (rentRes.rows.length === 0) {
      doc.fontSize(10).font('Helvetica').text('No rent payments for this cycle month.');
    } else {
      const rentHeaders = ['Tenant', 'Status', 'Amount Paid'];
      const rentColWidths = [220, 120, 120];
      renderTableHeader(doc, rentHeaders, rentColWidths);
      for (const row of rentRes.rows) {
        renderTableRow(doc, [row.tenant_name, row.status, `₹${row.amount_paid}`], rentColWidths);
      }
    }

    doc.moveDown(1);

    // ─── Expenses Section ────────────────────────────────────────────────────
    doc.fontSize(14).font('Helvetica-Bold').text('Expenses');
    doc.moveDown(0.4);

    if (expRes.rows.length === 0) {
      doc.fontSize(10).font('Helvetica').text('No expenses recorded for this period.');
    } else {
      const expHeaders = ['Date', 'Category', 'Amount', 'Description'];
      const expColWidths = [80, 100, 100, 180];
      renderTableHeader(doc, expHeaders, expColWidths);
      for (const row of expRes.rows) {
        renderTableRow(doc, [row.expense_date, row.category, `₹${row.amount}`, row.description || ''], expColWidths);
      }
    }

    doc.end();
  } catch (err) {
    return next(err);
  }
}

/**
 * Render a table header row in the PDF.
 * @param {PDFDocument} doc
 * @param {string[]} headers
 * @param {number[]} colWidths
 */
function renderTableHeader(doc, headers, colWidths) {
  doc.fontSize(10).font('Helvetica-Bold');
  const startX = doc.page.margins.left;
  let x = startX;
  const y = doc.y;

  doc.rect(startX, y, colWidths.reduce((a, b) => a + b, 0), 18).fill('#EEEEEE').stroke();
  doc.fillColor('black');

  headers.forEach((h, i) => {
    doc.text(h, x + 4, y + 4, { width: colWidths[i] - 8 });
    x += colWidths[i];
  });

  doc.moveDown(0.6);
}

/**
 * Render a table data row in the PDF.
 * @param {PDFDocument} doc
 * @param {string[]} cells
 * @param {number[]} colWidths
 */
function renderTableRow(doc, cells, colWidths) {
  doc.fontSize(9).font('Helvetica');
  const startX = doc.page.margins.left;
  let x = startX;
  const y = doc.y;

  cells.forEach((cell, i) => {
    doc.text(String(cell), x + 4, y, { width: colWidths[i] - 8 });
    x += colWidths[i];
  });

  doc.moveDown(0.5);
}

/**
 * Export a monthly report as a CSV file streamed to the client.
 * Writes combined loan payments, rent payments, and expenses rows.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function exportCsv(req, res, next) {
  const { tenantId } = req;
  const { year, month, type = 'all' } = req.query;

  if (!year || !month) {
    return error(res, 'year and month are required', 400);
  }

  const yearInt = parseInt(year, 10);
  const monthInt = parseInt(month, 10);
  const cycleMonth = `${yearInt}-${String(monthInt).padStart(2, '0')}-01`;
  const monthStart = cycleMonth;
  const monthEnd = new Date(Date.UTC(yearInt, monthInt, 0)).toISOString().split('T')[0];

  try {
    const rows = [];

    if (type === 'all' || type === 'loans') {
      const { rows: loanRows } = await db.query(
        `SELECT 'loan_payment' AS record_type, lp.payment_date AS date, lp.type AS subtype,
                b.full_name AS party_name, lp.amount, lp.notes
         FROM loan_payments lp
         JOIN loans l ON l.id = lp.loan_id
         JOIN borrowers b ON b.id = l.borrower_id
         WHERE lp.tenant_id = $1 AND lp.payment_date >= $2 AND lp.payment_date <= $3`,
        [tenantId, monthStart, monthEnd]
      );
      rows.push(...loanRows);
    }

    if (type === 'all' || type === 'rent') {
      const { rows: rentRows } = await db.query(
        `SELECT 'rent_payment' AS record_type, rp.cycle_month AS date, rp.status AS subtype,
                rt.full_name AS party_name, rp.amount_paid AS amount, rp.notes
         FROM rent_payments rp
         JOIN rental_tenants rt ON rt.id = rp.rental_tenant_id
         WHERE rp.tenant_id = $1 AND rp.cycle_month = $2`,
        [tenantId, cycleMonth]
      );
      rows.push(...rentRows);
    }

    if (type === 'all' || type === 'expenses') {
      const { rows: expRows } = await db.query(
        `SELECT 'expense' AS record_type, expense_date AS date, category AS subtype,
                description AS party_name, amount, description AS notes
         FROM expenses
         WHERE tenant_id = $1 AND expense_date >= $2 AND expense_date <= $3`,
        [tenantId, monthStart, monthEnd]
      );
      rows.push(...expRows);
    }

    // Write to temp file then stream
    const tmpFile = path.join(os.tmpdir(), `report-${tenantId}-${year}-${month}.csv`);
    const csvWriter = createObjectCsvWriter({
      path: tmpFile,
      header: [
        { id: 'record_type', title: 'Type' },
        { id: 'date', title: 'Date' },
        { id: 'subtype', title: 'Sub Type' },
        { id: 'party_name', title: 'Party' },
        { id: 'amount', title: 'Amount' },
        { id: 'notes', title: 'Notes' },
      ],
    });

    await csvWriter.writeRecords(rows);

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename="report-${year}-${month}.csv"`);

    const stream = fs.createReadStream(tmpFile);
    stream.pipe(res);
    stream.on('end', () => {
      fs.unlink(tmpFile, () => {});
    });
  } catch (err) {
    return next(err);
  }
}

module.exports = { getMonthlyReport, exportPdf, exportCsv };
