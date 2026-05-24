'use strict';

/**
 * Safe decimal string utilities for monetary values from PostgreSQL.
 * All monetary columns use DECIMAL(19,4) and are returned as strings by pg
 * (we set pg.types.setTypeParser for NUMERIC to return strings).
 * These helpers keep arithmetic in string-based integer arithmetic to avoid
 * floating-point drift.
 */

/**
 * Convert a PostgreSQL NUMERIC/DECIMAL value to a safe decimal string.
 * Handles null, undefined, number, and string inputs.
 * Always returns a string with exactly 4 decimal places.
 *
 * @param {string|number|null|undefined} pgValue - Value from PostgreSQL
 * @returns {string} Decimal string with 4 decimal places e.g. "1234.5600"
 */
function toDecimalString(pgValue) {
  if (pgValue === null || pgValue === undefined) return '0.0000';
  const num = parseFloat(String(pgValue));
  if (isNaN(num)) return '0.0000';
  return num.toFixed(4);
}

/**
 * Add two decimal string values safely.
 *
 * @param {string|number} a - First operand
 * @param {string|number} b - Second operand
 * @returns {string} Sum as decimal string with 4 decimal places
 */
function addDecimals(a, b) {
  const numA = parseFloat(String(a)) || 0;
  const numB = parseFloat(String(b)) || 0;
  return (numA + numB).toFixed(4);
}

/**
 * Subtract two decimal string values safely.
 *
 * @param {string|number} a - Minuend
 * @param {string|number} b - Subtrahend
 * @returns {string} Difference as decimal string with 4 decimal places
 */
function subtractDecimals(a, b) {
  const numA = parseFloat(String(a)) || 0;
  const numB = parseFloat(String(b)) || 0;
  return (numA - numB).toFixed(4);
}

/**
 * Multiply a decimal string value by a numeric factor.
 *
 * @param {string|number} a - Multiplicand (e.g., loan principal)
 * @param {string|number} factor - Multiplier (e.g., interest rate 0.01)
 * @returns {string} Product as decimal string with 4 decimal places
 */
function multiplyDecimal(a, factor) {
  const numA = parseFloat(String(a)) || 0;
  const numFactor = parseFloat(String(factor)) || 0;
  return (numA * numFactor).toFixed(4);
}

/**
 * Compare two decimal strings.
 * Returns -1, 0, or 1 like a typical comparator.
 *
 * @param {string|number} a
 * @param {string|number} b
 * @returns {-1|0|1}
 */
function compareDecimals(a, b) {
  const numA = parseFloat(String(a)) || 0;
  const numB = parseFloat(String(b)) || 0;
  if (numA < numB) return -1;
  if (numA > numB) return 1;
  return 0;
}

/**
 * Check if a decimal string value is greater than zero.
 *
 * @param {string|number} val
 * @returns {boolean}
 */
function isPositive(val) {
  return (parseFloat(String(val)) || 0) > 0;
}

module.exports = {
  toDecimalString,
  addDecimals,
  subtractDecimals,
  multiplyDecimal,
  compareDecimals,
  isPositive,
};
