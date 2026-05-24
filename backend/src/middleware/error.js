'use strict';

/**
 * Global Express error handler middleware.
 * Must be registered last with app.use(errorHandler).
 * Handles Joi validation errors, PostgreSQL errors, JWT errors, and generic 500s.
 *
 * @param {Error} err
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} _next
 */
function errorHandler(err, req, res, _next) {
  // Log error details for debugging
  console.error('[ErrorHandler]', {
    name: err.name,
    message: err.message,
    path: req.path,
    method: req.method,
    code: err.code,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
  });

  // ─── Joi Validation Error ─────────────────────────────────────────────────
  if (err.name === 'ValidationError' && err.isJoi) {
    return res.status(400).json({
      success: false,
      error: 'Validation failed',
      details: err.details.map((d) => ({ field: d.path.join('.'), message: d.message })),
    });
  }

  // ─── PostgreSQL Unique Violation (23505) ──────────────────────────────────
  if (err.code === '23505') {
    const match = err.detail && err.detail.match(/Key \((.+)\)=\((.+)\) already exists/);
    const field = match ? match[1] : 'field';
    return res.status(409).json({
      success: false,
      error: `Duplicate value: ${field} already exists`,
    });
  }

  // ─── PostgreSQL Foreign Key Violation (23503) ─────────────────────────────
  if (err.code === '23503') {
    const match = err.detail && err.detail.match(/Key \((.+)\)=\((.+)\) is not present in table/);
    const info = match ? `${match[1]} with value ${match[2]} not found` : 'Referenced record not found';
    return res.status(400).json({
      success: false,
      error: `Foreign key constraint violated: ${info}`,
    });
  }

  // ─── PostgreSQL Check Violation (23514) ───────────────────────────────────
  if (err.code === '23514') {
    return res.status(400).json({
      success: false,
      error: 'Value failed database check constraint',
    });
  }

  // ─── JWT Errors ──────────────────────────────────────────────────────────
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({ success: false, error: 'Invalid token' });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({ success: false, error: 'Token has expired' });
  }

  // ─── Multer / Payload Too Large ───────────────────────────────────────────
  if (err.type === 'entity.too.large') {
    return res.status(413).json({ success: false, error: 'Request payload too large' });
  }

  // ─── SyntaxError (bad JSON body) ──────────────────────────────────────────
  if (err instanceof SyntaxError && err.status === 400) {
    return res.status(400).json({ success: false, error: 'Invalid JSON in request body' });
  }

  // ─── Custom App Errors with statusCode ────────────────────────────────────
  if (err.statusCode) {
    return res.status(err.statusCode).json({ success: false, error: err.message });
  }

  // ─── Generic 500 ─────────────────────────────────────────────────────────
  return res.status(500).json({
    success: false,
    error: process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message,
  });
}

module.exports = errorHandler;
