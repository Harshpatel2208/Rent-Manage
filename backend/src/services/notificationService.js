'use strict';

const cron = require('node-cron');
const db = require('../config/db');
const { getMessaging } = require('../config/firebaseAdmin');
const { formatMonthLabel, getCurrentCycleMonth, formatMonthKey } = require('../utils/dateUtils');

/**
 * Send a push notification to a specific user via FCM.
 * Fetches all active FCM tokens for the user and sends a multicast message.
 *
 * @param {string} userId - UUID of the user to notify
 * @param {string} title - Notification title
 * @param {string} body - Notification body text
 * @param {object} [data={}] - Optional key/value payload for the notification
 * @returns {Promise<{ successCount: number, failureCount: number }>}
 */
async function sendPushNotification(userId, title, body, data = {}) {
  try {
    const { rows: tokenRows } = await db.query(
      'SELECT token FROM fcm_tokens WHERE user_id = $1',
      [userId]
    );

    if (tokenRows.length === 0) {
      console.log(`[Notification] No FCM tokens for user ${userId}`);
      return { successCount: 0, failureCount: 0 };
    }

    const tokens = tokenRows.map((r) => r.token);
    const messaging = getMessaging();

    const message = {
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
      tokens,
    };

    const response = await messaging.sendEachForMulticast(message);

    // Clean up invalid tokens
    const invalidTokenIndices = [];
    response.responses.forEach((resp, idx) => {
      if (
        !resp.success &&
        (resp.error?.code === 'messaging/invalid-registration-token' ||
          resp.error?.code === 'messaging/registration-token-not-registered')
      ) {
        invalidTokenIndices.push(idx);
      }
    });

    if (invalidTokenIndices.length > 0) {
      const invalidTokens = invalidTokenIndices.map((i) => tokens[i]);
      for (const token of invalidTokens) {
        await db.query('DELETE FROM fcm_tokens WHERE token = $1', [token]).catch(() => {});
      }
      console.log(`[Notification] Removed ${invalidTokens.length} invalid FCM tokens for user ${userId}`);
    }

    console.log(
      `[Notification] Sent to user ${userId}: ${response.successCount} success, ${response.failureCount} failed`
    );

    return { successCount: response.successCount, failureCount: response.failureCount };
  } catch (err) {
    console.error('[Notification] sendPushNotification error:', err.message);
    return { successCount: 0, failureCount: 0 };
  }
}

/**
 * Send monthly due reminders to all active tenant users.
 * Notifies about upcoming rent and interest payments.
 * Called by cron on the 25th of each month.
 *
 * @returns {Promise<void>}
 */
async function sendMonthlyReminders() {
  console.log('[Notification] Starting monthly reminder notifications...');

  const currentMonth = formatMonthKey(getCurrentCycleMonth());
  const monthLabel = formatMonthLabel(new Date(currentMonth));

  try {
    // Get all tenants with active loans or rental tenants
    const { rows: tenants } = await db.query('SELECT id, name FROM tenants');

    for (const tenant of tenants) {
      try {
        // Get all admin users for this tenant with FCM tokens
        const { rows: users } = await db.query(
          `SELECT DISTINCT u.id
           FROM users u
           JOIN fcm_tokens ft ON ft.user_id = u.id
           WHERE u.tenant_id = $1 AND u.is_active = true AND u.role = 'admin'`,
          [tenant.id]
        );

        if (users.length === 0) continue;

        // Check for pending rent payments this month
        const { rows: pendingRent } = await db.query(
          `SELECT COUNT(*) AS count, COALESCE(SUM(remaining_balance), '0') AS total_due
           FROM rent_payments
           WHERE tenant_id = $1 AND cycle_month = $2 AND status != 'paid'`,
          [tenant.id, currentMonth]
        );

        // Check for pending interest schedule this month
        const { rows: pendingInterest } = await db.query(
          `SELECT COUNT(*) AS count, COALESCE(SUM(expected_amount), '0') AS total_due
           FROM loan_interest_schedule
           WHERE tenant_id = $1 AND cycle_month = $2 AND status = 'pending'`,
          [tenant.id, currentMonth]
        );

        const rentCount = parseInt(pendingRent[0].count, 10);
        const interestCount = parseInt(pendingInterest[0].count, 10);

        if (rentCount === 0 && interestCount === 0) continue;

        let notificationBody = `Reminders for ${monthLabel}:\n`;
        if (rentCount > 0) {
          notificationBody += `• ${rentCount} rent payment(s) pending — ₹${pendingRent[0].total_due}\n`;
        }
        if (interestCount > 0) {
          notificationBody += `• ${interestCount} interest payment(s) pending — ₹${pendingInterest[0].total_due}`;
        }

        for (const user of users) {
          await sendPushNotification(
            user.id,
            '📅 Payment Reminder',
            notificationBody.trim(),
            { type: 'monthly_reminder', month: currentMonth }
          );
        }
      } catch (tenantErr) {
        console.error(`[Notification] Error processing tenant ${tenant.id}:`, tenantErr.message);
      }
    }

    console.log('[Notification] Monthly reminders completed');
  } catch (err) {
    console.error('[Notification] sendMonthlyReminders error:', err.message);
  }
}

/**
 * Start the notification cron jobs.
 * - 25th of every month at 09:00 UTC: send monthly due reminders
 */
function startNotificationCron() {
  cron.schedule('0 9 25 * *', sendMonthlyReminders, {
    scheduled: true,
    timezone: 'UTC',
  });

  console.log('[Notification] Cron scheduled: 25th of every month at 09:00 UTC');
}

module.exports = { sendPushNotification, sendMonthlyReminders, startNotificationCron };
