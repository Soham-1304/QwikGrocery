import 'dotenv/config';
import { randomBytes } from 'node:crypto';
import { auth } from '../src/config/db.js';

const email = process.env.STAFF_EMAIL || 'staff@qwikgrocery.test';
const password = randomBytes(18).toString('base64url');

try {
  await auth.getUserByEmail(email);
  console.error(`A Firebase user already uses ${email}; no account or password was changed.`);
  process.exitCode = 1;
} catch (error) {
  if (error.code !== 'auth/user-not-found') throw error;

  const user = await auth.createUser({
    email,
    password,
    displayName: 'QwikGrocery Staff',
    emailVerified: true,
  });

  try {
    await auth.setCustomUserClaims(user.uid, { staff: true });
  } catch (error) {
    await auth.deleteUser(user.uid);
    throw error;
  }

  console.log('QwikGrocery staff account created. Save this password now; it is not stored in the project.');
  console.log(`Email: ${email}`);
  console.log(`Password: ${password}`);
  console.log(`UID: ${user.uid}`);
  console.log('Role: staff (Firebase custom claim)');
  console.log('Sign in at http://localhost:8080, then sign out and back in if already signed in.');
}
