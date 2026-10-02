import { Router } from 'express';
import { db, FieldValue } from '../config/db.js';
import { requireStaff, requireUser } from '../middleware/auth.js';
import { orders, orderStatuses } from '../models/Order.js';
import { products } from '../models/Product.js';
import { fail, isQuantity, isText, serialize } from '../utils/http.js';

const router = Router();
router.use(requireUser);

router.get('/', async (req, res, next) => {
  try {
    const snapshot = await orders.where('userId', '==', req.user.uid).get();
    res.json(snapshot.docs.map(serialize).sort((a, b) => String(b.createdAt).localeCompare(String(a.createdAt))));
  } catch (error) { next(error); }
});

router.post('/', async (req, res, next) => {
  try {
    const { items, customerName, phone, address } = req.body || {};
    if (!Array.isArray(items) || items.length === 0 || items.length > 50 || !isText(customerName, 120) || !isText(phone, 40) || !isText(address, 1000)) {
      throw fail(400, 'Provide order items, customer name, phone, and delivery address.');
    }
    const quantities = new Map();
    for (const item of items) {
      if (!isText(item?.productId, 128) || !isQuantity(item?.quantity)) throw fail(400, 'Each order item needs a valid product and quantity.');
      quantities.set(item.productId, (quantities.get(item.productId) || 0) + item.quantity);
    }
    const refs = [...quantities.keys()].map((id) => products.doc(id));
    const orderRef = orders.doc();
    await db.runTransaction(async (transaction) => {
      const productSnapshots = await Promise.all(refs.map((ref) => transaction.get(ref)));
      const orderItems = [];
      let totalCents = 0;
      for (const productSnapshot of productSnapshots) {
        const product = productSnapshot.data();
        const quantity = quantities.get(productSnapshot.id);
        if (!productSnapshot.exists || product?.active === false) throw fail(409, 'A product in your cart is no longer available. Refresh the catalog.');
        if (!Number.isInteger(product.stock) || product.stock < quantity) throw fail(409, `${product.name} does not have enough stock.`);
        if (!Number.isInteger(product.priceCents) || product.priceCents < 0) throw fail(500, 'A product has invalid catalog pricing.');
        orderItems.push({ productId: productSnapshot.id, name: product.name, category: product.category, imageUrl: product.imageUrl || '', quantity, unitPriceCents: product.priceCents, lineTotalCents: product.priceCents * quantity });
        totalCents += product.priceCents * quantity;
      }
      for (const productSnapshot of productSnapshots) {
        transaction.update(productSnapshot.ref, { stock: productSnapshot.data().stock - quantities.get(productSnapshot.id), updatedAt: FieldValue.serverTimestamp() });
      }
      transaction.create(orderRef, {
        userId: req.user.uid, customerName: customerName.trim(), phone: phone.trim(), address: address.trim(),
        items: orderItems, subtotalCents: totalCents, totalCents, status: 'placed',
        createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(),
      });
    });
    res.status(201).json(serialize(await orderRef.get()));
  } catch (error) { next(error); }
});

router.get('/:id', async (req, res, next) => {
  try {
    const snapshot = await orders.doc(req.params.id).get();
    if (!snapshot.exists || snapshot.data().userId !== req.user.uid) throw fail(404, 'Order not found.');
    res.json(serialize(snapshot));
  } catch (error) { next(error); }
});

router.patch('/:id/status', requireStaff, async (req, res, next) => {
  try {
    const { status } = req.body || {};
    if (![...orderStatuses, 'cancelled'].includes(status)) throw fail(400, 'Choose a valid delivery status.');
    const ref = orders.doc(req.params.id);
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw fail(404, 'Order not found.');
      const previous = snapshot.data().status;
      const oldIndex = orderStatuses.indexOf(previous);
      const newIndex = orderStatuses.indexOf(status);
      if (previous === 'cancelled' || (status === 'cancelled' && oldIndex === orderStatuses.length - 1) || (status !== 'cancelled' && newIndex < oldIndex)) {
        throw fail(409, 'Delivery status cannot move backwards.');
      }
      transaction.update(ref, { status, updatedAt: FieldValue.serverTimestamp() });
    });
    res.json(serialize(await ref.get()));
  } catch (error) { next(error); }
});

export default router;
