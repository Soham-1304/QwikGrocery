import { db } from '../config/db.js';

export const subscriptions = db.collection('subscriptions');

export const subscriptionFrequencies = ['Daily', 'Weekly', 'Biweekly', 'Monthly'];
