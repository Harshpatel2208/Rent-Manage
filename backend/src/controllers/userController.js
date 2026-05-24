'use strict';

const { v4: uuidv4 } = require('uuid');
const db = require('../config/db');
const { success, error } = require('../utils/responseHelper');

/**
 * Get/update user info or invite a new user to the tenant.
 * Only admins can manage users.
 */

/**
 * List all users in the tenant.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getUsers(req, res, next) {
  const { tenantId } = req;
  try {
    const { rows } = await db.query(
      `SELECT id, tenant_id, email, phone, role, is_active, created_at
       FROM users
       WHERE tenant_id = $1
       ORDER BY created_at ASC`,
      [tenantId]
    );
    return success(res, rows);
  } catch (err) {
    return next(err);
  }
}

/**
 * Invite a new user to the tenant (admin only).
 * Creates a user with a temporary password or without one if Google/OTP login is used.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function inviteUser(req, res, next) {
  const { tenantId } = req;
  const { email, phone, role = 'viewer' } = req.body;

  if (!email && !phone) {
    return error(res, 'Email or phone is required to invite a user', 400);
  }

  try {
    // Check for duplicate email/phone in tenant
    if (email) {
      const { rows } = await db.query('SELECT id FROM users WHERE email = $1', [email]);
      if (rows.length > 0) {
        return error(res, 'User with this email already exists', 409);
      }
    }

    if (phone) {
      const { rows } = await db.query('SELECT id FROM users WHERE phone = $1', [phone]);
      if (rows.length > 0) {
        return error(res, 'User with this phone already exists', 409);
      }
    }

    const userId = uuidv4();
    const { rows } = await db.query(
      `INSERT INTO users (id, tenant_id, email, phone, role)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, tenant_id, email, phone, role, is_active, created_at`,
      [userId, tenantId, email || null, phone || null, role]
    );

    return success(res, rows[0], 201);
  } catch (err) {
    return next(err);
  }
}

/**
 * Update a user's role within the tenant (admin only).
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function updateUserRole(req, res, next) {
  const { tenantId, userId: requestingUserId } = req;
  const { id } = req.params;
  const { role, is_active } = req.body;

  // Prevent admins from demoting themselves
  if (id === requestingUserId && role === 'viewer') {
    return error(res, 'You cannot change your own role', 400);
  }

  try {
    const updates = [];
    const params = [tenantId, id];

    if (role !== undefined) {
      params.push(role);
      updates.push(`role = $${params.length}`);
    }

    if (is_active !== undefined) {
      params.push(is_active);
      updates.push(`is_active = $${params.length}`);
    }

    if (updates.length === 0) {
      return error(res, 'No fields to update', 400);
    }

    const { rows } = await db.query(
      `UPDATE users SET ${updates.join(', ')}
       WHERE tenant_id = $1 AND id = $2
       RETURNING id, tenant_id, email, phone, role, is_active, created_at`,
      params
    );

    if (rows.length === 0) {
      return error(res, 'User not found', 404);
    }

    return success(res, rows[0]);
  } catch (err) {
    return next(err);
  }
}

module.exports = { getUsers, inviteUser, updateUserRole };
