import { db } from '../config/db.js';

export const wallets = db.collection('wallets');
export const walletTransactions = db.collection('walletTransactions');

export const demoTopUpAmounts = [5000, 10000, 25000, 50000];
