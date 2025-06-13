// backend/models/Order.js
const mongoose = require("mongoose");

const { Schema, model, Types } = mongoose;

const orderSchema = new Schema({
  client: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  clientOrderId: { type: String, required: true, unique: true },
  vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor', required: true },
  items: { type: Array, required: true },
  subtotal: { type: Number, required: true },
  taxRate: { type: Number, required: true },
  taxAmount: { type: Number, required: true },
  deliveryFee: { type: Number, required: true },
  totalAmount: { type: Number, required: true },
  paymentMethod: { type: String, required: true },
  deliveryAddress: { type: String, required: true },
  status: { type: String, default: 'Placed' },
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

const Order = model('Order', orderSchema);
module.exports = Order;