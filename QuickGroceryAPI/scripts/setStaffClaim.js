import 'dotenv/config';
import { auth } from '../src/config/db.js';

const [uid, action = 'grant'] = process.argv.slice(2);
if (!uid || !['grant', 'revoke'].includes(action)) {
  console.error('Usage: npm run staff:claim -- <firebase-user-uid> [grant|revoke]');
  process.exitCode = 2;
} else {
  const user = await auth.getUser(uid);
  const claims = { ...user.customClaims };
  if (action === 'grant') claims.staff = true;
  else delete claims.staff;
  await auth.setCustomUserClaims(uid, claims);
  console.log(`Staff access ${action === 'grant' ? 'granted to' : 'revoked from'} ${user.email || uid}. Sign out and back in to refresh the token.`);
}
