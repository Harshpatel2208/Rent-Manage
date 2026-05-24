'use strict';

const path = require('path');
const request = require('supertest');
const app = require(path.join(__dirname, '..', '..', '..', 'server'));
const { query, pool } = require(path.join(__dirname, '..', '..', 'config', 'db'));

/**
 * Register a fresh tenant + admin user and return authentication details.
 * Each call creates a unique tenant to allow parallel test isolation.
 * @param {string} [suffix=''] - Optional suffix to make emails unique between test files.
 * @returns {Promise<{token: string, refreshToken: string, tenantId: string, userId: string, email: string}>}
 */
async function registerAndLogin(suffix = '') {
  const unique = `${Date.now()}_${Math.floor(Math.random() * 99999)}${suffix}`;
  const email = `test_${unique}@rentmanager.com`;
  const password = 'TestPass123!';

  const regRes = await request(app)
    .post('/api/v1/auth/register')
    .send({
      tenant_name: `Test Tenant ${unique}`,
      email,
      password,
    });

  if (regRes.status !== 201) {
    throw new Error(
      `Registration failed (${regRes.status}): ${JSON.stringify(regRes.body)}`
    );
  }

  const { token, refresh_token: refreshToken, user } = regRes.body.data;
  const { tenant_id: tenantId, id: userId } = user;

  return { token, refreshToken, tenantId, userId, email, password };
}

/**
 * Log in with email + password and return tokens.
 */
async function loginUser(email, password) {
  const res = await request(app)
    .post('/api/v1/auth/login')
    .send({ email, password });

  if (res.status !== 200) {
    throw new Error(`Login failed (${res.status}): ${JSON.stringify(res.body)}`);
  }

  return res.body.data;
}

/**
 * Delete all data associated with a tenant (for afterAll cleanup).
 * Relies on cascade deletes via FK relationships.
 */
async function cleanupTenant(tenantId) {
  if (!tenantId) return;
  try {
    // Delete from all leaf tables first, then parent tables
    const tables = [
      'fcm_tokens',
      'sync_conflicts',
      'loan_interest_schedule',
      'loan_payments',
      'loans',
      'borrowers',
      'rent_payments',
      'rental_tenants',
      'shop_units',
      'expenses',
      'otp_codes',
      'refresh_tokens',
      'users',
      'tenants',
    ];

    for (const table of tables) {
      if (table === 'tenants') {
        await query(`DELETE FROM tenants WHERE id = $1`, [tenantId]);
      } else if (table === 'otp_codes' || table === 'refresh_tokens') {
        await query(`DELETE FROM ${table} WHERE user_id IN (SELECT id FROM users WHERE tenant_id = $1)`, [tenantId]);
      } else {
        await query(`DELETE FROM ${table} WHERE tenant_id = $1`, [tenantId]);
      }
    }
  } catch (err) {
    console.warn(`[testSetup] Cleanup warning for tenant ${tenantId}: ${err.message}`);
  }
}

/**
 * End the pg pool — call once in the very last afterAll to prevent Jest
 * from hanging with open handles.
 */
async function closePool() {
  await pool.end();
}

module.exports = { registerAndLogin, loginUser, cleanupTenant, closePool };
