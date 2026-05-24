'use strict';

const db = require('../config/db');

/**
 * Map of table names to their idempotency_key column existence check query.
 * These are the tables that support idempotency.
 */
const IDEMPOTENCY_TABLES = {
  loan_payments: 'loan_payments',
  rent_payments: 'rent_payments',
  expenses: 'expenses',
};

/**
 * Idempotency middleware factory.
 * Checks if the given idempotency_key already exists in the specified table.
 * If it does, return a 200 response indicating the operation was already completed.
 * The key should be provided in the X-Idempotency-Key header or in the request body.
 *
 * @param {string} tableName - The database table to check for duplicate idempotency keys
 * @returns {import('express').RequestHandler}
 */
function idempotencyCheck(tableName) {
  if (!IDEMPOTENCY_TABLES[tableName]) {
    throw new Error(`[Idempotency] Unknown table: ${tableName}`);
  }

  return async function (req, res, next) {
    const idempotencyKey =
      req.headers['x-idempotency-key'] || req.body.idempotency_key;

    if (!idempotencyKey) {
      return next();
    }

    try {
      const { rows } = await db.query(
        `SELECT id FROM ${tableName} WHERE idempotency_key = $1 AND tenant_id = $2 LIMIT 1`,
        [idempotencyKey, req.tenantId]
      );

      if (rows.length > 0) {
        return res.status(200).json({
          success: true,
          data: { idempotent: true, message: 'Request already processed', id: rows[0].id },
        });
      }

      // Store the key on the request so controllers can use it
      req.idempotencyKey = idempotencyKey;
      return next();
    } catch (err) {
      return next(err);
    }
  };
}

module.exports = { idempotencyCheck };
