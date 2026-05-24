'use strict';

const jwt = require('jsonwebtoken');
const config = require('../config/env');
const { error } = require('../utils/responseHelper');

/**
 * Verify JWT Bearer token and attach decoded user data to req.user.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function requireAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return error(res, 'Authorization header missing or malformed', 401);
    }

    const token = authHeader.slice(7);
    if (!token) {
      return error(res, 'Token not provided', 401);
    }

    const decoded = jwt.verify(token, config.JWT_SECRET);

    if (!decoded.userId || !decoded.tenantId) {
      return error(res, 'Invalid token payload', 401);
    }

    req.user = {
      userId: decoded.userId,
      tenantId: decoded.tenantId,
      role: decoded.role,
    };

    return next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return error(res, 'Token has expired', 401);
    }
    if (err.name === 'JsonWebTokenError') {
      return error(res, 'Invalid token', 401);
    }
    return next(err);
  }
}

/**
 * Ensure the authenticated user has the 'admin' role.
 * Must be used after requireAuth.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
function requireAdmin(req, res, next) {
  if (!req.user) {
    return error(res, 'Authentication required', 401);
  }
  if (req.user.role !== 'admin') {
    return error(res, 'Admin privileges required', 403);
  }
  return next();
}

module.exports = { requireAuth, requireAdmin };
