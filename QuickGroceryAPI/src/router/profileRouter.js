import { Router } from 'express';
import { db, FieldValue } from '../config/db.js';
import { requireUser } from '../middleware/auth.js';
import { fail, isText } from '../utils/http.js';

const router = Router();
router.use(requireUser);
const profiles = db.collection('customerProfiles');
const profileRef = (uid) => profiles.doc(uid);

router.get('/', async (req, res, next) => {
  try {
    const snapshot = await profileRef(req.user.uid).get();
    const data = snapshot.exists ? snapshot.data() : {};
    res.json({
      name: data.name || req.user.name || '', email: req.user.email || '',
      addresses: data.addresses || [], paymentMethods: data.paymentMethods || [],
    });
  } catch (error) { next(error); }
});

router.patch('/', async (req, res, next) => {
  try {
    const { name } = req.body || {};
    if (!isText(name, 120)) throw fail(400, 'Enter a valid profile name.');
    await profileRef(req.user.uid).set({ name: name.trim(), updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    res.json({ name: name.trim() });
  } catch (error) { next(error); }
});

router.post('/addresses', async (req, res, next) => {
  try {
    const { label, recipientName, phone, line1, line2 = '', landmark = '', city, state, postalCode, latitude, longitude } = req.body || {};
    if (![label, recipientName, phone, line1, city, state, postalCode].every((value) => isText(value, 120)) || (line2 && !isText(line2, 120)) || (landmark && !isText(landmark, 120))) {
      throw fail(400, 'Complete the required address fields.');
    }
    const ref = profileRef(req.user.uid);
    if ((latitude != null && (typeof latitude !== 'number' || latitude < -90 || latitude > 90)) || (longitude != null && (typeof longitude !== 'number' || longitude < -180 || longitude > 180)) || ((latitude == null) !== (longitude == null))) throw fail(400, 'Choose a valid map pin or leave it empty.');
    const address = { id: ref.collection('addressIds').doc().id, label: label.trim(), recipientName: recipientName.trim(), phone: phone.trim(), line1: line1.trim(), line2: line2.trim(), landmark: landmark.trim(), city: city.trim(), state: state.trim(), postalCode: postalCode.trim(), ...(latitude != null ? { latitude, longitude } : {}) };
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(ref);
      const addresses = snapshot.data()?.addresses || [];
      transaction.set(ref, { addresses: [...addresses, address], updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    });
    res.status(201).json(address);
  } catch (error) { next(error); }
});

router.delete('/addresses/:id', async (req, res, next) => {
  try {
    const ref = profileRef(req.user.uid);
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(ref);
      const addresses = snapshot.data()?.addresses || [];
      const nextAddresses = addresses.filter((address) => address.id !== req.params.id);
      if (nextAddresses.length === addresses.length) throw fail(404, 'Saved address not found.');
      transaction.set(ref, { addresses: nextAddresses, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    });
    res.status(204).end();
  } catch (error) { next(error); }
});

router.post('/payment-methods', async (req, res, next) => {
  try {
    const { type, label, lastFour = '', upiId = '' } = req.body || {};
    if (!['card', 'upi'].includes(type) || !isText(label, 80) || (type === 'card' && !/^\d{4}$/.test(lastFour)) || (type === 'upi' && !/^[\w.-]{2,}@[\w.-]{2,}$/.test(upiId))) {
      throw fail(400, 'Enter a valid demo card label and last four digits, or a demo UPI ID.');
    }
    const ref = profileRef(req.user.uid);
    const method = { id: ref.collection('paymentIds').doc().id, type, label: label.trim(), ...(type === 'card' ? { lastFour } : { upiId: upiId.trim() }) };
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(ref);
      const methods = snapshot.data()?.paymentMethods || [];
      transaction.set(ref, { paymentMethods: [...methods, method], updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    });
    res.status(201).json(method);
  } catch (error) { next(error); }
});

router.delete('/payment-methods/:id', async (req, res, next) => {
  try {
    const ref = profileRef(req.user.uid);
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(ref);
      const methods = snapshot.data()?.paymentMethods || [];
      const nextMethods = methods.filter((method) => method.id !== req.params.id);
      if (nextMethods.length === methods.length) throw fail(404, 'Saved payment method not found.');
      transaction.set(ref, { paymentMethods: nextMethods, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    });
    res.status(204).end();
  } catch (error) { next(error); }
});

export default router;
