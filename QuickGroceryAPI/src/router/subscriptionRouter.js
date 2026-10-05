import { Router } from 'express';
import { db, FieldValue, Timestamp } from '../config/db.js';
import { requireUser } from '../middleware/auth.js';
import { products } from '../models/Product.js';
import { subscriptions, subscriptionFrequencies } from '../models/Subscription.js';
import { wallets, walletTransactions } from '../models/Wallet.js';
import { fail, isQuantity, isText, serialize } from '../utils/http.js';
import { nextOccurrence } from '../services/scheduleTime.js';

const router = Router();
router.use(requireUser);

function validateSchedule({ items, addressId, frequency, startDate, deliveryTime }) {
  if (!Array.isArray(items) || !items.length || items.length > 40) throw fail(400, 'Choose at least one grocery item.');
  const seen = new Set();
  for (const item of items) {
    if (!isText(item?.productId, 128) || !isQuantity(item?.quantity) || seen.has(item.productId)) throw fail(400, 'Every scheduled product needs a valid product and quantity.');
    seen.add(item.productId);
  }
  if (!isText(addressId, 128)) throw fail(400, 'Choose a saved delivery address.');
  if (!subscriptionFrequencies.includes(frequency)) throw fail(400, 'Choose a valid delivery frequency.');
  if (!/^\d{4}-\d{2}-\d{2}$/.test(startDate || '')) throw fail(400, 'Choose a valid start date.');
  const date = new Date(`${startDate}T12:00:00Z`);
  if (Number.isNaN(date.valueOf()) || date.toISOString().slice(0, 10) !== startDate) throw fail(400, 'Choose a valid start date.');
  if (typeof deliveryTime !== 'string' || !/^([01]\d|2[0-3]):[0-5]\d$/.test(deliveryTime)) throw fail(400, 'Choose a valid delivery time.');
}

async function buildSchedule(req, body) {
  validateSchedule(body);
  const profile = await db.collection('customerProfiles').doc(req.user.uid).get();
  const savedAddress = (profile.data()?.addresses || []).find((item) => item.id === body.addressId);
  if (!savedAddress) throw fail(400, 'That saved address is unavailable.');
  const productRefs = body.items.map((item) => products.doc(item.productId));
  const snapshots = await Promise.all(productRefs.map((ref) => ref.get()));
  const normalizedItems = snapshots.map((snapshot, index) => {
    const product = snapshot.data();
    const quantity = body.items[index].quantity;
    if (!snapshot.exists || product?.active === false) throw fail(409, 'A scheduled product is no longer available.');
    if (!Number.isInteger(product.priceCents) || product.priceCents < 0) throw fail(500, 'A product has invalid catalog pricing.');
    return { productId: snapshot.id, productName: product.name, quantity, unitPriceCents: product.priceCents };
  });
  const scheduleDate = body.startDate;
  const nextRun = nextOccurrence({ scheduleDate, frequency: body.frequency, deliveryTime: body.deliveryTime, after: new Date(Date.now() - 60_000) });
  return {
    userId: req.user.uid,
    customerName: savedAddress.recipientName,
    phone: savedAddress.phone,
    addressId: savedAddress.id,
    address: [savedAddress.line1, savedAddress.line2, savedAddress.landmark, savedAddress.city, savedAddress.state, savedAddress.postalCode].filter(Boolean).join(', '),
    ...(typeof savedAddress.latitude === 'number' && typeof savedAddress.longitude === 'number' ? { deliveryLocation: { latitude: savedAddress.latitude, longitude: savedAddress.longitude } } : {}),
    items: normalizedItems,
    paymentMethod: 'wallet',
    frequency: body.frequency,
    startDate: scheduleDate,
    deliveryTime: body.deliveryTime,
    timeZone: 'Asia/Kolkata',
    nextRunAt: Timestamp.fromDate(nextRun),
    lastRunStatus: null,
    active: true,
    updatedAt: FieldValue.serverTimestamp(),
  };
}

router.get('/', async (req, res, next) => {
  try {
    const snapshot = await subscriptions.where('userId', '==', req.user.uid).get();
    res.json(snapshot.docs.map(serialize).sort((a, b) => String(a.nextRunAt ?? a.startDate).localeCompare(String(b.nextRunAt ?? b.startDate))));
  } catch (error) { next(error); }
});

router.post('/', async (req, res, next) => {
  try {
    const data = await buildSchedule(req, req.body || {});
    const ref = subscriptions.doc();
    await ref.create({ ...data, createdAt: FieldValue.serverTimestamp() });
    res.status(201).json(serialize(await ref.get()));
  } catch (error) { next(error); }
});

router.patch('/:id', async (req, res, next) => {
  try {
    const ref = subscriptions.doc(req.params.id);
    const snapshot = await ref.get();
    if (!snapshot.exists || snapshot.data().userId !== req.user.uid) throw fail(404, 'Subscription not found.');
    const body = req.body || {};
    if (typeof body.active === 'boolean' && Object.keys(body).length === 1) {
      await ref.update({ active: body.active, updatedAt: FieldValue.serverTimestamp() });
      return res.json(serialize(await ref.get()));
    }
    const data = await buildSchedule(req, body);
    await ref.update({ ...data, updatedAt: FieldValue.serverTimestamp() });
    res.json(serialize(await ref.get()));
  } catch (error) { next(error); }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const ref = subscriptions.doc(req.params.id);
    const snapshot = await ref.get();
    if (!snapshot.exists || snapshot.data().userId !== req.user.uid) throw fail(404, 'Subscription not found.');
    await ref.delete();
    res.json({ success: true, id: req.params.id });
  } catch (error) { next(error); }
});

export default router;
