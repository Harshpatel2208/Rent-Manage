'use strict';

const admin = require('firebase-admin');
const config = require('./env');

let firebaseApp = null;

/**
 * Initialize and return the Firebase Admin app instance.
 * Decodes the base64-encoded service account JSON from the environment.
 * @returns {import('firebase-admin').app.App} Firebase Admin app
 */
function getFirebaseApp() {
  if (firebaseApp) return firebaseApp;

  try {
    const serviceAccountJson = Buffer.from(config.FIREBASE_SERVICE_ACCOUNT_KEY, 'base64').toString('utf8');
    const serviceAccount = JSON.parse(serviceAccountJson);

    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    console.log('[Firebase] Admin SDK initialized successfully');
    return firebaseApp;
  } catch (err) {
    console.error('[Firebase] Failed to initialize Admin SDK:', err.message);
    throw new Error(`Firebase Admin initialization failed: ${err.message}`);
  }
}

/**
 * Get the Firebase Admin messaging instance.
 * @returns {import('firebase-admin').messaging.Messaging} Firebase Messaging
 */
function getMessaging() {
  const app = getFirebaseApp();
  return admin.messaging(app);
}

module.exports = { getFirebaseApp, getMessaging };
