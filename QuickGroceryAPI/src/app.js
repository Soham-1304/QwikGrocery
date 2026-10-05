import cors from 'cors';
import express from 'express';
import orderRouter from './router/orderRouter.js';
import productRouter from './router/productRouter.js';
import subscriptionRouter from './router/subscriptionRouter.js';
import profileRouter from './router/profileRouter.js';
import walletRouter from './router/walletRouter.js';
import { errorHandler, fail } from './utils/http.js';

const app = express();

app.disable('x-powered-by');
app.use(cors({
  origin: true,
  credentials: true,
}));
app.options('*', cors());
app.use(express.json({ limit: '64kb' }));
app.get('/api/health', (_req, res) => res.json({ status: 'ok' }));
app.use('/api/products', productRouter);
app.use('/api/orders', orderRouter);
app.use('/api/subscriptions', subscriptionRouter);
app.use('/api/profile', profileRouter);
app.use('/api/wallet', walletRouter);
app.use((_req, _res, next) => next(fail(404, 'Endpoint not found.')));
app.use(errorHandler);

export default app;
