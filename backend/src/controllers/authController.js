'use strict';

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { OAuth2Client } = require('google-auth-library');
const twilio = require('twilio');

const db = require('../config/db');
const config = require('../config/env');
const { success, error } = require('../utils/responseHelper');

const googleClient = new OAuth2Client(config.GOOGLE_CLIENT_ID);
const twilioClient = twilio(config.TWILIO_ACCOUNT_SID, config.TWILIO_AUTH_TOKEN);

const SALT_ROUNDS = 12;
const OTP_EXPIRY_MINUTES = 10;
const OTP_LENGTH = 6;

/**
 * Generate a signed JWT access token.
 * @param {string} userId
 * @param {string} tenantId
 * @param {string} role
 * @returns {string} Signed JWT
 */
function generateAccessToken(userId, tenantId, role) {
  return jwt.sign({ userId, tenantId, role }, config.JWT_SECRET, {
    expiresIn: config.JWT_EXPIRES_IN,
  });
}

/**
 * Generate a signed JWT refresh token.
 * @param {string} userId
 * @returns {string} Signed refresh JWT
 */
function generateRefreshToken(userId) {
  return jwt.sign({ userId, jti: uuidv4() }, config.JWT_REFRESH_SECRET, {
    expiresIn: config.REFRESH_EXPIRES_IN,
  });
}

/**
 * Store a refresh token hash in the database.
 * @param {string} userId
 * @param {string} refreshToken
 * @param {import('pg').PoolClient} [client] - Optional transaction client
 */
async function storeRefreshToken(userId, refreshToken, client = db) {
  const signature = refreshToken.split('.')[2] || refreshToken;
  const tokenHash = await bcrypt.hash(signature, 10);
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);

  await client.query(
    `INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at)
     VALUES ($1, $2, $3, $4)`,
    [uuidv4(), userId, tokenHash, expiresAt]
  );
}

