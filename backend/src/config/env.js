'use strict';

require('dotenv').config();

const Joi = require('joi');

const envSchema = Joi.object({
  // Server
  PORT: Joi.number().default(5000),
  NODE_ENV: Joi.string().valid('development', 'production', 'test').default('development'),
  ALLOWED_ORIGINS: Joi.string().default('*'),

  // Database
  DATABASE_URL: Joi.string().uri().required(),

  // JWT
  JWT_SECRET: Joi.string().min(32).required(),
  JWT_REFRESH_SECRET: Joi.string().min(32).required(),
  JWT_EXPIRES_IN: Joi.string().default('15m'),
  REFRESH_EXPIRES_IN: Joi.string().default('30d'),

  // Twilio
  TWILIO_ACCOUNT_SID: Joi.string().required(),
  TWILIO_AUTH_TOKEN: Joi.string().required(),
  TWILIO_PHONE_NUMBER: Joi.string().required(),

  // Google OAuth
  GOOGLE_CLIENT_ID: Joi.string().required(),

  // Firebase
  FIREBASE_SERVICE_ACCOUNT_KEY: Joi.string().required(),

  // Rate Limiting
  RATE_LIMIT_WINDOW_MS: Joi.number().default(900000),
  RATE_LIMIT_MAX_REQUESTS: Joi.number().default(100),
}).unknown(true);

const { error, value: envVars } = envSchema.validate(process.env, { abortEarly: false });

if (error) {
  const missing = error.details.map((d) => d.message).join('\n  ');
  throw new Error(`[Config] Environment validation failed:\n  ${missing}`);
}

const config = {
  PORT: envVars.PORT,
  NODE_ENV: envVars.NODE_ENV,
  ALLOWED_ORIGINS: envVars.ALLOWED_ORIGINS,
  DATABASE_URL: envVars.DATABASE_URL,
  JWT_SECRET: envVars.JWT_SECRET,
  JWT_REFRESH_SECRET: envVars.JWT_REFRESH_SECRET,
  JWT_EXPIRES_IN: envVars.JWT_EXPIRES_IN,
  REFRESH_EXPIRES_IN: envVars.REFRESH_EXPIRES_IN,
  TWILIO_ACCOUNT_SID: envVars.TWILIO_ACCOUNT_SID,
  TWILIO_AUTH_TOKEN: envVars.TWILIO_AUTH_TOKEN,
  TWILIO_PHONE_NUMBER: envVars.TWILIO_PHONE_NUMBER,
  GOOGLE_CLIENT_ID: envVars.GOOGLE_CLIENT_ID,
  FIREBASE_SERVICE_ACCOUNT_KEY: envVars.FIREBASE_SERVICE_ACCOUNT_KEY,
  RATE_LIMIT_WINDOW_MS: envVars.RATE_LIMIT_WINDOW_MS,
  RATE_LIMIT_MAX_REQUESTS: envVars.RATE_LIMIT_MAX_REQUESTS,
};

module.exports = config;
