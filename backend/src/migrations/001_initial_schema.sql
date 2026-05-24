-- ─────────────────────────────────────────────────────────────────────────────
-- Migration 001: Initial Schema for Multi-Tenant Mobile Money Management App
-- All monetary columns use DECIMAL(19,4) for precision
-- All tables have tenant_id for row-level isolation
-- ─────────────────────────────────────────────────────────────────────────────

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─── ENUMS ───────────────────────────────────────────────────────────────────
CREATE TYPE user_role AS ENUM ('admin', 'viewer');
CREATE TYPE loan_status AS ENUM ('active', 'closed');
CREATE TYPE payment_type AS ENUM ('interest', 'principal');
CREATE TYPE schedule_status AS ENUM ('pending', 'collected', 'waived');
CREATE TYPE rent_payment_status AS ENUM ('paid', 'partially_paid', 'pending');
CREATE TYPE expense_category AS ENUM ('food', 'maintenance', 'travel', 'business', 'other');
CREATE TYPE conflict_status AS ENUM ('pending', 'resolved', 'dismissed');

-- ─── TENANTS ─────────────────────────────────────────────────────────────────
CREATE TABLE tenants (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── USERS ───────────────────────────────────────────────────────────────────
CREATE TABLE users (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id      UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    email          VARCHAR(255) UNIQUE,
    phone          VARCHAR(20) UNIQUE,
    google_id      VARCHAR(255) UNIQUE,
    password_hash  TEXT,
    role           user_role NOT NULL DEFAULT 'viewer',
    is_active      BOOLEAN NOT NULL DEFAULT true,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT users_identity_check CHECK (
        email IS NOT NULL OR phone IS NOT NULL OR google_id IS NOT NULL
    )
);

CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_phone ON users(phone) WHERE phone IS NOT NULL;
CREATE INDEX idx_users_google_id ON users(google_id) WHERE google_id IS NOT NULL;

-- ─── REFRESH TOKENS ──────────────────────────────────────────────────────────
CREATE TABLE refresh_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  TEXT NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token_hash ON refresh_tokens(token_hash);

-- ─── OTP CODES ───────────────────────────────────────────────────────────────
CREATE TABLE otp_codes (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    code_hash   TEXT NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    used        BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_otp_codes_user_id ON otp_codes(user_id);

-- ─── BORROWERS ───────────────────────────────────────────────────────────────
CREATE TABLE borrowers (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id   UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    full_name   VARCHAR(255) NOT NULL,
    phone       VARCHAR(20),
    address     TEXT,
    notes       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_borrowers_tenant_id ON borrowers(tenant_id);

-- ─── LOANS ───────────────────────────────────────────────────────────────────
CREATE TABLE loans (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id         UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    borrower_id       UUID NOT NULL REFERENCES borrowers(id) ON DELETE RESTRICT,
    principal         DECIMAL(19,4) NOT NULL CHECK (principal > 0),
    interest_rate     DECIMAL(5,4) NOT NULL DEFAULT 0.0100,
    status            loan_status NOT NULL DEFAULT 'active',
    registered_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    first_cycle_date  DATE,
    closed_at         TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_loans_tenant_id ON loans(tenant_id);
CREATE INDEX idx_loans_borrower_id ON loans(borrower_id);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_loans_tenant_status ON loans(tenant_id, status);

-- ─── LOAN PAYMENTS ───────────────────────────────────────────────────────────
CREATE TABLE loan_payments (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    loan_id          UUID NOT NULL REFERENCES loans(id) ON DELETE RESTRICT,
    tenant_id        UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    amount           DECIMAL(19,4) NOT NULL CHECK (amount > 0),
    payment_date     DATE NOT NULL,
    type             payment_type NOT NULL,
    idempotency_key  UUID NOT NULL UNIQUE,
    synced_at        TIMESTAMPTZ,
    notes            TEXT,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_loan_payments_loan_id ON loan_payments(loan_id);
CREATE INDEX idx_loan_payments_tenant_id ON loan_payments(tenant_id);
CREATE INDEX idx_loan_payments_payment_date ON loan_payments(payment_date);

-- ─── LOAN INTEREST SCHEDULE ──────────────────────────────────────────────────
CREATE TABLE loan_interest_schedule (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    loan_id          UUID NOT NULL REFERENCES loans(id) ON DELETE CASCADE,
    tenant_id        UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    cycle_month      DATE NOT NULL,
    expected_amount  DECIMAL(19,4) NOT NULL,
    status           schedule_status NOT NULL DEFAULT 'pending',
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (loan_id, cycle_month)
);

CREATE INDEX idx_loan_interest_schedule_loan_id ON loan_interest_schedule(loan_id);
CREATE INDEX idx_loan_interest_schedule_tenant_id ON loan_interest_schedule(tenant_id);
CREATE INDEX idx_loan_interest_schedule_cycle_month ON loan_interest_schedule(cycle_month);
CREATE INDEX idx_loan_interest_schedule_status ON loan_interest_schedule(status);

-- ─── SHOP UNITS ──────────────────────────────────────────────────────────────
CREATE TABLE shop_units (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id   UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    unit_name   VARCHAR(255) NOT NULL,
    address     TEXT,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shop_units_tenant_id ON shop_units(tenant_id);

-- ─── RENTAL TENANTS ──────────────────────────────────────────────────────────
CREATE TABLE rental_tenants (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id    UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    unit_id      UUID REFERENCES shop_units(id) ON DELETE SET NULL,
    full_name    VARCHAR(255) NOT NULL,
    phone        VARCHAR(20),
    rent_amount  DECIMAL(19,4) NOT NULL CHECK (rent_amount > 0),
    lease_start  DATE NOT NULL,
    lease_end    DATE,
    is_active    BOOLEAN NOT NULL DEFAULT true,
    notes        TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rental_tenants_tenant_id ON rental_tenants(tenant_id);
CREATE INDEX idx_rental_tenants_unit_id ON rental_tenants(unit_id);
CREATE INDEX idx_rental_tenants_is_active ON rental_tenants(is_active);

-- ─── RENT PAYMENTS ───────────────────────────────────────────────────────────
CREATE TABLE rent_payments (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rental_tenant_id   UUID NOT NULL REFERENCES rental_tenants(id) ON DELETE RESTRICT,
    tenant_id          UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    cycle_month        DATE NOT NULL,
    amount_due         DECIMAL(19,4) NOT NULL,
    amount_paid        DECIMAL(19,4) NOT NULL DEFAULT 0,
    remaining_balance  DECIMAL(19,4) GENERATED ALWAYS AS (amount_due - amount_paid) STORED,
    status             rent_payment_status NOT NULL DEFAULT 'pending',
    idempotency_key    UUID NOT NULL UNIQUE,
    synced_at          TIMESTAMPTZ,
    notes              TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (rental_tenant_id, cycle_month)
);

CREATE INDEX idx_rent_payments_rental_tenant_id ON rent_payments(rental_tenant_id);
CREATE INDEX idx_rent_payments_tenant_id ON rent_payments(tenant_id);
CREATE INDEX idx_rent_payments_cycle_month ON rent_payments(cycle_month);
CREATE INDEX idx_rent_payments_status ON rent_payments(status);

-- ─── EXPENSES ────────────────────────────────────────────────────────────────
CREATE TABLE expenses (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id        UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    amount           DECIMAL(19,4) NOT NULL CHECK (amount > 0),
    category         expense_category NOT NULL,
    expense_date     DATE NOT NULL,
    description      VARCHAR(255),
    idempotency_key  UUID NOT NULL UNIQUE,
    synced_at        TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_expenses_tenant_id ON expenses(tenant_id);
CREATE INDEX idx_expenses_expense_date ON expenses(expense_date);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_tenant_date ON expenses(tenant_id, expense_date);

-- ─── SYNC CONFLICTS ──────────────────────────────────────────────────────────
CREATE TABLE sync_conflicts (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id        UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entity_type      VARCHAR(50) NOT NULL,
    entity_id        UUID,
    local_payload    JSONB NOT NULL,
    conflict_reason  TEXT NOT NULL,
    status           conflict_status NOT NULL DEFAULT 'pending',
    resolved_at      TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sync_conflicts_tenant_id ON sync_conflicts(tenant_id);
CREATE INDEX idx_sync_conflicts_user_id ON sync_conflicts(user_id);
CREATE INDEX idx_sync_conflicts_status ON sync_conflicts(status);
CREATE INDEX idx_sync_conflicts_entity_type ON sync_conflicts(entity_type);

-- ─── FCM TOKENS ──────────────────────────────────────────────────────────────
CREATE TABLE fcm_tokens (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tenant_id  UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    token      TEXT NOT NULL,
    device_id  VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, device_id)
);

CREATE INDEX idx_fcm_tokens_user_id ON fcm_tokens(user_id);
CREATE INDEX idx_fcm_tokens_tenant_id ON fcm_tokens(tenant_id);

-- ─── TRIGGER: Auto-update updated_at columns ─────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_borrowers_updated_at
    BEFORE UPDATE ON borrowers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_shop_units_updated_at
    BEFORE UPDATE ON shop_units
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_rental_tenants_updated_at
    BEFORE UPDATE ON rental_tenants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_rent_payments_updated_at
    BEFORE UPDATE ON rent_payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_expenses_updated_at
    BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_fcm_tokens_updated_at
    BEFORE UPDATE ON fcm_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
