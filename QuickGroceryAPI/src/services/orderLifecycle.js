import { db, FieldValue } from '../config/db.js';
import { orders } from '../models/Order.js';

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const activeSimulations = new Set();

/**
 * Automatically advances an order through its lifecycle:
 * placed -> confirmed (4s) -> preparing (6s) -> out_for_delivery (6s) -> delivered (12s).
 */
export async function advanceOrderLifecycle(orderId, deliveryLocation) {
  if (activeSimulations.has(orderId)) return;
  activeSimulations.add(orderId);

  try {
    const ref = orders.doc(orderId);
    let snap = await ref.get();
    if (!snap.exists) return;

    let currentStatus = snap.data().status;
    const dest = deliveryLocation || snap.data().deliveryLocation || {
      latitude: 19.0438,
      longitude: 73.0682,
      label: 'Sector 14 Kharghar',
    };

    // 1. If placed, wait and advance to confirmed
    if (currentStatus === 'placed') {
      await delay(4000);
      snap = await ref.get();
      if (!snap.exists || snap.data().status === 'cancelled') return;
      await ref.update({
        status: 'confirmed',
        updatedAt: FieldValue.serverTimestamp(),
      });
      currentStatus = 'confirmed';
    }

    // 2. If confirmed, wait and advance to preparing
    if (currentStatus === 'confirmed') {
      await delay(6000);
      snap = await ref.get();
      if (!snap.exists || snap.data().status === 'cancelled') return;
      await ref.update({
        status: 'preparing',
        updatedAt: FieldValue.serverTimestamp(),
      });
      currentStatus = 'preparing';
    }

    // 3. If preparing, wait and advance to out_for_delivery with rider details
    if (currentStatus === 'preparing') {
      await delay(6000);
      snap = await ref.get();
      if (!snap.exists || snap.data().status === 'cancelled') return;
      await ref.update({
        status: 'out_for_delivery',
        delivery: {
          riderName: 'Rahul Verma (Qwik Pilot)',
          riderPhone: '+91 98765 43210',
          simulated: true,
          origin: {
            latitude: 19.05253,
            longitude: 73.07351,
            label: 'Qwik Dark Store #12',
          },
          destination: dest,
          startedAt: FieldValue.serverTimestamp(),
        },
        updatedAt: FieldValue.serverTimestamp(),
      });
      currentStatus = 'out_for_delivery';
    }

    // 4. If out_for_delivery, wait and advance to delivered
    if (currentStatus === 'out_for_delivery') {
      await delay(12000);
      snap = await ref.get();
      if (!snap.exists || snap.data().status === 'cancelled') return;
      await ref.update({
        status: 'delivered',
        deliveredAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  } catch (error) {
    console.error(`Auto-advancing order ${orderId} failed:`, error);
  } finally {
    activeSimulations.delete(orderId);
  }
}

/**
 * Resumes simulation for any active orders that were placed or in-progress
 * (e.g. from scheduled runs or across server restarts).
 */
export async function resumeActiveOrderLifecycles() {
  try {
    const activeStatuses = ['placed', 'confirmed', 'preparing', 'out_for_delivery'];
    const snapshot = await orders.where('status', 'in', activeStatuses).limit(30).get();

    for (const doc of snapshot.docs) {
      const data = doc.data();
      advanceOrderLifecycle(doc.id, data.deliveryLocation).catch((err) =>
        console.error(`Failed to resume order ${doc.id}:`, err)
      );
    }
  } catch (error) {
    console.error('Failed to resume active orders:', error);
  }
}
