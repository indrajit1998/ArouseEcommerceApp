const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { ConnectToMongoDB } = require('./lib/db');
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const orderRoutes = require('./routes/order.routes');
const productRoutes = require('./routes/product.routes');
const meetingRoutes = require('./routes/meeting.routes');
const clientRoutes = require('./routes/client.routes');

dotenv.config();
const app = express();

console.log('[server] Initializing server...');
console.log('[server] Environment variables:', {
    PORT: process.env.PORT,
    MONGODB_URI: process.env.MONGODB_URI,
    JWT_SECRET: process.env.JWT_SECRET ? '[REDACTED]' : 'Not set'
});

app.use(cors({
    origin: "*",
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));
app.use(express.json());

// Connect to MongoDB
ConnectToMongoDB().catch(error => {
    console.error('[server] Failed to start server due to MongoDB connection error:', {
        errorName: error.name,
        errorMessage: error.message,
        errorStack: error.stack,
        timestamp: new Date().toISOString()
    });
    process.exit(1);
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/order', orderRoutes);
app.use('/api/client', clientRoutes);
app.use('/api/product', productRoutes);
app.use('/api/meeting', meetingRoutes);

// Global error handler
app.use((error, req, res, next) => {
    console.error('[server] Unhandled error:', {
        errorName: error.name,
        errorMessage: error.message,
        errorStack: error.stack,
        request: {
            method: req.method,
            url: req.originalUrl,
            headers: req.headers
        },
        timestamp: new Date().toISOString()
    });
    res.status(500).json({
        success: false,
        message: 'Internal Server Error',
        error: {
            name: error.name,
            message: error.message
        }
    });
});

const PORT = process.env.PORT || 7500;
app.listen(PORT, () => {
    console.log(`[server] Server running on http://localhost:${PORT}`);
});

module.exports = app;