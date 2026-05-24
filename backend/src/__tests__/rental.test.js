'use strict';

const path = require('path');
const request = require('supertest');
const { v4: uuidv4 } = require('uuid');
const app = require(path.join(__dirname, '..', '..', 'server'));
const { registerAndLogin, cleanupTenant } = require('./helpers/testSetup');

describe('Rental Endpoints', () => {
  let token;
  let tenantId;
  let unitId;
  let rentalTenantId;

  beforeAll(async () => {
    const creds = await registerAndLogin('rental');
    token = creds.token;
    tenantId = creds.tenantId;
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  // ─── Shop Units ────────────────────────────────────────────────────────────

  describe('POST /api/v1/rental/units', () => {
    it('creates a shop unit', async () => {
      const res = await request(app)
        .post('/api/v1/rental/units')
        .set('Authorization', `Bearer ${token}`)
        .send({
          unit_name: 'Shop A-101',
          address: 'MG Road, Bengaluru',
          description: 'Ground floor corner shop',
        });

      expect(res.status).toBe(201);
      expect(res.body.data.unit_name).toBe('Shop A-101');
      unitId = res.body.data.id;
    });

    it('rejects unit creation without unit_name', async () => {
      const res = await request(app)
        .post('/api/v1/rental/units')
        .set('Authorization', `Bearer ${token}`)
        .send({ address: 'Test Address' });

      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/v1/rental/units', () => {
    it('lists all shop units', async () => {
      const res = await request(app)
        .get('/api/v1/rental/units')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.length).toBeGreaterThanOrEqual(1);
    });
  });

  // ─── Rental Tenants ────────────────────────────────────────────────────────

  describe('POST /api/v1/rental/tenants', () => {
    it('creates a rental tenant and auto-creates current month rent row', async () => {
      const res = await request(app)
        .post('/api/v1/rental/tenants')
        .set('Authorization', `Bearer ${token}`)
        .send({
          full_name: 'Sunita Sharma',
          phone: '9090909090',
          rent_amount: 15000,
          lease_start: new Date().toISOString().substring(0, 10),
          unit_id: unitId,
        });

      expect(res.status).toBe(201);
      expect(res.body.data.full_name).toBe('Sunita Sharma');
      rentalTenantId = res.body.data.id;
    });

    it('rejects tenant creation without required fields', async () => {
      const res = await request(app)
        .post('/api/v1/rental/tenants')
        .set('Authorization', `Bearer ${token}`)
        .send({ phone: '1111111111' }); // Missing full_name and rent_amount

      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/v1/rental/tenants', () => {
    it('lists all rental tenants', async () => {
      const res = await request(app)
        .get('/api/v1/rental/tenants')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  // ─── Tenant Ledger ─────────────────────────────────────────────────────────

  describe('GET /api/v1/rental/tenants/:id (ledger)', () => {
    it('returns ledger with 1 pending rent row for current month', async () => {
      const res = await request(app)
        .get(`/api/v1/rental/tenants/${rentalTenantId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      const data = res.body.data;
      expect(data.tenant).toBeDefined();
      expect(Array.isArray(data.payments)).toBe(true);
      // Auto-created row from tenant creation
      expect(data.payments.length).toBeGreaterThanOrEqual(1);
      expect(data.payments[0].status).toBe('pending');
    });
  });

  // ─── Rent Payments ─────────────────────────────────────────────────────────

  describe('POST /api/v1/rental/payments (partial)', () => {
    it('records a partial payment and sets status to partially_paid', async () => {
      const idempotencyKey = uuidv4();
      const now = new Date();
      const cycleMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01`;

      const res = await request(app)
        .post('/api/v1/rental/payments')
        .set('Authorization', `Bearer ${token}`)
        .send({
          rental_tenant_id: rentalTenantId,
          cycle_month: cycleMonth,
          amount_paid: 7500, // Half of 15,000
          idempotency_key: idempotencyKey,
          notes: 'Partial month 1',
        });

      expect(res.status).toBe(201);

      // Verify ledger shows partially_paid
      const ledger = await request(app)
        .get(`/api/v1/rental/tenants/${rentalTenantId}`)
        .set('Authorization', `Bearer ${token}`);

      const row = ledger.body.data.payments.find(
        (p) => p.cycle_month && p.cycle_month.startsWith(cycleMonth.substring(0, 7))
      );
      expect(row).toBeDefined();
      expect(row.status).toBe('partially_paid');
      expect(parseFloat(row.amount_paid)).toBeCloseTo(7500, 1);
    });
  });

  describe('POST /api/v1/rental/payments (full)', () => {
    it('records a full payment and sets status to paid', async () => {
      const idempotencyKey = uuidv4();
      const now = new Date();
      const cycleMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01`;

      // Record remaining 7500 to complete 15000
      const res = await request(app)
        .post('/api/v1/rental/payments')
        .set('Authorization', `Bearer ${token}`)
        .send({
          rental_tenant_id: rentalTenantId,
          cycle_month: cycleMonth,
          amount_paid: 7500, // Remaining half
          idempotency_key: idempotencyKey,
          notes: 'Remaining half',
        });

      expect(res.status).toBe(201);

      // Verify ledger shows paid
      const ledger = await request(app)
        .get(`/api/v1/rental/tenants/${rentalTenantId}`)
        .set('Authorization', `Bearer ${token}`);

      const row = ledger.body.data.payments.find(
        (p) => p.cycle_month && p.cycle_month.startsWith(cycleMonth.substring(0, 7))
      );
      expect(row).toBeDefined();
      expect(row.status).toBe('paid');
      expect(parseFloat(row.amount_paid)).toBeCloseTo(15000, 1);
    });
  });
});
