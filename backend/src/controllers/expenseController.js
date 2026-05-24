'use strict';

const { v4: uuidv4 } = require('uuid');
const db = require('../config/db');
const { success, error, paginated } = require('../utils/responseHelper');

const VALID_CATEGORIES = ['food', 'maintenance', 'travel', 'business', 'other'];

/**
 * List expenses for the tenant with optional filters.
 * Supports filtering by category, date range, and pagination.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getExpenses(req, res, next) {
  const { tenantId } = req;
  const { category, date_from, date_to, limit = 50, offset = 0 } = req.query;

  try {
    const params = [tenantId];
    const conditions = ['e.tenant_id = $1'];

    if (category && VALID_CATEGORIES.includes(category)) {
      params.push(category);
      conditions.push(`e.category = $${params.length}`);
    }

    if (date_from) {
      params.push(date_from);
      conditions.push(`e.expense_date >= $${params.length}`);
    }

    if (date_to) {
      params.push(date_to);
      conditions.push(`e.expense_date <= $${params.length}`);
    }

    const whereClause = conditions.join(' AND ');

    const { rows } = await db.query(
      `SELECT * FROM expenses e
       WHERE ${whereClause}
       ORDER BY e.expense_date DESC, e.created_at DESC
       LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
      [...params, limit, offset]
    );

    const { rows: countRows } = await db.query(
      `SELECT COUNT(*) FROM expenses e WHERE ${whereClause}`,
      params
    );

    return paginated(res, rows, parseInt(countRows[0].count, 10), Math.floor(offset / limit) + 1, Number(limit));
  } catch (err) {
    return next(err);
  }
}

/**
 * Create a new expense record.
 * Idempotency is checked via the idempotency_key field.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function createExpense(req, res, next) {
  const { tenantId } = req;
  const { amount, category, expense_date, description, idempotency_key } = req.body;

  try {
    // Manual idempotency check (in addition to middleware)
    const { rows: existing } = await db.query(
      'SELECT id FROM expenses WHERE idempotency_key = $1 AND tenant_id = $2',
      [idempotency_key, tenantId]
    );

    if (existing.length > 0) {
      const { rows: expRow } = await db.query('SELECT * FROM expenses WHERE id = $1', [existing[0].id]);
      return success(res, { idempotent: true, expense: expRow[0] });
    }

    const { rows } = await db.query(
      `INSERT INTO expenses (id, tenant_id, amount, category, expense_date, description, idempotency_key)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [uuidv4(), tenantId, amount, category, expense_date, description || null, idempotency_key]
    );

    return success(res, { expense: rows[0] }, 201);
  } catch (err) {
    return next(err);
  }
}

module.exports = { getExpenses, createExpense };
