import { db, FieldValue, Timestamp } from '../config/db.js';
import { orders } from '../models/Order.js';
import { products } from '../models/Product.js';
import { subscriptions } from '../models/Subscription.js';
import { walletTransactions, wallets } from '../models/Wallet.js';
import { nextOccurrence } from './scheduleTime.js';
import { advanceOrderLifecycle } from './orderLifecycle.js';

let running = false;

export async function processDueSchedules(now = new Date()) {
  if (running) return;
  running = true;
  try {
    const snapshot = await subscriptions.get();
    const due = snapshot.docs.filter((doc) => {
      const data = doc.data();
      return data.active === true && Array.isArray(data.items) && data.nextRunAt?.toDate?.() <= now;
    }).slice(0, 50);
    for (const scheduleSnapshot of due) await processOne(scheduleSnapshot.ref, now);
  } finally {
    running = false;
  }
}

async function processOne(scheduleRef, now) {
  const orderRef = orders.doc();
  const ledgerRef = walletTransactions.doc();
  let createdOrderId = null;
  let createdLocation = null;

  await db.runTransaction(async (transaction) => {
    const current = await transaction.get(scheduleRef);
    if (!current.exists) return;
    const schedule = current.data();
    if (!schedule.active || !Array.isArray(schedule.items) || !schedule.nextRunAt?.toDate || schedule.nextRunAt.toDate() > now) return;
    const actualWalletRef = wallets.doc(schedule.userId);
    const productRefs = schedule.items.map((item) => products.doc(item.productId));
    const [walletSnapshot, productSnapshots] = await Promise.all([
      transaction.get(actualWalletRef),
      Promise.all(productRefs.map((ref) => transaction.get(ref))),
    ]);
    const walletBalance = walletSnapshot.data()?.balanceCents ?? 0;
    let failure = null;
    const orderItems = [];
    let totalCents = 0;
    for (let index = 0; index < productSnapshots.length; index += 1) {
      const snapshot = productSnapshots[index];
      const product = snapshot.data();
      const requested = schedule.items[index];
      if (!snapshot.exists || product?.active === false) { failure = `${requested.productName} is unavailable.`; break; }
      if (!Number.isInteger(product.stock) || product.stock < requested.quantity) { failure = `Not enough stock for ${product.name}.`; break; }
      if (!Number.isInteger(product.priceCents) || product.priceCents < 0) { failure = 'A product has invalid catalog pricing.'; break; }
      const lineTotalCents = product.priceCents * requested.quantity;
      orderItems.push({ productId: snapshot.id, name: product.name, category: product.category, imageUrl: product.imageUrl || '', quantity: requested.quantity, unitPriceCents: product.priceCents, lineTotalCents });
      totalCents += lineTotalCents;
    }
    if (!failure && walletBalance < totalCents) failure = 'QwikWallet has insufficient demo credits.';
    const nextRunAt = Timestamp.fromDate(nextOccurrence({ scheduleDate: schedule.startDate, frequency: schedule.frequency, deliveryTime: schedule.deliveryTime, after: now }));
    if (failure) {
      transaction.update(scheduleRef, { lastRunAt: FieldValue.serverTimestamp(), lastRunStatus: 'failed', lastRunError: failure, nextRunAt, updatedAt: FieldValue.serverTimestamp() });
      return;
    }
    for (const snapshot of productSnapshots) transaction.update(snapshot.ref, { stock: snapshot.data().stock - schedule.items.find((item) => item.productId === snapshot.id).quantity, updatedAt: FieldValue.serverTimestamp() });
    transaction.update(actualWalletRef, { balanceCents: walletBalance - totalCents, updatedAt: FieldValue.serverTimestamp() });
    transaction.create(ledgerRef, { userId: schedule.userId, type: 'scheduled_order_payment', amountCents: -totalCents, balanceAfterCents: walletBalance - totalCents, orderId: orderRef.id, note: `Recurring order ${orderRef.id}`, createdAt: FieldValue.serverTimestamp() });
    transaction.create(orderRef, {
      userId: schedule.userId, customerName: schedule.customerName, phone: schedule.phone, address: schedule.address,
      ...(schedule.addressId ? { addressId: schedule.addressId } : {}), ...(schedule.deliveryLocation ? { deliveryLocation: schedule.deliveryLocation } : {}),
      items: orderItems, subtotalCents: totalCents, totalCents, status: 'placed',
      payment: { type: 'wallet', label: 'QwikWallet', simulated: true },
      createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(), source: 'subscription', subscriptionId: scheduleRef.id,
    });
    transaction.update(scheduleRef, { lastRunAt: FieldValue.serverTimestamp(), lastRunStatus: 'success', lastRunError: null, lastOrderId: orderRef.id, nextRunAt, updatedAt: FieldValue.serverTimestamp() });

    createdOrderId = orderRef.id;
    createdLocation = schedule.deliveryLocation;
  });

  if (createdOrderId) {
    advanceOrderLifecycle(createdOrderId, createdLocation).catch((err) =>
      console.error(`Auto lifecycle for scheduled order ${createdOrderId} failed:`, err)
    );
  }
}
