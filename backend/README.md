# Rent Manager — Backend API

Multi-Tenant Mobile Money Management App backend built with **Node.js + Express + PostgreSQL**.

## Features

- 🔐 Multi-tenant JWT authentication (Email/Password, OTP via Twilio, Google OAuth)
- 🏦 Loan management with auto-generated interest schedules
- 🏠 Rental management with shop units, tenant ledgers, and partial payments
- 💸 Expense tracking with category filters
- 📊 Single-query dashboard with financial KPIs
- 🔄 Offline-first batch sync with conflict resolution
- 📄 PDF & CSV report exports
- 🔔 FCM push notifications with monthly reminders
- ⏰ Automated cron jobs for interest schedule and notifications
- 🛡️ Helmet, CORS, rate limiting, and row-level tenant isolation on every query

---

## Prerequisites

- **Node.js** ≥ 18.0.0
- **PostgreSQL** ≥ 14
- **Twilio** account (for OTP SMS)
- **Google Cloud** project with OAuth 2.0 Client ID
- **Firebase** project with Admin SDK service account

---

## Setup

### 1. Install PostgreSQL

Download and install PostgreSQL from https://www.postgresql.org/download/

Create the database:
```bash
psql -U postgres
CREATE DATABASE rent_manager;
\q
```

### 2. Clone & Install Dependencies

```bash
cd backend
npm install
```

### 3. Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your actual values:

| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string |
| `JWT_SECRET` | ≥32 char random string for access tokens |
| `JWT_REFRESH_SECRET` | ≥32 char random string for refresh tokens |
| `JWT_EXPIRES_IN` | Access token TTL (e.g. `15m`) |
| `REFRESH_EXPIRES_IN` | Refresh token TTL (e.g. `30d`) |
| `TWILIO_ACCOUNT_SID` | From Twilio Console |
| `TWILIO_AUTH_TOKEN` | From Twilio Console |
| `TWILIO_PHONE_NUMBER` | Your Twilio phone number (e.g. `+1234567890`) |
| `GOOGLE_CLIENT_ID` | OAuth 2.0 Client ID from Google Cloud Console |
| `FIREBASE_SERVICE_ACCOUNT_KEY` | Base64-encoded Firebase Admin SDK JSON |

**Encode Firebase service account:**
```bash
# Linux/Mac
base64 -i serviceAccountKey.json | tr -d '\n'

# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('serviceAccountKey.json'))
```

### 4. Run Database Migration

```bash
npm run migrate
```

This creates all 14 tables with proper indexes and triggers.

### 5. Start the Server

```bash
# Development (with auto-reload)
npm run dev

# Production
npm start
```

Server starts on `http://localhost:5000`

---

## API Overview

Base URL: `http://localhost:5000/api/v1`

### Authentication
| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/register` | Register tenant + admin user |
| POST | `/auth/login` | Email/phone + password login |
| POST | `/auth/otp/send` | Send OTP via SMS |
| POST | `/auth/otp/verify` | Verify OTP, get tokens |
| POST | `/auth/google` | Google ID token login |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/logout` | Invalidate refresh token |

### Loans
| Method | Endpoint | Description |
|---|---|---|
| GET | `/loans` | List all loans |
| POST | `/loans` | Create loan + auto-schedule |
| GET | `/loans/:id` | Loan detail + payments + schedule |
| POST | `/loans/:id/payments` | Record payment |
| GET | `/loans/:id/schedule` | Interest schedule |

### Rental
| Method | Endpoint | Description |
|---|---|---|
| GET | `/rental/units` | List shop units |
| POST | `/rental/units` | Create shop unit |
| GET | `/rental/tenants` | List rental tenants |
| POST | `/rental/tenants` | Create tenant + month's rent row |
| GET | `/rental/tenants/:id` | Tenant ledger + outstanding |
| POST | `/rental/payments` | Record rent payment |

### Dashboard
| Method | Endpoint | Description |
|---|---|---|
| GET | `/dashboard` | All KPIs in one query |

### Expenses
| Method | Endpoint | Description |
|---|---|---|
| GET | `/expenses` | List with filters |
| POST | `/expenses` | Create expense |

### Sync (Offline-First)
| Method | Endpoint | Description |
|---|---|---|
| POST | `/sync/batch` | Batch sync operations |
| GET | `/sync/conflicts` | List conflicts |
| PATCH | `/sync/conflicts/:id` | Resolve/dismiss conflict |

### Reports
| Method | Endpoint | Description |
|---|---|---|
| GET | `/reports/monthly` | Monthly aggregate report |
| GET | `/reports/export/pdf` | Download PDF report |
| GET | `/reports/export/csv` | Download CSV report |

---

## Architecture Notes

### Decimal Precision
All monetary values use `DECIMAL(19,4)` in PostgreSQL. The `pg` driver is configured to return `NUMERIC` types as **strings** (not JavaScript floats) to avoid floating-point drift. Use `src/utils/decimal.js` helpers for arithmetic.

### Tenant Isolation
Every database query includes `WHERE tenant_id = $N` using `req.tenantId` injected by `src/middleware/tenant.js`. Never query without this filter.

### Idempotency
Write endpoints (`loan_payments`, `rent_payments`, `expenses`) require a `idempotency_key` (UUID v4). Duplicate requests return the existing record instead of creating duplicates.

### Cron Jobs
- **1st of every month @ 00:00 UTC**: Generate next month's interest schedule for all active loans
- **25th of every month @ 09:00 UTC**: Send payment reminder push notifications

---

## Running Tests

```bash
npm test
```

---

## Project Structure

```
backend/
├── server.js                          # Express app entry point
├── package.json
├── .env.example
└── src/
    ├── config/
    │   ├── db.js                      # PostgreSQL pool
    │   ├── env.js                     # Joi-validated config
    │   └── firebaseAdmin.js           # Firebase Admin SDK
    ├── controllers/
    │   ├── authController.js
    │   ├── loanController.js
    │   ├── rentalController.js
    │   ├── expenseController.js
    │   ├── dashboardController.js
    │   ├── syncController.js
    │   ├── reportController.js
    │   └── userController.js
    ├── middleware/
    │   ├── auth.js                    # JWT verification
    │   ├── tenant.js                  # Tenant isolation
    │   ├── idempotency.js             # Idempotency checks
    │   ├── error.js                   # Global error handler
    │   └── validate.js                # Joi validation factory
    ├── migrations/
    │   ├── 001_initial_schema.sql     # All 14 tables
    │   └── run.js                     # Migration runner
    ├── routes/
    │   ├── index.js                   # Route aggregator
    │   ├── auth.js
    │   ├── users.js
    │   ├── loans.js
    │   ├── rental.js
    │   ├── expenses.js
    │   ├── dashboard.js
    │   ├── sync.js
    │   └── reports.js
    ├── services/
    │   ├── interestScheduleService.js # Cron + schedule generation
    │   └── notificationService.js    # FCM push notifications
    └── utils/
        ├── decimal.js                 # Decimal arithmetic helpers
        ├── dateUtils.js               # Billing cycle date helpers
        └── responseHelper.js          # Consistent JSON responses
```
