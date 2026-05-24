'use strict';

const cron = require('node-cron');
const { v4: uuidv4 } = require('uuid');
const db = require('../config/db');
const { multiplyDecimal } = require('../utils/decimal');
const { getNextCycleMonth, formatMonthKey, getCurrentCycleMonth } = require('../utils/dateUtils');

/**
 * Generate the next month's interest schedule row for all active loans of a given tenant.
 * Inserts a new loan_interest_schedule row for each active loan if one doesn't exist
 * for the next cycle month.
 *
 * @param {string} tenantId - The tenant UUID to process
 * @returns {Promise<{ processed: number, inserted: number }>}
 */
async function generateNextMonthSchedule(tenantId) {
  const { rows: activeLoans } = await db.query(
    `SELECT id, principal, interest_rate, first_cycle_date
     FROM loans
     WHERE tenant_id = $1 AND status = 'active'`,
    [tenantId]
  );

  let processed = 0;
  let inserted = 0;

  for (const loan of activeLoans) {
    try {
      // Determine the next cycle month: find the latest schedule row and add 1 month
      const { rows: latestRows } = await db.query(
        `SELECT cycle_month FROM loan_interest_schedule
         WHERE loan_id = $1
         ORDER BY cycle_month DESC LIMIT 1`,
        [loan.id]
      );

      let nextCycleMonth;
      if (latestRows.length > 0) {
        nextCycleMonth = formatMonthKey(getNextCycleMonth(latestRows[0].cycle_month));
      } else {
        // No schedule yet — start from first_cycle_date
        nextCycleMonth = formatMonthKey(new Date(loan.first_cycle_date));
      }

      const expectedAmount = multiplyDecimal(loan.principal, loan.interest_rate);

      // Insert only if not already present (ON CONFLICT DO NOTHING)
      const result = await db.query(
        `INSERT INTO loan_interest_schedule (id, loan_id, tenant_id, cycle_month, expected_amount)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (loan_id, cycle_month) DO NOTHING`,
        [uuidv4(), loan.id, tenantId, nextCycleMonth, expectedAmount]
      );

      if (result.rowCount > 0) {
        inserted++;
      }

      processed++;
    } catch (err) {
      console.error(`[InterestSchedule] Failed to generate schedule for loan ${loan.id}:`, err.message);
    }
  }

  return { processed, inserted };
}

/**
 * Generate the current month's rent payment row for all active rental tenants of a given tenant.
 * Inserts a new rent_payments row if one doesn't exist for the current cycle month.
 *
 * @param {string} tenantId - The tenant UUID to process
 * @returns {Promise<{ processed: number, inserted: number }>}
 */
async function generateNextMonthRentPayments(tenantId) {
  const { rows: activeTenants } = await db.query(
    `SELECT id, rent_amount
     FROM rental_tenants
     WHERE tenant_id = $1 AND is_active = true`,
    [tenantId]
  );

  let processed = 0;
  let inserted = 0;
  const currentCycleMonth = formatMonthKey(getCurrentCycleMonth());

  for (const tenant of activeTenants) {
    try {
      const result = await db.query(
        `INSERT INTO rent_payments (id, rental_tenant_id, tenant_id, cycle_month, amount_due, amount_paid, status, idempotency_key)
         VALUES ($1, $2, $3, $4, $5, 0, 'pending', $6)
         ON CONFLICT (rental_tenant_id, cycle_month) DO NOTHING`,
        [uuidv4(), tenant.id, tenantId, currentCycleMonth, tenant.rent_amount, uuidv4()]
      );

      if (result.rowCount > 0) {
        inserted++;
      }

      processed++;
    } catch (err) {
      console.error(`[RentSchedule] Failed to generate rent payment for tenant ${tenant.id}:`, err.message);
    }
  }

  return { processed, inserted };
}

/**
 * Run interest schedule and rent payment generation for ALL tenants in the system.
 * Called by cron on the 1st of every month.
 *
 * @returns {Promise<void>}
 */
async function generateScheduleForAllTenants() {
  console.log('[BillingSchedule] Starting monthly billing schedule generation for all tenants...');

  try {
    const { rows: tenants } = await db.query('SELECT id FROM tenants');

    let totalLoansProcessed = 0;
    let totalLoansInserted = 0;
    let totalRentProcessed = 0;
    let totalRentInserted = 0;

    for (const tenant of tenants) {
      // 1. Interest Schedule
      const loanResult = await generateNextMonthSchedule(tenant.id);
      totalLoansProcessed += loanResult.processed;
      totalLoansInserted += loanResult.inserted;

      // 2. Rent Payments
      const rentResult = await generateNextMonthRentPayments(tenant.id);
      totalRentProcessed += rentResult.processed;
      totalRentInserted += rentResult.inserted;
    }

    console.log(
      `[BillingSchedule] Completed. Tenants: ${tenants.length}. ` +
      `Loans: processed ${totalLoansProcessed}, inserted ${totalLoansInserted}. ` +
      `Rent: processed ${totalRentProcessed}, inserted ${totalRentInserted}.`
    );
  } catch (err) {
    console.error('[BillingSchedule] Error during billing generation:', err.message);
  }
}

/**
 * Start the monthly billing schedule cron job.
 * Runs at midnight on the 1st of every month (UTC).
 * Schedule: '0 0 1 * *'
 */
function startCron() {
  cron.schedule('0 0 1 * *', generateScheduleForAllTenants, {
    scheduled: true,
    timezone: 'UTC',
  });

  console.log('[BillingSchedule] Cron scheduled: 1st of every month at 00:00 UTC');
}

module.exports = {
  generateNextMonthSchedule,
  generateNextMonthRentPayments,
  generateScheduleForAllTenants,
  startCron,
};

