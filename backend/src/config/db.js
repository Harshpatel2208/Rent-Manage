'use strict';

const { Pool } = require('pg');
const config = require('./env');

const pool = new Pool({
  connectionString: config.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
  ssl: config.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

// ─── Force pg to return NUMERIC/DECIMAL as strings (not JS floats) ────────────
// This preserves decimal precision for monetary values (DECIMAL(19,4))
const pg = require('pg');
pg.types.setTypeParser(pg.types.builtins.NUMERIC, (val) => val);
pg.types.setTypeParser(pg.types.builtins.INT8, (val) => val);
pg.types.setTypeParser(pg.types.builtins.DATE, (val) => val);

pool.on('connect', () => {
  if (config.NODE_ENV === 'development') {
    console.log('[DB] New client connected to PostgreSQL pool');
  }
});

pool.on('error', (err) => {
  console.error('[DB] Unexpected error on idle client:', err.message);
});

/**
 * Execute a parameterized SQL query against the PostgreSQL pool.
 * @param {string} text - SQL query string with $1, $2, ... placeholders
 * @param {Array} [params=[]] - Query parameter values
 * @returns {Promise<import('pg').QueryResult>} PostgreSQL query result
 */
async function query(text, params = []) {
  const start = Date.now();
  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    if (config.NODE_ENV === 'development') {
      console.log('[DB] Query executed', { text: text.substring(0, 80), duration: `${duration}ms`, rows: result.rowCount });
    }
    return result;
  } catch (err) {
    console.error('[DB] Query error:', { text: text.substring(0, 80), error: err.message });
    throw err;
  }
}

/**
 * Get a dedicated client from the pool for transaction use.
 * Remember to call client.release() after done.
 * @returns {Promise<import('pg').PoolClient>} PostgreSQL pool client
 */
async function getClient() {
  return pool.connect();
}

/**
 * Execute a function within a PostgreSQL transaction.
 * Automatically commits on success and rolls back on error.
 * @param {function(import('pg').PoolClient): Promise<*>} fn - Async function receiving the client
 * @returns {Promise<*>} Result of the provided function
 */
async function withTransaction(fn) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { query, getClient, withTransaction, pool };
