'use strict';

/**
 * Migration runner: reads all .sql files from the migrations directory
 * in numeric order and executes them against the database.
 */

require('dotenv').config();

const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

async function runMigrations() {
  const client = await pool.connect();
  try {
    // Create migrations tracking table if it doesn't exist
    await client.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version VARCHAR(255) PRIMARY KEY,
        ran_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `);

    const migrationsDir = path.join(__dirname);
    const sqlFiles = fs
      .readdirSync(migrationsDir)
      .filter((f) => f.endsWith('.sql'))
      .sort();

    for (const file of sqlFiles) {
      const version = file.replace('.sql', '');
      const { rows } = await client.query('SELECT version FROM schema_migrations WHERE version = $1', [version]);

      if (rows.length > 0) {
        console.log(`[Migration] Skipping ${file} (already ran)`);
        continue;
      }

      console.log(`[Migration] Running ${file}...`);
      const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
      await client.query('BEGIN');
      await client.query(sql);
      await client.query('INSERT INTO schema_migrations (version) VALUES ($1)', [version]);
      await client.query('COMMIT');
      console.log(`[Migration] ✓ ${file} completed`);
    }

    console.log('[Migration] All migrations completed successfully');
  } catch (err) {
    await client.query('ROLLBACK').catch(() => {});
    console.error('[Migration] Error:', err.message);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

if (require.main === module) {
  runMigrations().catch(() => process.exit(1));
}

module.exports = runMigrations;
