'use strict';

/**
 * Jest Global Teardown
 * Runs once after ALL test suites complete.
 * Ends the PostgreSQL pool to prevent Jest from hanging.
 */
module.exports = async function globalTeardown() {
  try {
    const { pool } = require('./src/config/db');
    await pool.end();
    console.log('[GlobalTeardown] PostgreSQL pool closed.');
  } catch (err) {
    // Pool may already be ended or not initialized — safe to ignore
    if (!err.message.includes('Called end on pool')) {
      console.warn('[GlobalTeardown] Pool teardown warning:', err.message);
    }
  }
};
