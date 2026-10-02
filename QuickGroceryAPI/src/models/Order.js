import { db } from '../config/db.js';

export const orders = db.collection('orders');

export const orderStatuses = ['placed', 'confirmed', 'preparing', 'out_for_delivery', 'delivered'];
