import { Router } from 'express';
import { db, FieldValue } from '../config/db.js';
import { requireUser } from '../middleware/auth.js';
import { demoTopUpAmounts, walletTransactions, wallets } from '../models/Wallet.js';
import { fail, serialize } from '../utils/http.js';

const router = Router();
router.use(requireUser);

router.get('/', async (req, res, next) => {
  try {
    const [wallet, ledger] = await Promise.all([
      wallets.doc(req.user.uid).get(),
      walletTransactions.where('userId', '==', req.user.uid).limit(50).get(),
    ]);
    res.json({
      balanceCents: wallet.data()?.balanceCents ?? 0,
      transactions: ledger.docs.map(serialize)
        .sort((a, b) => String(b.createdAt ?? '').localeCompare(String(a.createdAt ?? ''))),
    });
  } catch (error) { next(error); }
});

router.post('/topups', async (req, res, next) => {
  try {
    const { amountCents } = req.body || {};
    if (!demoTopUpAmounts.includes(amountCents)) throw fail(400, 'Choose one of the available demo top-up amounts.');
    const walletRef = wallets.doc(req.user.uid);
    const transactionRef = walletTransactions.doc();
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(walletRef);
      const balanceCents = snapshot.data()?.balanceCents ?? 0;
      transaction.set(walletRef, { userId: req.user.uid, balanceCents: balanceCents + amountCents, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
      transaction.create(transactionRef, { userId: req.user.uid, type: 'demo_top_up', amountCents, balanceAfterCents: balanceCents + amountCents, note: 'Simulated demo credit; no payment collected.', createdAt: FieldValue.serverTimestamp() });
    });
    res.status(201).json({ transactionId: transactionRef.id, amountCents });
  } catch (error) { next(error); }
});

export default router;
