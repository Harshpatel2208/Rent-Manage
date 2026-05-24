'use strict';

const db = require('../config/db');
const { success } = require('../utils/responseHelper');

/**
 * Get a comprehensive dashboard summary for the tenant.
 * Uses a single SQL query with CTEs for efficiency.
 * Returns all key financial metrics for the current calendar month.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getDashboard(req, res, next) {
  const { tenantId } = req;

  try {
    const { rows } = await db.query(
      `WITH
        -- Current month boundaries
        month_bounds AS (
          SELECT
            DATE_TRUNC('month', CURRENT_DATE) AS month_start,
            (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE AS month_end
        ),

        -- Total active capital (sum of principal for all active loans)
        active_capital AS (
          SELECT COALESCE(SUM(principal), '0.0000') AS total_active_capital
          FROM loans
          WHERE tenant_id = $1 AND status = 'active'
        ),

        -- Expected monthly interest income (pending schedule rows for current month)
        monthly_interest AS (
          SELECT COALESCE(SUM(lis.expected_amount), '0.0000') AS expected_monthly_interest
          FROM loan_interest_schedule lis
          JOIN month_bounds mb ON lis.cycle_month = mb.month_start
          WHERE lis.tenant_id = $1 AND lis.status = 'pending'
        ),

        -- Expected monthly rent (amount_due for current month's rent payment rows)
        monthly_rent AS (
          SELECT COALESCE(SUM(rp.amount_due), '0.0000') AS expected_monthly_rent
          FROM rent_payments rp
          JOIN month_bounds mb ON rp.cycle_month = mb.month_start
          WHERE rp.tenant_id = $1
        ),

        -- Total expenses this calendar month
        monthly_expenses AS (
          SELECT COALESCE(SUM(amount), '0.0000') AS total_expenses_this_month
          FROM expenses
          WHERE tenant_id = $1
            AND expense_date >= (SELECT month_start FROM month_bounds)
            AND expense_date <= (SELECT month_end FROM month_bounds)
        ),

        -- Active loans count
        loan_count AS (
          SELECT COUNT(*) AS active_loans_count
          FROM loans
          WHERE tenant_id = $1 AND status = 'active'
        ),

        -- Active rental tenants count
        tenant_count AS (
          SELECT COUNT(*) AS active_tenants_count
          FROM rental_tenants
          WHERE tenant_id = $1 AND is_active = true
        ),

        -- Pending sync conflicts
        conflict_count AS (
          SELECT COUNT(*) AS pending_conflicts_count
          FROM sync_conflicts
          WHERE tenant_id = $1 AND status = 'pending'
        )

      SELECT
        ac.total_active_capital,
        mi.expected_monthly_interest,
        mr.expected_monthly_rent,
        (mi.expected_monthly_interest::NUMERIC + mr.expected_monthly_rent::NUMERIC) AS expected_monthly_income,
        me.total_expenses_this_month,
        lc.active_loans_count::INT AS active_loans_count,
        tc.active_tenants_count::INT AS active_tenants_count,
        cc.pending_conflicts_count::INT AS pending_conflicts_count
      FROM active_capital ac, monthly_interest mi, monthly_rent mr,
           monthly_expenses me, loan_count lc, tenant_count tc, conflict_count cc`,
      [tenantId]
    );

    const dashboard = rows[0];

    return success(res, {
      total_active_capital: dashboard.total_active_capital,
      expected_monthly_interest: dashboard.expected_monthly_interest,
      expected_monthly_rent: dashboard.expected_monthly_rent,
      expected_monthly_income: dashboard.expected_monthly_income,
      total_expenses_this_month: dashboard.total_expenses_this_month,
      active_loans_count: dashboard.active_loans_count,
      active_tenants_count: dashboard.active_tenants_count,
      pending_conflicts_count: dashboard.pending_conflicts_count,
    });
  } catch (err) {
    return next(err);
  }
}

module.exports = { getDashboard };
