'use strict';

require('dotenv').config();

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const config = require('./src/config/env');
const routes = require('./src/routes/index');
const errorHandler = require('./src/middleware/error');
const { startCron } = require('./src/services/interestScheduleService');
const { startNotificationCron } = require('./src/services/notificationService');

const app = express();

// ─── Security Middleware ──────────────────────────────────────────────────────
app.use(helmet());

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (like mobile apps, curl)
      if (!origin) return callback(null, true);
      
      if (config.NODE_ENV !== 'production') {
        return callback(null, true);
      }
      
      const origins = config.ALLOWED_ORIGINS.split(',').map((o) => o.trim());
      if (origins.includes('*') || origins.includes(origin)) {
        return callback(null, true);
      }
      
      callback(new Error('Not allowed by CORS'));
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Idempotency-Key'],
    credentials: true,
  })
);

const limiter = rateLimit({
  windowMs: config.RATE_LIMIT_WINDOW_MS,
  max: config.RATE_LIMIT_MAX_REQUESTS,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: 'Too many requests from this IP, please try again later.',
  },
});

app.use(limiter);

// ─── Body Parsing ─────────────────────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ─── Health Check ─────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => {
  res.json({ success: true, data: { status: 'ok', timestamp: new Date().toISOString() } });
});

// ─── API Routes ───────────────────────────────────────────────────────────────
app.use('/api/v1', routes);

// ─── 404 Handler ─────────────────────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ success: false, error: 'Route not found' });
});

// ─── Global Error Handler ─────────────────────────────────────────────────────
app.use(errorHandler);

// ─── Start Server (only when run directly, not when imported by tests) ────────
const PORT = config.PORT || 5000;

if (require.main === module) {
  const server = app.listen(PORT, () => {
    console.log(`[Server] Running on port ${PORT} in ${config.NODE_ENV} mode`);

    // Start cron jobs
    if (config.NODE_ENV !== 'test') {
      startCron();
      startNotificationCron();
      console.log('[Cron] Interest schedule and notification cron jobs started');
    }
  });

  // Graceful shutdown
  process.on('SIGTERM', () => {
    console.log('[Server] SIGTERM received, shutting down gracefully');
    server.close(() => {
      console.log('[Server] Process terminated');
      process.exit(0);
    });
  });

  process.on('unhandledRejection', (reason, promise) => {
    console.error('[Server] Unhandled Rejection at:', promise, 'reason:', reason);
  });
}

module.exports = app;
