'use strict';

/**
 * Standardized JSON response helpers.
 * All API responses follow the shape:
 *   Success: { success: true, data: {...}, meta?: {...} }
 *   Error:   { success: false, error: "..." }
 */

/**
 * Send a standardized success response.
 *
 * @param {import('express').Response} res - Express response object
 * @param {*} data - Response payload
 * @param {number} [statusCode=200] - HTTP status code
 * @param {object} [meta] - Optional pagination or metadata
 * @returns {import('express').Response}
 */
function success(res, data, statusCode = 200, meta = undefined) {
  const response = { success: true, data };
  if (meta) response.meta = meta;
  return res.status(statusCode).json(response);
}

/**
 * Send a standardized error response.
 *
 * @param {import('express').Response} res - Express response object
 * @param {string} message - Human-readable error message
 * @param {number} [statusCode=400] - HTTP status code
 * @param {Array} [details] - Optional array of field-level error details
 * @returns {import('express').Response}
 */
function error(res, message, statusCode = 400, details = undefined) {
  const response = { success: false, error: message };
  if (details) response.details = details;
  return res.status(statusCode).json(response);
}

/**
 * Send a paginated success response.
 *
 * @param {import('express').Response} res - Express response object
 * @param {Array} items - Array of result items
 * @param {number} total - Total count of items (before pagination)
 * @param {number} page - Current page number (1-indexed)
 * @param {number} limit - Items per page
 * @returns {import('express').Response}
 */
function paginated(res, items, total, page, limit) {
  return res.status(200).json({
    success: true,
    data: items,
    meta: {
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
      hasMore: page * limit < total,
    },
  });
}

module.exports = { success, error, paginated };
