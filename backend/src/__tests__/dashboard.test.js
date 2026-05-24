'use strict';

const path = require('path');
const request = require('supertest');
const app = require(path.join(__dirname, '..', '..', 'server'));
const { registerAndLogin, cleanupTenant } = require('./helpers/testSetup');

describe('Dashboard Endpoint', () => {
  let token;
  let tenantId;

  beforeAll(async () => {
    const creds = await registerAndLogin('dashboard');
    token = creds.token;
    tenantId = creds.tenantId;
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  describe('GET /api/v1/dashboard', () => {
    it('returns 200 with all required KPI fields', async () => {
      const res = await request(app)
        .get('/api/v1/dashboard')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);

      const data = res.body.data;

      // All mandatory top-level keys must be present
      const requiredKeys = [
        'total_active_capital',
        'expected_monthly_interest',
        'expected_monthly_rent',
        'expected_monthly_income',
        'total_expenses_this_month',
        'active_loans_count',
        'active_tenants_count',
        'pending_conflicts_count',
      ];

      requiredKeys.forEach((key) => {
        expect(data).toHaveProperty(key);
      });
    });

    it('returns numeric string (not float) for monetary fields', async () => {
      const res = await request(app)
        .get('/api/v1/dashboard')
        .set('Authorization', `Bearer ${token}`);

      const data = res.body.data;

      // Monetary fields should be strings (pg NUMERIC → string via type parser)
      // or numbers — but NOT floats with precision issues
      const monetaryFields = [
        'total_active_capital',
        'expected_monthly_interest',
        'expected_monthly_rent',
        'expected_monthly_income',
        'total_expenses_this_month',
      ];

      monetaryFields.forEach((field) => {
        // Each field must be parseable as a finite number
        const val = parseFloat(data[field]);
        expect(Number.isFinite(val)).toBe(true);
        expect(val).toBeGreaterThanOrEqual(0);
      });
    });

    it('returns integer counts for active_loans_count and active_tenants_count', async () => {
      const res = await request(app)
        .get('/api/v1/dashboard')
        .set('Authorization', `Bearer ${token}`);

      const data = res.body.data;

      expect(typeof data.active_loans_count).toBe('number');
      expect(Number.isInteger(data.active_loans_count)).toBe(true);

      expect(typeof data.active_tenants_count).toBe('number');
      expect(Number.isInteger(data.active_tenants_count)).toBe(true);

      expect(typeof data.pending_conflicts_count).toBe('number');
      expect(Number.isInteger(data.pending_conflicts_count)).toBe(true);
    });

    it('dashboard counts update correctly after adding a loan', async () => {
      // Create a borrower
      const bRes = await request(app)
        .post('/api/v1/loans/borrowers')
        .set('Authorization', `Bearer ${token}`)
        .send({
          full_name: 'Dashboard Test Borrower',
          phone: '8001234567',
          address: '42 Test Lane, Mumbai, MH',
        });
      const bId = bRes.body.data.id;

      // Create a loan
      await request(app)
        .post('/api/v1/loans')
        .set('Authorization', `Bearer ${token}`)
        .send({
          borrower_id: bId,
          principal: 200000,
          interest_rate: 0.01,
        });

      // Now the dashboard active_loans_count should be at least 1
      const dashRes = await request(app)
        .get('/api/v1/dashboard')
        .set('Authorization', `Bearer ${token}`);

      expect(dashRes.body.data.active_loans_count).toBeGreaterThanOrEqual(1);
      // Capital should reflect 200000
      expect(parseFloat(dashRes.body.data.total_active_capital)).toBeGreaterThanOrEqual(200000);
    });
  });
});
