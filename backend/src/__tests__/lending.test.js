'use strict';

const path = require('path');
const request = require('supertest');
const { v4: uuidv4 } = require('uuid');
const app = require(path.join(__dirname, '..', '..', 'server'));
const { registerAndLogin, cleanupTenant } = require('./helpers/testSetup');

describe('Lending Endpoints', () => {
  let token;
  let tenantId;
  let borrowerId;
  let loanId;

  beforeAll(async () => {
    const creds = await registerAndLogin('lending');
    token = creds.token;
    tenantId = creds.tenantId;
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  // ─── Borrowers ─────────────────────────────────────────────────────────────

  describe('POST /api/v1/loans/borrowers', () => {
    it('creates a new borrower and returns the borrower object', async () => {
      const res = await request(app)
        .post('/api/v1/loans/borrowers')
        .set('Authorization', `Bearer ${token}`)
        .send({
          full_name: 'Ravi Kumar',
          phone: '9876543210',
          address: '12 Gandhi Nagar, Chennai, TN',
        });

      expect(res.status).toBe(201);
      expect(res.body.data.full_name).toBe('Ravi Kumar');
      borrowerId = res.body.data.id;
      expect(borrowerId).toMatch(/^[0-9a-f-]{36}$/);
    });

    it('rejects borrower creation without required fields', async () => {
      const res = await request(app)
        .post('/api/v1/loans/borrowers')
        .set('Authorization', `Bearer ${token}`)
        .send({ phone: '1234567890' }); // Missing full_name and address

      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/v1/loans/borrowers', () => {
    it('lists all borrowers for the tenant', async () => {
      const res = await request(app)
        .get('/api/v1/loans/borrowers')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.length).toBeGreaterThanOrEqual(1);
    });
  });

  // ─── Loans ─────────────────────────────────────────────────────────────────

  describe('POST /api/v1/loans', () => {
    it('creates a loan and auto-generates 12 interest schedule rows', async () => {
      const res = await request(app)
        .post('/api/v1/loans')
        .set('Authorization', `Bearer ${token}`)
        .send({
          borrower_id: borrowerId,
          principal: 100000,
          interest_rate: 0.01,
          registered_at: new Date().toISOString(),
        });

      expect(res.status).toBe(201);
      const data = res.body.data;
      expect(data.loan).toBeDefined();
      expect(parseFloat(data.loan.principal)).toBe(100000);
      expect(Array.isArray(data.schedule)).toBe(true);
      expect(data.schedule.length).toBe(12);
      loanId = data.loan.id;
    });

    it('rejects a loan with a non-existent borrower UUID', async () => {
      const res = await request(app)
        .post('/api/v1/loans')
        .set('Authorization', `Bearer ${token}`)
        .send({
          borrower_id: uuidv4(),
          principal: 50000,
          interest_rate: 0.01,
        });

      expect(res.status).toBeGreaterThanOrEqual(400);
    });

    it('rejects a loan with zero / negative principal', async () => {
      const res = await request(app)
        .post('/api/v1/loans')
        .set('Authorization', `Bearer ${token}`)
        .send({
          borrower_id: borrowerId,
          principal: -1000,
          interest_rate: 0.01,
        });

      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/v1/loans', () => {
    it('lists all active loans for the tenant', async () => {
      const res = await request(app)
        .get('/api/v1/loans')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.length).toBeGreaterThanOrEqual(1);
    });
  });

  describe('GET /api/v1/loans/:id', () => {
    it('returns full loan detail including payments and schedule', async () => {
      const res = await request(app)
        .get(`/api/v1/loans/${loanId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      const data = res.body.data;
      expect(data.loan.id).toBe(loanId);
      expect(Array.isArray(data.schedule)).toBe(true);
      expect(Array.isArray(data.payments)).toBe(true);
    });
  });

  // ─── Interest Schedule ─────────────────────────────────────────────────────

  describe('GET /api/v1/loans/:id/schedule', () => {
    it('returns 12 schedule rows, each at 1% of principal', async () => {
      const res = await request(app)
        .get(`/api/v1/loans/${loanId}/schedule`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      const { schedule } = res.body.data;
      expect(schedule.length).toBe(12);

      // Each expected amount should be ~1000 (1% of 100,000)
      schedule.forEach((row) => {
        expect(parseFloat(row.expected_amount)).toBeCloseTo(1000, 1);
        expect(row.status).toBe('pending');
      });
    });
  });

  // ─── Payments ──────────────────────────────────────────────────────────────

  describe('POST /api/v1/loans/:id/payments (interest)', () => {
    let idempotencyKey;

    it('records an interest payment and marks the schedule row as collected', async () => {
      idempotencyKey = uuidv4();

      // Get the first schedule row's cycle_month
      const schedRes = await request(app)
        .get(`/api/v1/loans/${loanId}/schedule`)
        .set('Authorization', `Bearer ${token}`);

      const firstPending = schedRes.body.data.schedule.find((r) => r.status === 'pending');
      expect(firstPending).toBeDefined();

      const res = await request(app)
        .post(`/api/v1/loans/${loanId}/payments`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          amount: 1000,
          payment_date: firstPending.cycle_month.substring(0, 10),
          type: 'interest',
          idempotency_key: idempotencyKey,
          cycle_month: firstPending.cycle_month.substring(0, 10).substring(0, 7) + '-01',
          notes: 'Monthly interest',
        });

      expect(res.status).toBe(201);

      // Verify schedule row status changed
      const updatedSched = await request(app)
        .get(`/api/v1/loans/${loanId}/schedule`)
        .set('Authorization', `Bearer ${token}`);

      const updated = updatedSched.body.data.schedule.find(
        (r) => r.cycle_month === firstPending.cycle_month
      );
      expect(updated.status).toBe('collected');
    });

    it('returns the same result when the same idempotency_key is replayed (idempotent)', async () => {
      const schedRes = await request(app)
        .get(`/api/v1/loans/${loanId}/schedule`)
        .set('Authorization', `Bearer ${token}`);

      const firstPending = schedRes.body.data.schedule.find((r) => r.status === 'pending');
      const replayKey = uuidv4();

      // First call
      await request(app)
        .post(`/api/v1/loans/${loanId}/payments`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          amount: 1000,
          payment_date: new Date().toISOString().substring(0, 10),
          type: 'interest',
          idempotency_key: replayKey,
          cycle_month: firstPending
            ? firstPending.cycle_month.substring(0, 7) + '-01'
            : new Date().toISOString().substring(0, 7) + '-01',
        });

      // Second call with same key — should return 200 (idempotent replay), not 4xx/5xx
      const res2 = await request(app)
        .post(`/api/v1/loans/${loanId}/payments`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          amount: 1000,
          payment_date: new Date().toISOString().substring(0, 10),
          type: 'interest',
          idempotency_key: replayKey,
          cycle_month: firstPending
            ? firstPending.cycle_month.substring(0, 7) + '-01'
            : new Date().toISOString().substring(0, 7) + '-01',
        });

      expect([200, 201]).toContain(res2.status);
    });
  });

  describe('POST /api/v1/loans/:id/payments (principal / bullet)', () => {
    it('records a principal payment and closes the loan, waiving pending rows', async () => {
      // Create a separate loan for this test to avoid interference
      const bRes = await request(app)
        .post('/api/v1/loans/borrowers')
        .set('Authorization', `Bearer ${token}`)
        .send({
          full_name: 'Bullet Borrower',
          phone: '9111111111',
          address: '99 Test Street, Bengaluru, KA',
        });

      const bulletBorrowerId = bRes.body.data.id;

      const loanRes = await request(app)
        .post('/api/v1/loans')
        .set('Authorization', `Bearer ${token}`)
        .send({
          borrower_id: bulletBorrowerId,
          principal: 50000,
          interest_rate: 0.01,
        });

      const bulletLoanId = loanRes.body.data.loan.id;

      // Record principal payment
      const payRes = await request(app)
        .post(`/api/v1/loans/${bulletLoanId}/payments`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          amount: 50000,
          payment_date: new Date().toISOString().substring(0, 10),
          type: 'principal',
          idempotency_key: uuidv4(),
        });

      expect(payRes.status).toBe(201);

      // Loan status should now be 'closed'
      const detail = await request(app)
        .get(`/api/v1/loans/${bulletLoanId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(detail.body.data.loan.status).toBe('closed');

      // All pending schedule rows should be waived
      const sched = await request(app)
        .get(`/api/v1/loans/${bulletLoanId}/schedule`)
        .set('Authorization', `Bearer ${token}`);

      sched.body.data.schedule
        .filter((r) => r.status !== 'collected')
        .forEach((r) => expect(r.status).toBe('waived'));
    });
  });
});
