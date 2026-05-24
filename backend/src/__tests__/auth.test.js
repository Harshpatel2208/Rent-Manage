'use strict';

const path = require('path');
const request = require('supertest');
const app = require(path.join(__dirname, '..', '..', 'server'));
const { registerAndLogin, loginUser, cleanupTenant } = require('./helpers/testSetup');

describe('Auth Endpoints', () => {
  let tenantId;
  let token;
  let refreshToken;
  let testEmail;
  let testPassword;

  afterAll(async () => {
    await cleanupTenant(tenantId);
  });

  // ─── Registration ──────────────────────────────────────────────────────────

  describe('POST /api/v1/auth/register', () => {
    it('creates a new tenant and admin user, returning JWT and refresh token', async () => {
      const creds = await registerAndLogin('auth');
      token = creds.token;
      refreshToken = creds.refreshToken;
      tenantId = creds.tenantId;
      testEmail = creds.email;
      testPassword = creds.password;

      expect(token).toBeTruthy();
      expect(refreshToken).toBeTruthy();
      expect(tenantId).toMatch(/^[0-9a-f-]{36}$/); // UUID format
    });

    it('rejects duplicate email registration with 409', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          tenant_name: 'Duplicate Tenant',
          email: testEmail,
          password: 'AnotherPass123!',
        });

      expect(res.status).toBe(409);
    });

    it('rejects invalid registration payload with 400', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({ email: 'bad' }); // Missing required fields

      expect(res.status).toBe(400);
    });
  });

  // ─── Login ─────────────────────────────────────────────────────────────────

  describe('POST /api/v1/auth/login', () => {
    it('returns access_token and refresh_token for valid credentials', async () => {
      const data = await loginUser(testEmail, testPassword);

      expect(data.token).toBeTruthy();
      expect(data.refresh_token).toBeTruthy();
      expect(data.user.email).toBe(testEmail);
    });

    it('rejects wrong password with 401', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({ email: testEmail, password: 'WrongPassword!' });

      expect(res.status).toBe(401);
    });

    it('rejects unknown email with 401', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({ email: 'nobody@nowhere.test', password: 'Test123!' });

      expect(res.status).toBe(401);
    });
  });

  // ─── Refresh Token ─────────────────────────────────────────────────────────

  describe('POST /api/v1/auth/refresh', () => {
    it('issues a new access token given a valid refresh token', async () => {
      const loginData = await loginUser(testEmail, testPassword);
      const res = await request(app)
        .post('/api/v1/auth/refresh')
        .send({ refresh_token: loginData.refresh_token });

      expect(res.status).toBe(200);
      expect(res.body.data.token).toBeTruthy();
    });

    it('rejects an invalid / tampered refresh token with 401', async () => {
      const res = await request(app)
        .post('/api/v1/auth/refresh')
        .send({ refresh_token: 'not-a-valid-token' });

      expect(res.status).toBe(401);
    });
  });

  // ─── Logout ────────────────────────────────────────────────────────────────

  describe('POST /api/v1/auth/logout', () => {
    it('invalidates the refresh token', async () => {
      const loginData = await loginUser(testEmail, testPassword);
      const logoutRes = await request(app)
        .post('/api/v1/auth/logout')
        .set('Authorization', `Bearer ${loginData.token}`)
        .send({ refresh_token: loginData.refresh_token });

      expect([200, 204]).toContain(logoutRes.status);

      // Using the same refresh token after logout should fail
      const refreshRes = await request(app)
        .post('/api/v1/auth/refresh')
        .send({ refresh_token: loginData.refresh_token });

      expect(refreshRes.status).toBe(401);
    });
  });

  // ─── Auth Guard ────────────────────────────────────────────────────────────

  describe('Auth Guard Middleware', () => {
    it('returns 401 when no Bearer token is provided to protected routes', async () => {
      const res = await request(app).get('/api/v1/dashboard');
      expect(res.status).toBe(401);
    });

    it('returns 401 with a malformed / expired token', async () => {
      const res = await request(app)
        .get('/api/v1/dashboard')
        .set('Authorization', 'Bearer not.a.real.token');
      expect(res.status).toBe(401);
    });

    it('allows access to protected routes with a valid token', async () => {
      const res = await request(app)
        .get('/api/v1/dashboard')
        .set('Authorization', `Bearer ${token}`);
      expect(res.status).toBe(200);
    });
  });
});
