const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/authentication');
const { addProduct, deleteProduct, findProduct, updateProduct, getAllProducts } = require('../controllers/product.controllers');
const mongoose = require('mongoose');

// Validate ObjectId
const validateObjectId = (req, res, next) => {
    const { id } = req.params;
    console.log('[product.routes] Validating ObjectId:', { id });
    if (!mongoose.Types.ObjectId.isValid(id)) {
        console.log('[product.routes] Invalid ObjectId:', { id });
        return res.status(400).json({
            success: false,
            message: 'Invalid product ID format'
        });
    }
    next();
};

// Specific routes first
router.get('/getAll', (req, res, next) => {
    console.log('[product.routes] Handling GET /api/product/getAll:', {
        method: req.method,
        url: req.originalUrl,
        headers: req.headers,
        timestamp: new Date().toISOString()
    });
    next();
}, authenticate, getAllProducts);

router.post('/add', authenticate, addProduct);

// Parametric routes last
router.get('/:id', validateObjectId, findProduct);
router.put('/:id/update', authenticate, validateObjectId, updateProduct);
router.delete('/:id/delete', authenticate, validateObjectId, deleteProduct);

module.exports = router;