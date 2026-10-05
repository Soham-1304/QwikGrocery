import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, Timestamp, getFirestore } from 'firebase-admin/firestore';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const projectId = process.env.FIREBASE_PROJECT_ID;

let serviceAccountKey = null;

// 1. Support raw JSON string in environment variable (Render / Cloud deployment)
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  try {
    serviceAccountKey = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  } catch (err) {
    console.error('Failed to parse FIREBASE_SERVICE_ACCOUNT environment variable:', err);
  }
}

// 2. Fall back to local file or Render secret file mount
if (!serviceAccountKey) {
  const candidatePaths = [
    path.resolve(__dirname, '../../secrets/ServiceAccountKey.json'),
    path.resolve('/etc/secrets/ServiceAccountKey.json'),
    path.resolve(process.cwd(), 'secrets/ServiceAccountKey.json'),
  ];
  for (const filePath of candidatePaths) {
    if (fs.existsSync(filePath)) {
      try {
        serviceAccountKey = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        break;
      } catch (_) {}
    }
  }
}

if (getApps().length === 0) {
  if (serviceAccountKey) {
    initializeApp({
      credential: cert(serviceAccountKey),
      ...(projectId ? { projectId } : {}),
    });
  } else {
    // Default application credentials (e.g. Google Cloud Run / App Engine)
    initializeApp({
      ...(projectId ? { projectId } : {}),
    });
  }
}

export const auth = getAuth();
export const db = getFirestore();
export { FieldValue, Timestamp };
