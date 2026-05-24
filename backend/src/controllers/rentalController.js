'use strict';

const { v4: uuidv4 } = require('uuid');
const db = require('../config/db');
const { success, error } = require('../utils/responseHelper');
const { addDecimals, toDecimalString, compareDecimals } = require('../utils/decimal');
const { formatMonthKey, getCurrentCycleMonth } = require('../utils/dateUtils');

/**
 * List all shop units for the tenant.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getUnits(req, res, next) {
  const { tenantId } = req;
  try {
    const { rows } = await db.query(
      `SELECT su.*,
              COUNT(rt.id) AS active_tenant_count
       FROM shop_units su
       LEFT JOIN rental_tenants rt ON rt.unit_id = su.id AND rt.is_active = true
       WHERE su.tenant_id = $1
       GROUP BY su.id
       ORDER BY su.unit_name ASC`,
      [tenantId]
    );
    return success(res, rows);
  } catch (err) {
    return next(err);
  }
}

/**
 * Create a new shop unit for the tenant.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function createUnit(req, res, next) {
  const { tenantId } = req;
  const { unit_name, address, description } = req.body;
  try {
    const { rows } = await db.query(
      `INSERT INTO shop_units (id, tenant_id, unit_name, address, description)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [uuidv4(), tenantId, unit_name, address || null, description || null]
    );
    return success(res, rows[0], 201);
  } catch (err) {
    return next(err);
  }
}

/**
 * List all rental tenants for the tenant with their current month payment status.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getTenants(req, res, next) {
  const { tenantId } = req;
  const { is_active, unit_id } = req.query;
  const currentMonth = formatMonthKey(getCurrentCycleMonth());

  try {
    const params = [tenantId, currentMonth];
    let whereClause = 'rt.tenant_id = $1';

    if (is_active !== undefined) {
      params.push(is_active === 'true');
      whereClause += ` AND rt.is_active = $${params.length}`;
    }

    if (unit_id) {
      params.push(unit_id);
      whereClause += ` AND rt.unit_id = $${params.length}`;
    }

    const { rows } = await db.query(
      `SELECT
         rt.*,
         su.unit_name,
         rp.status AS current_month_status,
         rp.amount_paid AS current_month_paid,
         rp.amount_due AS current_month_due,
         rp.remaining_balance AS current_month_balance,
         COALESCE(
           (SELECT SUM(rp2.remaining_balance)
            FROM rent_payments rp2
            WHERE rp2.rental_tenant_id = rt.id AND rp2.status != 'paid'),
           '0.0000'
         ) AS total_outstanding
       FROM rental_tenants rt
       LEFT JOIN shop_units su ON su.id = rt.unit_id
       LEFT JOIN rent_payments rp ON rp.rental_tenant_id = rt.id AND rp.cycle_month = $2
       WHERE ${whereClause}
       ORDER BY rt.full_name ASC`,
      params
    );

    return success(res, rows);
  } catch (err) {
    return next(err);
  }
}

/**
 * Create a new rental tenant and auto-create the current month's rent_payment row.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function createTenant(req, res, next) {
  const { tenantId } = req;
  const { unit_id, full_name, phone, rent_amount, lease_start, lease_end, notes } = req.body;

  try {
    const result = await db.withTransaction(async (client) => {
      const rentalTenantId = uuidv4();

      // Verify unit belongs to tenant if provided
      if (unit_id) {
        const { rows: unitRows } = await client.query(
          'SELECT id FROM shop_units WHERE id = $1 AND tenant_id = $2',
          [unit_id, tenantId]
        );
        if (unitRows.length === 0) {
          const err = new Error('Shop unit not found');
          err.statusCode = 404;
          throw err;
        }
      }

      const { rows } = await client.query(
        `INSERT INTO rental_tenants (id, tenant_id, unit_id, full_name, phone, rent_amount, lease_start, lease_end, notes)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
         RETURNING *`,
        [
          rentalTenantId,
          tenantId,
          unit_id || null,
          full_name,
          phone || null,
          rent_amount,
          lease_start,
          lease_end || null,
          notes || null,
        ]
      );

      // Auto-create current month's rent payment
      const currentMonth = formatMonthKey(getCurrentCycleMonth());
      const rentPaymentId = uuidv4();
      const idempotencyKey = uuidv4();

      await client.query(
        `INSERT INTO rent_payments (id, rental_tenant_id, tenant_id, cycle_month, amount_due, amount_paid, status, idempotency_key)
         VALUES ($1, $2, $3, $4, $5, 0, 'pending', $6)
         ON CONFLICT (rental_tenant_id, cycle_month) DO NOTHING`,
        [rentPaymentId, rentalTenantId, tenantId, currentMonth, rent_amount, idempotencyKey]
      );

      return rows[0];
    });

    return success(res, result, 201);
  } catch (err) {
    return next(err);
  }
}

/**
 * Get full payment ledger for a rental tenant.
 * Includes all payment history and total outstanding balance.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getTenantLedger(req, res, next) {
  const { tenantId } = req;
  const { id: rentalTenantId } = req.params;

  try {
    // Verify rental tenant belongs to this tenant
    const { rows: tenantRows } = await db.query(
      `SELECT rt.*, su.unit_name FROM rental_tenants rt
       LEFT JOIN shop_units su ON su.id = rt.unit_id
       WHERE rt.id = $1 AND rt.tenant_id = $2`,
      [rentalTenantId, tenantId]
    );

    if (tenantRows.length === 0) {
      return error(res, 'Rental tenant not found', 404);
    }

    const rentalTenant = tenantRows[0];

    // Get all payment rows
    const { rows: payments } = await db.query(
      `SELECT * FROM rent_payments
       WHERE rental_tenant_id = $1 AND tenant_id = $2
       ORDER BY cycle_month DESC`,
      [rentalTenantId, tenantId]
    );

    // Get total outstanding
    const { rows: outstandingRows } = await db.query(
      `SELECT COALESCE(SUM(remaining_balance), '0.0000') AS total_outstanding
       FROM rent_payments
       WHERE rental_tenant_id = $1 AND tenant_id = $2 AND status != 'paid'`,
      [rentalTenantId, tenantId]
    );

    return success(res, {
      tenant: rentalTenant,
      payments,
      total_outstanding: toDecimalString(outstandingRows[0].total_outstanding),
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Record a rent payment for a rental tenant for a specific cycle month.
 * Handles partial and full payments. Updates status accordingly.
 * Creates the rent_payment row if it doesn't exist for the cycle_month.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function recordRentPayment(req, res, next) {
  const { tenantId } = req;
  const { rental_tenant_id, cycle_month, amount_paid, idempotency_key, notes } = req.body;

  try {
    const result = await db.withTransaction(async (client) => {
      // Idempotency check
      const { rows: idem } = await client.query(
        'SELECT id FROM rent_payments WHERE idempotency_key = $1 AND tenant_id = $2',
        [idempotency_key, tenantId]
      );
      if (idem.length > 0) {
        const { rows: existing } = await client.query(
          'SELECT * FROM rent_payments WHERE id = $1',
          [idem[0].id]
        );
        return { idempotent: true, payment: existing[0] };
      }

      // Verify rental tenant belongs to this tenant
      const { rows: rtRows } = await client.query(
        'SELECT id, rent_amount FROM rental_tenants WHERE id = $1 AND tenant_id = $2',
        [rental_tenant_id, tenantId]
      );
      if (rtRows.length === 0) {
        const err = new Error('Rental tenant not found');
        err.statusCode = 404;
        throw err;
      }

      const rentAmount = toDecimalString(rtRows[0].rent_amount);

      // Check if payment row already exists for this cycle_month
      const { rows: existingPayment } = await client.query(
        'SELECT * FROM rent_payments WHERE rental_tenant_id = $1 AND cycle_month = $2',
        [rental_tenant_id, cycle_month]
      );

      let paymentRow;

      if (existingPayment.length > 0) {
        // Update existing payment
        const current = existingPayment[0];
        const newAmountPaid = addDecimals(current.amount_paid, amount_paid);
        const amountDue = toDecimalString(current.amount_due);

        let newStatus = 'partially_paid';
        if (compareDecimals(newAmountPaid, amountDue) >= 0) {
          newStatus = 'paid';
        }

        const { rows: updated } = await client.query(
          `UPDATE rent_payments
           SET amount_paid = $1, status = $2, notes = COALESCE($3, notes), idempotency_key = $4, updated_at = NOW()
           WHERE id = $5
           RETURNING *`,
          [newAmountPaid, newStatus, notes || null, idempotency_key, current.id]
        );
        paymentRow = updated[0];
      } else {
        // Create new payment row for this cycle_month
        const amountDue = rentAmount;
        let newStatus = 'partially_paid';
        if (compareDecimals(amount_paid, amountDue) >= 0) {
          newStatus = 'paid';
        }

        const { rows: inserted } = await client.query(
          `INSERT INTO rent_payments (id, rental_tenant_id, tenant_id, cycle_month, amount_due, amount_paid, status, idempotency_key, notes)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
           RETURNING *`,
          [
            uuidv4(),
            rental_tenant_id,
            tenantId,
            cycle_month,
            amountDue,
            amount_paid,
            newStatus,
            idempotency_key,
            notes || null,
          ]
        );
        paymentRow = inserted[0];
      }

      return { payment: paymentRow };
    });

    return success(res, result, 201);
  } catch (err) {
    return next(err);
  }
}

module.exports = { getUnits, createUnit, getTenants, createTenant, getTenantLedger, recordRentPayment };
