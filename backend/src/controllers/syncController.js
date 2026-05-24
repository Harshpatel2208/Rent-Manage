'use strict';

const { v4: uuidv4 } = require('uuid');
const db = require('../config/db');
const { success, error } = require('../utils/responseHelper');

const SUPPORTED_ENTITY_TYPES = ['loan_payment', 'rent_payment', 'expense', 'borrower', 'rental_tenant'];

/**
 * Process a batch of offline sync operations.
 * For each entry: check idempotency, attempt DB write, record conflict on failure.
 * Returns a detailed result for each operation.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function batchSync(req, res, next) {
  const { tenantId, userId } = req;
  const { operations } = req.body;

  if (!Array.isArray(operations) || operations.length === 0) {
    return error(res, 'operations must be a non-empty array', 400);
  }

  const results = [];

  for (const operation of operations) {
    const { entity_type, payload, idempotency_key } = operation;

    if (!SUPPORTED_ENTITY_TYPES.includes(entity_type)) {
      results.push({
        idempotency_key,
        entity_type,
        status: 'failed',
        reason: `Unsupported entity type: ${entity_type}`,
      });
      continue;
    }

    if (!idempotency_key) {
      results.push({
        entity_type,
        status: 'failed',
        reason: 'idempotency_key is required for each operation',
      });
      continue;
    }

    try {
      // Check for existing idempotency key across relevant tables
      let alreadyProcessed = false;

      if (entity_type === 'loan_payment') {
        const { rows } = await db.query(
          'SELECT id FROM loan_payments WHERE idempotency_key = $1 AND tenant_id = $2',
          [idempotency_key, tenantId]
        );
        alreadyProcessed = rows.length > 0;
      } else if (entity_type === 'rent_payment') {
        const { rows } = await db.query(
          'SELECT id FROM rent_payments WHERE idempotency_key = $1 AND tenant_id = $2',
          [idempotency_key, tenantId]
        );
        alreadyProcessed = rows.length > 0;
      } else if (entity_type === 'expense') {
        const { rows } = await db.query(
          'SELECT id FROM expenses WHERE idempotency_key = $1 AND tenant_id = $2',
          [idempotency_key, tenantId]
        );
        alreadyProcessed = rows.length > 0;
      }

      if (alreadyProcessed) {
        results.push({ idempotency_key, entity_type, status: 'already_processed' });
        continue;
      }

      // Attempt to write based on entity type
      let entityId;

      if (entity_type === 'loan_payment') {
        const { loan_id, amount, payment_date, type, notes, cycle_month } = payload;
        const id = uuidv4();
        await db.query(
          `INSERT INTO loan_payments (id, loan_id, tenant_id, amount, payment_date, type, idempotency_key, notes, synced_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())`,
          [id, loan_id, tenantId, amount, payment_date, type, idempotency_key, notes || null]
        );
        entityId = id;
      } else if (entity_type === 'rent_payment') {
        const { rental_tenant_id, cycle_month, amount_paid, amount_due, notes } = payload;
        const id = uuidv4();
        const amountDue = amount_due || (
          await db.query('SELECT rent_amount FROM rental_tenants WHERE id = $1', [rental_tenant_id])
        ).rows[0]?.rent_amount;

        const status = parseFloat(amount_paid) >= parseFloat(amountDue) ? 'paid' : 'partially_paid';

        await db.query(
          `INSERT INTO rent_payments (id, rental_tenant_id, tenant_id, cycle_month, amount_due, amount_paid, status, idempotency_key, notes, synced_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW())
           ON CONFLICT (rental_tenant_id, cycle_month) DO UPDATE
           SET amount_paid = EXCLUDED.amount_paid, status = EXCLUDED.status, synced_at = NOW()`,
          [id, rental_tenant_id, tenantId, cycle_month, amountDue, amount_paid, status, idempotency_key, notes || null]
        );
        entityId = id;
      } else if (entity_type === 'expense') {
        const { amount, category, expense_date, description } = payload;
        const id = uuidv4();
        await db.query(
          `INSERT INTO expenses (id, tenant_id, amount, category, expense_date, description, idempotency_key, synced_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())`,
          [id, tenantId, amount, category, expense_date, description || null, idempotency_key]
        );
        entityId = id;
      }

      results.push({ idempotency_key, entity_type, status: 'success', id: entityId });
    } catch (writeErr) {
      const conflictId = uuidv4();
      // Record conflict for manual resolution
      try {
        await db.query(
          `INSERT INTO sync_conflicts (id, tenant_id, user_id, entity_type, local_payload, conflict_reason)
           VALUES ($1, $2, $3, $4, $5, $6)`,
          [conflictId, tenantId, userId, entity_type, JSON.stringify(payload), writeErr.message]
        );
      } catch (conflictErr) {
        console.error('[SyncController] Failed to record conflict:', conflictErr.message);
      }

      results.push({
        idempotency_key,
        entity_type,
        status: 'conflict',
        reason: writeErr.message,
        conflict_id: conflictId,
      });
    }
  }

  const summary = {
    total: results.length,
    success: results.filter((r) => r.status === 'success').length,
    already_processed: results.filter((r) => r.status === 'already_processed').length,
    conflicts: results.filter((r) => r.status === 'conflict').length,
    failed: results.filter((r) => r.status === 'failed').length,
  };

  return success(res, { results, summary });
}

/**
 * List all pending sync conflicts for the tenant.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getConflicts(req, res, next) {
  const { tenantId } = req;
  const { status = 'pending' } = req.query;

  try {
    const { rows } = await db.query(
      `SELECT sc.*, u.email AS user_email, u.phone AS user_phone
       FROM sync_conflicts sc
       LEFT JOIN users u ON u.id = sc.user_id
       WHERE sc.tenant_id = $1 AND sc.status = $2
       ORDER BY sc.created_at DESC`,
      [tenantId, status]
    );

    return success(res, rows);
  } catch (err) {
    return next(err);
  }
}

/**
 * Update a sync conflict status to resolved or dismissed.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function resolveConflict(req, res, next) {
  const { tenantId } = req;
  const { id } = req.params;
  let { status, action } = req.body;

  if (action) {
    if (action === 'dismiss') status = 'dismissed';
    if (action === 'resolve') status = 'resolved';
  }

  if (!status || !['resolved', 'dismissed'].includes(status)) {
    return error(res, 'Status must be "resolved" or "dismissed"', 400);
  }

  try {
    const { rows } = await db.query(
      `UPDATE sync_conflicts
       SET status = $1, resolved_at = NOW()
       WHERE id = $2 AND tenant_id = $3
       RETURNING *`,
      [status, id, tenantId]
    );

    if (rows.length === 0) {
      return error(res, 'Conflict not found', 404);
    }

    return success(res, rows[0]);
  } catch (err) {
    return next(err);
  }
}

module.exports = { batchSync, getConflicts, resolveConflict };
