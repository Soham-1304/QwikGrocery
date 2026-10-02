import { Router } from 'express';
import { FieldValue } from '../config/db.js';
import { requireUser } from '../middleware/auth.js';
import { products } from '../models/Product.js';
import { subscriptions, subscriptionFrequencies } from '../models/Subscription.js';
import { fail, isQuantity, isText, serialize } from '../utils/http.js';

const router = Router();
router.use(requireUser);

async function productForSubscription(productId, quantity) {
  if (!isText(productId, 128) || !isQuantity(quantity)) throw fail(400, 'Choose a product and a valid quantity.');
  const snapshot = await products.doc(productId).get();
  const product = snapshot.data();
  if (!snapshot.exists || product?.active === false || !Number.isInteger(product.stock) || product.stock < quantity) throw fail(409, 'This product does not have enough available stock.');
  return { productId, productName: product.name, quantity, unitPriceCents: product.priceCents };
}

function validateSchedule({ frequency, startDate, deliveryTime }) {
  if (!subscriptionFrequencies.includes(frequency)) throw fail(400, 'Choose a valid delivery frequency.');
  const parsedDate = new Date(startDate);
  if (!startDate || Number.isNaN(parsedDate.valueOf()) || parsedDate < new Date(new Date().toDateString())) throw fail(400, 'Choose a start date today or later.');
  if (typeof deliveryTime !== 'string' || !/^([01]\d|2[0-3]):[0-5]\d$/.test(deliveryTime)) throw fail(400, 'Choose a valid delivery time.');
  return parsedDate.toISOString();
}

router.get('/', async (req, res, next) => {
  try {
    const snapshot = await subscriptions.where('userId', '==', req.user.uid).get();
    res.json(snapshot.docs.map(serialize).sort((a, b) => String(a.startDate).localeCompare(String(b.startDate))));
  } catch (error) { next(error); }
});

router.post('/', async (req, res, next) => {
  try {
    const { productId, quantity, frequency, startDate, deliveryTime } = req.body || {};
    const product = await productForSubscription(productId, quantity);
    const normalizedDate = validateSchedule({ frequency, startDate, deliveryTime });
    const ref = subscriptions.doc();
    await ref.create({ userId: req.user.uid, ...product, frequency, startDate: normalizedDate, deliveryTime, active: true, createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    res.status(201).json(serialize(await ref.get()));
  } catch (error) { next(error); }
});

router.patch('/:id', async (req, res, next) => {
  try {
    const ref = subscriptions.doc(req.params.id);
    const snapshot = await ref.get();
    if (!snapshot.exists || snapshot.data().userId !== req.user.uid) throw fail(404, 'Subscription not found.');
    const body = req.body || {};
    const update = { updatedAt: FieldValue.serverTimestamp() };
    if (typeof body.active === 'boolean') update.active = body.active;
    if (body.productId !== undefined || body.quantity !== undefined || body.frequency !== undefined || body.startDate !== undefined || body.deliveryTime !== undefined) {
      const old = snapshot.data();
      const requestedProductId = body.productId ?? old.productId;
      const requestedQuantity = body.quantity ?? old.quantity;
      let product;
      if (requestedProductId !== old.productId || requestedQuantity !== old.quantity) {
        product = await productForSubscription(requestedProductId, requestedQuantity);
      } else {
        const productSnapshot = await products.doc(old.productId).get();
        const currentProduct = productSnapshot.data();
        if (!productSnapshot.exists || currentProduct?.active === false) throw fail(409, 'This product is no longer available.');
        product = { productId: old.productId, productName: currentProduct.name, quantity: old.quantity, unitPriceCents: currentProduct.priceCents };
      }
      const frequency = body.frequency ?? old.frequency;
      const startDate = body.startDate ?? old.startDate;
      const deliveryTime = body.deliveryTime ?? old.deliveryTime;
      Object.assign(update, product, { frequency, startDate: validateSchedule({ frequency, startDate, deliveryTime }), deliveryTime });
    }
    if (Object.keys(update).length === 1) throw fail(400, 'Provide subscription changes.');
    await ref.update(update);
    res.json(serialize(await ref.get()));
  } catch (error) { next(error); }
});

export default router;
