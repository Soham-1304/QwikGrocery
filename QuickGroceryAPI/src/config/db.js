import { createRequire } from 'node:module';
import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, Timestamp, getFirestore } from 'firebase-admin/firestore';

const projectId = process.env.FIREBASE_PROJECT_ID;
const require = createRequire(import.meta.url);
const serviceAccountKey = require('../../secrets/ServiceAccountKey.json');

if (getApps().length === 0) {
  initializeApp({ credential: cert(serviceAccountKey), ...(projectId ? { projectId } : {}) });
}

export const auth = getAuth();
export const db = getFirestore();
export { FieldValue, Timestamp };
