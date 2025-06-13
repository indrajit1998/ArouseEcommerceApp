const Product = require('../lib/models/Product');

const findProduct = async (req, res) => {
    try {
        console.log('[findProduct] Finding product:', { id: req.params.id });
        const product = await Product.findById(req.params.id).lean();
        if (!product) {
            console.log('[findProduct] Product not found');
            return res.status(204).json({ success: false, message: "Product not found" });
        }
        console.log('[findProduct] Product found:', { id: product._id, name: product.name });
        return res.status(200).json({ success: true, product });
    } catch (error) {
        console.error('[findProduct] Error:', {
            errorName: error.name,
            errorMessage: error.message,
            errorStack: error.stack,
            timestamp: new Date().toISOString()
        });
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error',
            error: error.message
        });
    }
};

const addProduct = async (req, res) => {
    try {
        console.log('[addProduct] Adding product:', { user: req.user, body: req.body });
        const { userId, role } = req.user;
        if (role !== "Admin") {
            console.log('[addProduct] Unauthorized attempt:', { userId, role });
            return res.status(403).json({ success: false, message: "Unauthorized Action!" });
        }
        const product = new Product({ ...req.body });
        const result = await product.save();
        console.log('[addProduct] Product created:', { id: result._id, name: result.name });
        return res.status(200).json({ success: true, result, message: "Product created Successfully" });
    } catch (error) {
        console.error('[addProduct] Error:', {
            errorName: error.name,
            errorMessage: error.message,
            errorStack: error.stack,
            timestamp: new Date().toISOString()
        });
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error',
            error: error.message
        });
    }
};

const updateProduct = async (req, res) => {
    try {
        console.log('[updateProduct] Updating product:', { id: req.params.id, user: req.user });
        const { userId, role } = req.user;
        if (role !== "Admin") {
            console.log('[updateProduct] Unauthorized attempt:', { userId, role });
            return res.status(403).json({ success: false, message: "Unauthorized Action!" });
        }
        const updatedProduct = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true }).lean();
        if (!updatedProduct) {
            console.log('[updateProduct] Product not found');
            return res.status(204).json({ success: false, message: "Product not found" });
        }
        console.log('[updateProduct] Product updated:', { id: updatedProduct._id, name: updatedProduct.name });
        return res.status(200).json({ success: true, updatedProduct, message: "Product updated Successfully" });
    } catch (error) {
        console.error('[updateProduct] Error:', {
            errorName: error.name,
            errorMessage: error.message,
            errorStack: error.stack,
            timestamp: new Date().toISOString()
        });
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error',
            error: error.message
        });
    }
};

const deleteProduct = async (req, res) => {
    try {
        console.log('[deleteProduct] Deleting product:', { id: req.params.id, user: req.user });
        const { userId, role } = req.user;
        if (role !== "Admin") {
            console.log('[deleteProduct] Unauthorized attempt:', { userId, role });
            return res.status(403).json({ success: false, message: "Unauthorized Action!" });
        }
        const product = await Product.findByIdAndDelete(req.params.id).lean();
        if (!product) {
            console.log('[deleteProduct] Product not found');
            return res.status(204).json({ success: false, message: "Product not found" });
        }
        console.log('[deleteProduct] Product deleted:', { id: product._id, name: product.name });
        return res.status(200).json({ success: true, message: "Product deleted Successfully" });
    } catch (error) {
        console.error('[deleteProduct] Error:', {
            errorName: error.name,
            errorMessage: error.message,
            errorStack: error.stack,
            timestamp: new Date().toISOString()
        });
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error',
            error: error.message
        });
    }
};

const getAllProducts = async (req, res) => {
    try {
        console.log('[getAllProducts] Received request:', {
            method: req.method,
            url: req.originalUrl,
            headers: req.headers,
            user: req.user || 'No user (middleware not setting req.user)',
            timestamp: new Date().toISOString()
        });
        console.log('[getAllProducts] Querying database for products...');
        const products = await Product.find().lean();
        console.log('[getAllProducts] Query result:', {
            productCount: products.length,
            products: products.map(p => ({
                id: p._id,
                name: p.name,
                hasVariants: Array.isArray(p.variants) && p.variants.length > 0,
                hasImages: Array.isArray(p.images) && p.images.length > 0,
                category: p.category,
                brand: p.brand
            }))
        });
        if (!products || products.length === 0) {
            console.log('[getAllProducts] No products found in database');
            return res.status(204).json({
                success: false,
                message: 'No products found'
            });
        }
        console.log('[getAllProducts] Successfully fetched products');
        return res.status(200).json({
            success: true,
            products
        });
    } catch (error) {
        console.error('[getAllProducts] Error occurred:', {
            errorName: error.name,
            errorMessage: error.message,
            errorStack: error.stack,
            timestamp: new Date().toISOString()
        });
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error',
            error: {
                name: error.name,
                message: error.message,
                stack: error.stack
            }
        });
    }
};

module.exports = {
    findProduct,
    addProduct,
    updateProduct,
    deleteProduct,
    getAllProducts
};