'use strict';

const { v4: uuidv4 } = require('uuid');
const db = require('../config/db');
const { success, error } = require('../utils/responseHelper');
const { multiplyDecimal, toDecimalString } = require('../utils/decimal');
const { getFirstOfNextMonth, formatMonthKey, generateCycleMonths, getCurrentCycleMonth } = require('../utils/dateUtils');

const SCHEDULE_MONTHS = 12;

/**
 * Get all loans for the tenant with borrower name, outstanding principal, and next payment date.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getLoans(req, res, next) {
  const { tenantId } = req;
  const { status, limit = 50, offset = 0 } = req.query;

  try {
    let whereClause = 'l.tenant_id = $1';
    const params = [tenantId];

    if (status && ['active', 'closed'].includes(status)) {
      params.push(status);
      whereClause += ` AND l.status = $${params.length}`;
    }

    const { rows } = await db.query(
      `SELECT
         l.id,
         l.tenant_id,
         l.borrower_id,
         b.full_name AS borrower_name,
         b.phone AS borrower_phone,
         l.principal,
         l.interest_rate,
         l.status,
         l.registered_at,
         l.first_cycle_date,
         l.closed_at,
         l.created_at,
         COALESCE(
           (SELECT SUM(lp.amount) FROM loan_payments lp
            WHERE lp.loan_id = l.id AND lp.type = 'principal'),
           0
         ) AS total_principal_paid,
         (l.principal - COALESCE(
           (SELECT SUM(lp.amount) FROM loan_payments lp
            WHERE lp.loan_id = l.id AND lp.type = 'principal'),
           0
         )) AS outstanding_principal,
         (SELECT lis.cycle_month FROM loan_interest_schedule lis
          WHERE lis.loan_id = l.id AND lis.status = 'pending'
          ORDER BY lis.cycle_month ASC LIMIT 1) AS next_payment_date
       FROM loans l
       JOIN borrowers b ON b.id = l.borrower_id
       WHERE ${whereClause}
       ORDER BY l.created_at DESC
       LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
      [...params, limit, offset]
    );

    const { rows: countRows } = await db.query(
      `SELECT COUNT(*) FROM loans l WHERE ${whereClause}`,
      params
    );

    return success(
      res,
      rows,
      200,
      { total: parseInt(countRows[0].count, 10), limit: Number(limit), offset: Number(offset) }
    );
  } catch (err) {
    return next(err);
  }
}

/**
 * Create a new loan for a borrower.
 * Computes first_cycle_date as the 1st of next month from registered_at.
 * Auto-generates 12 months of interest schedule rows.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function createLoan(req, res, next) {
  const { tenantId } = req;
  const { borrower_id, principal, interest_rate = '0.0100', registered_at, notes } = req.body;

  try {
    const result = await db.withTransaction(async (client) => {
      // Verify borrower belongs to this tenant
      const { rows: borrowerRows } = await client.query(
        'SELECT id FROM borrowers WHERE id = $1 AND tenant_id = $2',
        [borrower_id, tenantId]
      );
      if (borrowerRows.length === 0) {
        const err = new Error('Borrower not found');
        err.statusCode = 404;
        throw err;
      }

      const registeredDate = registered_at ? new Date(registered_at) : new Date();
      const firstCycleDate = getFirstOfNextMonth(registeredDate);
      const firstCycleDateStr = formatMonthKey(firstCycleDate);

      const loanId = uuidv4();

      // Insert the loan
      const { rows: loanRows } = await client.query(
        `INSERT INTO loans (id, tenant_id, borrower_id, principal, interest_rate, status, registered_at, first_cycle_date)
         VALUES ($1, $2, $3, $4, $5, 'active', $6, $7)
         RETURNING *`,
        [loanId, tenantId, borrower_id, principal, interest_rate, registeredDate, firstCycleDateStr]
      );

      // Auto-generate 12 months of interest schedule
      const cycleMonths = generateCycleMonths(firstCycleDate, SCHEDULE_MONTHS);
      const expectedAmount = multiplyDecimal(principal, interest_rate);

      const scheduleInserts = cycleMonths.map((month) => ({
        id: uuidv4(),
        loan_id: loanId,
        tenant_id: tenantId,
        cycle_month: formatMonthKey(month),
        expected_amount: expectedAmount,
      }));

      for (const row of scheduleInserts) {
        await client.query(
          `INSERT INTO loan_interest_schedule (id, loan_id, tenant_id, cycle_month, expected_amount)
           VALUES ($1, $2, $3, $4, $5)
           ON CONFLICT (loan_id, cycle_month) DO NOTHING`,
          [row.id, row.loan_id, row.tenant_id, row.cycle_month, row.expected_amount]
        );
      }

      const { rows: scheduleRows } = await client.query(
        'SELECT * FROM loan_interest_schedule WHERE loan_id = $1 ORDER BY cycle_month ASC',
        [loanId]
      );

      return { loan: loanRows[0], schedule: scheduleRows };
    });

    return success(res, result, 201);
  } catch (err) {
    return next(err);
  }
}

/**
 * Get full loan detail including schedule and payment history.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getLoanById(req, res, next) {
  const { tenantId } = req;
  const { id } = req.params;

  try {
    const { rows: loanRows } = await db.query(
      `SELECT l.*, b.full_name AS borrower_name, b.phone AS borrower_phone, b.address AS borrower_address
       FROM loans l
       JOIN borrowers b ON b.id = l.borrower_id
       WHERE l.id = $1 AND l.tenant_id = $2`,
      [id, tenantId]
    );

    if (loanRows.length === 0) {
      return error(res, 'Loan not found', 404);
    }

    const loan = loanRows[0];

    // Get payment history
    const { rows: payments } = await db.query(
      `SELECT * FROM loan_payments WHERE loan_id = $1 AND tenant_id = $2 ORDER BY payment_date DESC`,
      [id, tenantId]
    );

    // Get interest schedule
    const { rows: schedule } = await db.query(
      `SELECT * FROM loan_interest_schedule WHERE loan_id = $1 AND tenant_id = $2 ORDER BY cycle_month ASC`,
      [id, tenantId]
    );

    return success(res, { loan, payments, schedule });
  } catch (err) {
    return next(err);
  }
}

/**
 * Record a loan payment (interest or principal).
 * - If type='principal': close the loan and waive all pending schedule rows.
 * - If type='interest': mark the corresponding schedule row as collected.
 * Idempotency key checked via middleware.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function recordPayment(req, res, next) {
  const { tenantId } = req;
  const { id: loanId } = req.params;
  const { amount, payment_date, type, idempotency_key, notes, cycle_month } = req.body;

  try {
    const result = await db.withTransaction(async (client) => {
      // Verify loan belongs to tenant
      const { rows: loanRows } = await client.query(
        'SELECT id, status, principal, interest_rate FROM loans WHERE id = $1 AND tenant_id = $2',
        [loanId, tenantId]
      );

      if (loanRows.length === 0) {
        const err = new Error('Loan not found');
        err.statusCode = 404;
        throw err;
      }

      const loan = loanRows[0];

      if (loan.status === 'closed') {
        const err = new Error('Cannot record payment on a closed loan');
        err.statusCode = 400;
        throw err;
      }

      // Idempotency check
      const { rows: existing } = await client.query(
        'SELECT id FROM loan_payments WHERE idempotency_key = $1',
        [idempotency_key]
      );
      if (existing.length > 0) {
        return { idempotent: true, id: existing[0].id };
      }

      // Insert the payment
      const paymentId = uuidv4();
      const { rows: paymentRows } = await client.query(
        `INSERT INTO loan_payments (id, loan_id, tenant_id, amount, payment_date, type, idempotency_key, notes)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         RETURNING *`,
        [paymentId, loanId, tenantId, amount, payment_date, type, idempotency_key, notes || null]
      );

      if (type === 'principal') {
        // Close the loan
        await client.query(
          `UPDATE loans SET status = 'closed', closed_at = NOW() WHERE id = $1`,
          [loanId]
        );

        // Waive all pending schedule rows
        await client.query(
          `UPDATE loan_interest_schedule SET status = 'waived'
           WHERE loan_id = $1 AND status = 'pending'`,
          [loanId]
        );
      } else if (type === 'interest') {
        let targetMonth = cycle_month;
        if (!targetMonth) {
          const { rows: oldestPending } = await client.query(
            `SELECT cycle_month FROM loan_interest_schedule
             WHERE loan_id = $1 AND status = 'pending'
             ORDER BY cycle_month ASC LIMIT 1`,
            [loanId]
          );
          if (oldestPending.length > 0) {
            targetMonth = oldestPending[0].cycle_month;
          }
        }
        if (targetMonth) {
          await client.query(
            `UPDATE loan_interest_schedule SET status = 'collected'
             WHERE loan_id = $1 AND tenant_id = $2 AND cycle_month = $3 AND status = 'pending'`,
            [loanId, tenantId, targetMonth]
          );
        }
      }

      return { payment: paymentRows[0] };
    });

    return success(res, result, 201);
  } catch (err) {
    return next(err);
  }
}

/**
 * Get the full interest schedule for a loan.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getSchedule(req, res, next) {
  const { tenantId } = req;
  const { id } = req.params;

  try {
    // Verify loan belongs to tenant
    const { rows: loanRows } = await db.query(
      'SELECT id FROM loans WHERE id = $1 AND tenant_id = $2',
      [id, tenantId]
    );

    if (loanRows.length === 0) {
      return error(res, 'Loan not found', 404);
    }

    const { rows: schedule } = await db.query(
      `SELECT * FROM loan_interest_schedule
       WHERE loan_id = $1 AND tenant_id = $2
       ORDER BY cycle_month ASC`,
      [id, tenantId]
    );

    const summary = {
      total: schedule.length,
      pending: schedule.filter((s) => s.status === 'pending').length,
      collected: schedule.filter((s) => s.status === 'collected').length,
      waived: schedule.filter((s) => s.status === 'waived').length,
    };

    return success(res, { schedule, summary });
  } catch (err) {
    return next(err);
  }
}

/**
 * Get all borrowers for the tenant.
 */
async function getBorrowers(req, res, next) {
  const { tenantId } = req;
  try {
    const { rows } = await db.query(
      'SELECT * FROM borrowers WHERE tenant_id = $1 ORDER BY full_name ASC',
      [tenantId]
    );
    return success(res, rows);
  } catch (err) {
    return next(err);
  }
}

/**
 * Create a new borrower.
 */
async function createBorrower(req, res, next) {
  const { tenantId } = req;
  const { full_name, phone, address, notes } = req.body;
  try {
    const id = uuidv4();
    const { rows } = await db.query(
      `INSERT INTO borrowers (id, tenant_id, full_name, phone, address, notes)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [id, tenantId, full_name, phone, address, notes || null]
    );
    return success(res, rows[0], 201);
  } catch (err) {
    return next(err);
  }
}

module.exports = { getLoans, createLoan, getLoanById, recordPayment, getSchedule, getBorrowers, createBorrower };