/**
 * Register a new tenant and admin user.
 * Creates the tenant record first, then the admin user with hashed password.
 * Returns JWT access + refresh tokens.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function register(req, res, next) {
  const { tenant_name, email, password, phone } = req.body;

  try {
    const result = await db.withTransaction(async (client) => {
      // Check for existing user
      if (email) {
        const existing = await client.query('SELECT id FROM users WHERE email = $1', [email]);
        if (existing.rows.length > 0) {
          const err = new Error('Email already registered');
          err.statusCode = 409;
          throw err;
        }
      }

      // Create tenant
      const tenantId = uuidv4();
      await client.query(
        'INSERT INTO tenants (id, name) VALUES ($1, $2)',
        [tenantId, tenant_name]
      );

      // Hash password
      const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);
      const userId = uuidv4();

      // Create admin user
      await client.query(
        `INSERT INTO users (id, tenant_id, email, phone, password_hash, role)
         VALUES ($1, $2, $3, $4, $5, 'admin')`,
        [userId, tenantId, email || null, phone || null, passwordHash]
      );

      const accessToken = generateAccessToken(userId, tenantId, 'admin');
      const refreshToken = generateRefreshToken(userId);
      await storeRefreshToken(userId, refreshToken, client);

      return {
        user: { id: userId, tenant_id: tenantId, email, phone, role: 'admin' },
        access_token: accessToken,
        token: accessToken,
        refresh_token: refreshToken,
      };
    });

    return success(res, result, 201);
  } catch (err) {
    return next(err);
  }
}

/**
 * Login with email/phone + password.
 * Returns JWT access + refresh tokens on success.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function login(req, res, next) {
  const { email, phone, password } = req.body;

  try {
    let userRow;

    if (email) {
      const { rows } = await db.query(
        'SELECT id, tenant_id, email, phone, password_hash, role, is_active FROM users WHERE email = $1',
        [email]
      );
      userRow = rows[0];
    } else if (phone) {
      const { rows } = await db.query(
        'SELECT id, tenant_id, email, phone, password_hash, role, is_active FROM users WHERE phone = $1',
        [phone]
      );
      userRow = rows[0];
    } else {
      return error(res, 'Email or phone required', 400);
    }

    if (!userRow) {
      return error(res, 'Invalid credentials', 401);
    }

    if (!userRow.is_active) {
      return error(res, 'Account is deactivated', 403);
    }

    if (!userRow.password_hash) {
      return error(res, 'Password login not set up for this account. Use Google or OTP.', 400);
    }

    const passwordValid = await bcrypt.compare(password, userRow.password_hash);
    if (!passwordValid) {
      return error(res, 'Invalid credentials', 401);
    }

    const accessToken = generateAccessToken(userRow.id, userRow.tenant_id, userRow.role);
    const refreshToken = generateRefreshToken(userRow.id);
    await storeRefreshToken(userRow.id, refreshToken);

    return success(res, {
      user: {
        id: userRow.id,
        tenant_id: userRow.tenant_id,
        email: userRow.email,
        phone: userRow.phone,
        role: userRow.role,
      },
      access_token: accessToken,
      token: accessToken,
      refresh_token: refreshToken,
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Send a 6-digit OTP to the user's phone number via Twilio SMS.
 * Stores a bcrypt hash of the OTP in otp_codes with 10-minute expiry.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function sendOtp(req, res, next) {
  const { phone } = req.body;

  try {
    const { rows } = await db.query(
      'SELECT id, tenant_id, is_active FROM users WHERE phone = $1',
      [phone]
    );

    // Don't leak whether phone exists — always return 200
    if (rows.length === 0) {
      return success(res, { message: 'If this phone is registered, an OTP will be sent.' });
    }

    const user = rows[0];
    if (!user.is_active) {
      return error(res, 'Account is deactivated', 403);
    }

    // Generate 6-digit OTP
    const otp = String(Math.floor(100000 + Math.random() * 900000));
    const otpHash = await bcrypt.hash(otp, 10);
    const expiresAt = new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000);

    // Invalidate previous OTPs for this user
    await db.query('UPDATE otp_codes SET used = true WHERE user_id = $1 AND used = false', [user.id]);

    // Store new OTP
    await db.query(
      'INSERT INTO otp_codes (id, user_id, code_hash, expires_at) VALUES ($1, $2, $3, $4)',
      [uuidv4(), user.id, otpHash, expiresAt]
    );

    // Send via Twilio
    await twilioClient.messages.create({
      body: `Your Rent Manager OTP is: ${otp}. Valid for ${OTP_EXPIRY_MINUTES} minutes.`,
      from: config.TWILIO_PHONE_NUMBER,
      to: phone,
    });

    return success(res, { message: 'OTP sent successfully' });
  } catch (err) {
    return next(err);
  }
}

/**
 * Verify an OTP code and return a JWT access token on success.
 * Marks the OTP as used to prevent replay.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function verifyOtp(req, res, next) {
  const { phone, otp } = req.body;

  try {
    const { rows: userRows } = await db.query(
      'SELECT id, tenant_id, role, is_active FROM users WHERE phone = $1',
      [phone]
    );

    if (userRows.length === 0) {
      return error(res, 'Invalid phone or OTP', 401);
    }

    const user = userRows[0];

    // Get the latest unused, unexpired OTP
    const { rows: otpRows } = await db.query(
      `SELECT id, code_hash FROM otp_codes
       WHERE user_id = $1 AND used = false AND expires_at > NOW()
       ORDER BY created_at DESC LIMIT 1`,
      [user.id]
    );

    if (otpRows.length === 0) {
      return error(res, 'OTP expired or not found', 401);
    }

    const otpRow = otpRows[0];
    const valid = await bcrypt.compare(String(otp), otpRow.code_hash);

    if (!valid) {
      return error(res, 'Invalid OTP', 401);
    }

    // Mark OTP as used
    await db.query('UPDATE otp_codes SET used = true WHERE id = $1', [otpRow.id]);

    const accessToken = generateAccessToken(user.id, user.tenant_id, user.role);
    const refreshToken = generateRefreshToken(user.id);
    await storeRefreshToken(user.id, refreshToken);

    return success(res, {
      user: { id: user.id, tenant_id: user.tenant_id, phone, role: user.role },
      access_token: accessToken,
      token: accessToken,
      refresh_token: refreshToken,
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Authenticate or register a user via Google ID token.
 * Verifies the token with Google's OAuth2 client, then finds or creates the user.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function googleAuth(req, res, next) {
  const { id_token, tenant_name } = req.body;

  try {
    // Verify Google ID token
    const ticket = await googleClient.verifyIdToken({
      idToken: id_token,
      audience: config.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    const { sub: googleId, email, name } = payload;

    // Try to find existing user by google_id or email
    let userRow;
    const { rows: existingByGoogle } = await db.query(
      'SELECT id, tenant_id, role, is_active FROM users WHERE google_id = $1',
      [googleId]
    );

    if (existingByGoogle.length > 0) {
      userRow = existingByGoogle[0];
    } else {
      const { rows: existingByEmail } = await db.query(
        'SELECT id, tenant_id, role, is_active FROM users WHERE email = $1',
        [email]
      );

      if (existingByEmail.length > 0) {
        // Link Google ID to existing email account
        await db.query('UPDATE users SET google_id = $1 WHERE id = $2', [googleId, existingByEmail[0].id]);
        userRow = existingByEmail[0];
      } else {
        // Create new tenant + admin user
        userRow = await db.withTransaction(async (client) => {
          const tenantId = uuidv4();
          await client.query(
            'INSERT INTO tenants (id, name) VALUES ($1, $2)',
            [tenantId, tenant_name || `${name}'s Business`]
          );

          const userId = uuidv4();
          await client.query(
            `INSERT INTO users (id, tenant_id, email, google_id, role)
             VALUES ($1, $2, $3, $4, 'admin')`,
            [userId, tenantId, email, googleId]
          );

          return { id: userId, tenant_id: tenantId, role: 'admin', is_active: true };
        });
      }
    }

    if (!userRow.is_active) {
      return error(res, 'Account is deactivated', 403);
    }

    const accessToken = generateAccessToken(userRow.id, userRow.tenant_id, userRow.role);
    const refreshToken = generateRefreshToken(userRow.id);
    await storeRefreshToken(userRow.id, refreshToken);

    return success(res, {
      user: { id: userRow.id, tenant_id: userRow.tenant_id, email, role: userRow.role },
      access_token: accessToken,
      token: accessToken,
      refresh_token: refreshToken,
    });
  } catch (err) {
    if (err.message && err.message.includes('Invalid token')) {
      return error(res, 'Invalid Google ID token', 401);
    }
    return next(err);
  }
}

/**
 * Refresh an access token using a valid refresh token.
 * Verifies the refresh token against stored hashes in the database.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function refresh(req, res, next) {
  const { refresh_token } = req.body;

  try {
    if (!refresh_token) {
      return error(res, 'Refresh token required', 400);
    }

    // Verify JWT signature first
    let decoded;
    try {
      decoded = jwt.verify(refresh_token, config.JWT_REFRESH_SECRET);
    } catch (jwtErr) {
      console.log('JWT verify failed in refresh:', jwtErr.message);
      return error(res, 'Invalid or expired refresh token', 401);
    }

    // Get all valid refresh tokens for this user
    const { rows } = await db.query(
      'SELECT id, token_hash FROM refresh_tokens WHERE user_id = $1 AND expires_at > NOW()',
      [decoded.userId]
    );

    console.log(`[Refresh] Found ${rows.length} refresh tokens for user ${decoded.userId}`);

    if (rows.length === 0) {
      console.log('[Refresh] No refresh tokens found in database');
      return error(res, 'Refresh token not found or expired', 401);
    }

    // Find matching token hash
    let matchedTokenId = null;
    const signature = refresh_token.split('.')[2] || refresh_token;
    for (const row of rows) {
      const match = await bcrypt.compare(signature, row.token_hash);
      console.log(`[Refresh] Comparing with ${row.id}, match: ${match}`);
      if (match) {
        matchedTokenId = row.id;
        break;
      }
    }

    if (!matchedTokenId) {
      console.log('[Refresh] No matching token hash found');
      return error(res, 'Invalid refresh token', 401);
    }

    // Get user info
    const { rows: userRows } = await db.query(
      'SELECT id, tenant_id, role, is_active FROM users WHERE id = $1',
      [decoded.userId]
    );

    if (userRows.length === 0 || !userRows[0].is_active) {
      return error(res, 'User not found or deactivated', 401);
    }

    const user = userRows[0];
    const accessToken = generateAccessToken(user.id, user.tenant_id, user.role);

    return success(res, { access_token: accessToken, token: accessToken });
  } catch (err) {
    return next(err);
  }
}

/**
 * Logout by deleting the refresh token from the database.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function logout(req, res, next) {
  const { refresh_token } = req.body;

  try {
    if (!refresh_token) {
      return error(res, 'Refresh token required', 400);
    }

    let decoded;
    try {
      decoded = jwt.verify(refresh_token, config.JWT_REFRESH_SECRET);
    } catch (err) {
      console.log('JWT verify failed in logout:', err.message);
      // Even if token is expired/invalid, attempt cleanup
      return success(res, { message: 'Logged out' });
    }

    const { rows } = await db.query(
      'SELECT id, token_hash FROM refresh_tokens WHERE user_id = $1',
      [decoded.userId]
    );

    console.log(`Found ${rows.length} refresh tokens for user ${decoded.userId}`);

    let matched = false;
    const signature = refresh_token.split('.')[2] || refresh_token;
    for (const row of rows) {
      const match = await bcrypt.compare(signature, row.token_hash);
      console.log(`Comparing token, match: ${match}`);
      if (match) {
        const delRes = await db.query('DELETE FROM refresh_tokens WHERE id = $1', [row.id]);
        console.log(`Deleted refresh token row ${row.id}, rows affected: ${delRes.rowCount}`);
        matched = true;
        break;
      }
    }

    if (!matched) {
      console.log('No matching refresh token found in database to delete');
    }

    return success(res, { message: 'Logged out successfully' });
  } catch (err) {
    return next(err);
  }
}

module.exports = { register, login, sendOtp, verifyOtp, googleAuth, refresh, logout };
