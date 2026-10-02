import cors from 'cors';
import express from 'express';
import orderRouter from './router/orderRouter.js';
import productRouter from './router/productRouter.js';
import subscriptionRouter from './router/subscriptionRouter.js';
import { errorHandler, fail } from './utils/http.js';

const app = express();
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map((value) => value.trim())
  : ['http://localhost:5000', 'http://localhost:8080'];

app.disable('x-powered-by');
app.use(cors({
  origin(origin, callback) {
    const flutterDevOrigin = /^http:\/\/(localhost|127\.0\.0\.1):8080$/.test(origin || '');
    callback(null, !origin || allowedOrigins.includes(origin) || flutterDevOrigin);
  },
}));
app.use(express.json({ limit: '64kb' }));
app.get('/api/health', (_req, res) => res.json({ status: 'ok' }));
app.use('/api/products', productRouter);
app.use('/api/orders', orderRouter);
app.use('/api/subscriptions', subscriptionRouter);
app.use((_req, _res, next) => next(fail(404, 'Endpoint not found.')));
app.use(errorHandler);

export default app;
