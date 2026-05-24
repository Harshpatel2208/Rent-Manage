'use strict';

const { error } = require('../utils/responseHelper');

/**
 * Middleware that enforces tenant isolation.
 * Verifies req.user.tenantId is present (set by requireAuth) and attaches
 * it to req.tenantId for convenient access in controllers.
 * Every downstream DB query MUST include WHERE tenant_id = $N using req.tenantId.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
function injectTenant(req, res, next) {
  if (!req.user || !req.user.tenantId) {
    return error(res, 'Tenant context missing. Authentication required.', 401);
  }

  req.tenantId = req.user.tenantId;
  req.userId = req.user.userId;
  req.userRole = req.user.role;

  return next();
}

module.exports = { injectTenant };
