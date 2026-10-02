export const fail = (status, message) => Object.assign(new Error(message), { status });

export const isText = (value, max = 500) =>
  typeof value === 'string' && value.trim().length > 0 && value.trim().length <= max;

export const isQuantity = (value) => Number.isInteger(value) && value > 0;

export function normalize(value) {
  if (value && typeof value.toDate === 'function') return value.toDate().toISOString();
  if (Array.isArray(value)) return value.map(normalize);
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, normalize(item)]));
  }
  return value;
}

export const serialize = (snapshot) => ({ id: snapshot.id, ...normalize(snapshot.data()) });

export function errorHandler(error, _req, res, _next) {
  if (error.code === 5) {
    return res.status(503).json({ error: 'Firestore is not initialized for this Firebase project yet.' });
  }
  const status = Number.isInteger(error.status) ? error.status : 500;
  if (status >= 500) console.error(error);
  return res.status(status).json({ error: status === 500 ? 'The service could not complete the request.' : error.message });
}
