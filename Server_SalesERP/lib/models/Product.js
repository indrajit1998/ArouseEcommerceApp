const mongoose = require("mongoose");

const productSchema = new mongoose.Schema({
    name: { type: String, required: true },
    description: { type: String, default: "" },
    images: [{ type: String }],
    category: { type: String, required: true },
    brand: { type: String, required: true },
    tags: [{ type: String }],
    variants: [{
        price: { type: Number, required: true },
        discount: { type: Number, default: 0 },
        stockQuantity: { type: Number, required: true },
        priceUnit: { type: String, required: true }
    }],
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
});

const Product = mongoose.model('Product', productSchema);
module.exports = Product;