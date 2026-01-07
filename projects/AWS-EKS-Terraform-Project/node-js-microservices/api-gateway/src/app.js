import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';

dotenv.config();

const app = express();

// Security middleware
app.use(helmet());

// CORS configuration
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(limiter);

// Body parsing middleware - only for non-proxied routes
// We need raw body for proxy middleware to work with POST requests

// Body parsing middleware for non-proxied routes
app.use('/health', express.json({ limit: '10mb' }));
app.use('/', express.json({ limit: '10mb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API Gateway is healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Welcome to Microservices API Gateway',
    version: '1.0.0',
    services: {
      auth: '/api/auth',
      products: '/api/products',
      orders: '/api/orders',
      notifications: '/api/notifications'
    },
    health: '/health',
    timestamp: new Date().toISOString()
  });
});

// Service routes with proxy middleware
const userServiceUrl = process.env.USER_SERVICE_URL || 'http://localhost:3001';
const productServiceUrl = process.env.PRODUCT_SERVICE_URL || 'http://localhost:3002';
const orderServiceUrl = process.env.ORDER_SERVICE_URL || 'http://localhost:3003';
const notificationServiceUrl = process.env.NOTIFICATION_SERVICE_URL || 'http://localhost:3004';

// Proxy to User Service
app.use('/api/auth', createProxyMiddleware({
  target: userServiceUrl,
  changeOrigin: true,
  ws: true,
  logLevel: 'debug',
  onProxyReq: (proxyReq, req, res) => {
    // Forward the raw body for POST requests
    if (req.method === 'POST' && req.body) {
      const bodyData = JSON.stringify(req.body);
      proxyReq.setHeader('Content-Type', 'application/json');
      proxyReq.setHeader('Content-Length', Buffer.byteLength(bodyData));
      proxyReq.write(bodyData);
      proxyReq.end();
    }
  },
  onError: (err, req, res) => {
    console.error('Proxy error:', err);
    res.status(502).json({ success: false, message: 'Bad Gateway' });
  }
}));

// Proxy to Product Service
app.use('/api/products', createProxyMiddleware({
  target: productServiceUrl,
  changeOrigin: true,
  pathRewrite: {
    '^/api/products': '/api/products'
  }
}));

// Proxy to Order Service
app.use('/api/orders', createProxyMiddleware({
  target: orderServiceUrl,
  changeOrigin: true,
  pathRewrite: {
    '^/api/orders': '/api/orders'
  }
}));

// Proxy to Notification Service
app.use('/api/notifications', createProxyMiddleware({
  target: notificationServiceUrl,
  changeOrigin: true,
  pathRewrite: {
    '^/api/notifications': '/api/notifications'
  }
}));

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`
  });
});

// Global error handler
app.use((error, req, res, next) => {
  console.error('Gateway error:', error);
  res.status(error.statusCode || 500).json({
    success: false,
    message: error.message || 'Internal server error'
  });
});

// Start server
const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`User Service: ${userServiceUrl}`);
  console.log(`Product Service: ${productServiceUrl}`);
  console.log(`Order Service: ${orderServiceUrl}`);
  console.log(`Notification Service: ${notificationServiceUrl}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});

export default app;
