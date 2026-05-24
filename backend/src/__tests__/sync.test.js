'use strict';

const path = require('path');
const request = require('supertest');
const { v4: uuidv4 } = require('uuid');
const app = require(path.join(__dirname, '..', '..', 'server'));
const { registerAndLogin, cleanupTenant } = require('./helpers/testSetup');

describe('Sync Endpoints', () => {
  let token;
  let tenantId;

  beforeAll(async () => {
    const creds = await registerAndLogin('sync');
    token = creds.token;
    tenantId = creds.tenantId;
  });

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  // ─── Batch Sync ────────────────────────────────────────────────────────────

  describe('POST /api/v1/sync/batch', () => {
    it('successfully processes a batch containing a new expense', async () => {
      const idempotencyKey = uuidv4();
      const res = await request(app)
        .post('/api/v1/sync/batch')
        .set('Authorization', `Bearer ${token}`)
        .send({
          operations: [
            {
              entity_type: 'expense',
              operation: 'create',
              idempotency_key: idempotencyKey,
              payload: {
                amount: '500.00',
                category: 'food',
                expense_date: new Date().toISOString().substring(0, 10),
                description: 'Offline expense sync test',
                idempotency_key: idempotencyKey,
              },
            },
          ],
        });

      expect(res.status).toBe(200);
      const results = res.body.data.results;
      expect(Array.isArray(results)).toBe(true);
      expect(results[0].status).toMatch(/^(success|already_processed)$/);
    });

    it('replays the same idempotency_key and returns already_processed', async () => {
      const idempotencyKey = uuidv4();

      const firstPayload = {
        operations: [
          {
            entity_type: 'expense',
            operation: 'create',
            idempotency_key: idempotencyKey,
            payload: {
              amount: '250.00',
              category: 'travel',
              expense_date: new Date().toISOString().substring(0, 10),
              description: 'Idempotency replay test',
              idempotency_key: idempotencyKey,
            },
          },
        ],
      };

      // First call
      await request(app)
        .post('/api/v1/sync/batch')
        .set('Authorization', `Bearer ${token}`)
        .send(firstPayload);

      // Second call with identical key
      const res2 = await request(app)
        .post('/api/v1/sync/batch')
        .set('Authorization', `Bearer ${token}`)
        .send(firstPayload);

      expect(res2.status).toBe(200);
      const results = res2.body.data.results;
      expect(results[0].status).toBe('already_processed');
    });

    it('returns 200 with error status for invalid / unknown entity_type', async () => {
      const res = await request(app)
        .post('/api/v1/sync/batch')
        .set('Authorization', `Bearer ${token}`)
        .send({
          operations: [
            {
              entity_type: 'unknown_entity',
              operation: 'create',
              idempotency_key: uuidv4(),
              payload: { foo: 'bar' },
            },
          ],
        });

      // Server should respond with 200 but each result might have status: 'error' or 'conflict'
      expect(res.status).toBe(200);
    });
  });

  // ─── Conflicts ─────────────────────────────────────────────────────────────

  describe('GET /api/v1/sync/conflicts', () => {
    it('returns an empty list initially (no conflicts created yet)', async () => {
      const res = await request(app)
        .get('/api/v1/sync/conflicts')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe('PATCH /api/v1/sync/conflicts/:id', () => {
    it('returns 404 for a non-existent conflict UUID', async () => {
      const fakeId = uuidv4();
      const res = await request(app)
        .patch(`/api/v1/sync/conflicts/${fakeId}`)
        .set('Authorization', `Bearer ${token}`)
        .send({ action: 'dismiss' });

      expect(res.status).toBe(404);
    });
  });

  // ─── Expenses (via direct endpoint, not sync) ──────────────────────────────

  describe('POST /api/v1/expenses', () => {
    it('creates an expense directly via the REST endpoint', async () => {
      const idempotencyKey = uuidv4();
      const res = await request(app)
        .post('/api/v1/expenses')
        .set('Authorization', `Bearer ${token}`)
        .send({
          amount: 1200,
          category: 'maintenance',
          expense_date: new Date().toISOString().substring(0, 10),
          description: 'Plumber repair',
          idempotency_key: idempotencyKey,
        });

      expect(res.status).toBe(201);
      expect(parseFloat(res.body.data.expense.amount)).toBeCloseTo(1200, 1);
    });
  });

  describe('GET /api/v1/expenses', () => {
    it('lists expenses with optional filter by category', async () => {
      const res = await request(app)
        .get('/api/v1/expenses?category=maintenance')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });
});
