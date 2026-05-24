'use strict';

/**
 * Date utility functions for billing cycle calculations.
 * Dates are always stored as DATE (no time) in PostgreSQL.
 * Cycle months are always the 1st day of the month (e.g., 2024-03-01).
 */

/**
 * Get the first day of the next calendar month from the given date.
 *
 * @param {Date|string} date - Reference date
 * @returns {Date} First day of the next month at midnight UTC
 *
 * @example
 * getFirstOfNextMonth('2024-03-15') // => Date('2024-04-01')
 */
function getFirstOfNextMonth(date) {
  const d = new Date(date);
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 1));
}

/**
 * Get the first day of the current calendar month (UTC).
 *
 * @returns {Date} First day of the current month at midnight UTC
 */
function getCurrentCycleMonth() {
  const now = new Date();
  return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1));
}

/**
 * Format a Date object as a YYYY-MM-DD string suitable for PostgreSQL DATE columns.
 * Always uses the 1st of the month (cycle month key).
 *
 * @param {Date} date - Date to format
 * @returns {string} ISO date string e.g. "2024-03-01"
 */
function formatMonthKey(date) {
  const d = new Date(date);
  const year = d.getUTCFullYear();
  const month = String(d.getUTCMonth() + 1).padStart(2, '0');
  return `${year}-${month}-01`;
}

/**
 * Format a Date object as a YYYY-MM-DD string.
 *
 * @param {Date|string} date - Date to format
 * @returns {string} ISO date string e.g. "2024-03-15"
 */
function formatDate(date) {
  const d = new Date(date);
  const year = d.getUTCFullYear();
  const month = String(d.getUTCMonth() + 1).padStart(2, '0');
  const day = String(d.getUTCDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * Generate an array of cycle month dates (1st of each month) for N months
 * starting from the given start date.
 *
 * @param {Date|string} startDate - First cycle date (will be normalized to 1st)
 * @param {number} count - Number of months to generate
 * @returns {Date[]} Array of Date objects, each being the 1st of a month
 */
function generateCycleMonths(startDate, count) {
  const months = [];
  const start = new Date(startDate);
  let year = start.getUTCFullYear();
  let month = start.getUTCMonth();

  for (let i = 0; i < count; i++) {
    months.push(new Date(Date.UTC(year, month, 1)));
    month++;
    if (month > 11) {
      month = 0;
      year++;
    }
  }

  return months;
}

/**
 * Get the first day of the next month after the given cycle month.
 *
 * @param {Date|string} cycleMonth
 * @returns {Date}
 */
function getNextCycleMonth(cycleMonth) {
  const d = new Date(cycleMonth);
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 1));
}

/**
 * Get a human-readable month/year label from a cycle date.
 *
 * @param {Date|string} date
 * @returns {string} e.g. "March 2024"
 */
function formatMonthLabel(date) {
  const d = new Date(date);
  return d.toLocaleDateString('en-US', { month: 'long', year: 'numeric', timeZone: 'UTC' });
}

module.exports = {
  getFirstOfNextMonth,
  getCurrentCycleMonth,
  formatMonthKey,
  formatDate,
  generateCycleMonths,
  getNextCycleMonth,
  formatMonthLabel,
};
