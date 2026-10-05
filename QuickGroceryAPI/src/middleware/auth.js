import { getAuth } from 'firebase-admin/auth';
import { fail } from '../utils/http.js';

export async function requireUser(req, _res, next) {
  if (req.method === 'OPTIONS') return next();
  try {
    const match = /^Bearer\s+(.+)$/i.exec(req.get('authorization') || '');
    if (!match) throw fail(401, 'Sign in to continue.');
    req.user = await getAuth().verifyIdToken(match[1], true);
    next();
  } catch (error) {
    next(error.status ? error : fail(401, 'Your session is invalid. Sign in again.'));
  }
}

export function requireStaff(req, _res, next) {
  if (req.user?.staff !== true) return next(fail(403, 'Staff access is required to update delivery status.'));
  next();
}
