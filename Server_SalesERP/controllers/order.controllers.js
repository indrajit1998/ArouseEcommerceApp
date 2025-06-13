const Order = require('../lib/models/Order');

exports.createOrder = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { clientOrderId, vendorId, items, subtotal, taxRate, taxAmount, deliveryFee, totalAmount, paymentMethod, deliveryAddress } = req.body;

    if (!clientOrderId) {
      return res.status(400).json({ success: false, message: 'Client Order ID is required' });
    }
    if (!vendorId) {
      return res.status(400).json({ success: false, message: 'Vendor ID is required' });
    }
    if (!items || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Items are required' });
    }
    if (!subtotal || subtotal < 0) {
      return res.status(400).json({ success: false, message: 'Subtotal is required' });
    }
    if (!taxRate || taxRate < 0) {
      return res.status(400).json({ success: false, message: 'Tax rate is required' });
    }
    if (!deliveryFee || deliveryFee < 0) {
      return res.status(400).json({ success: false, message: 'Delivery fee is required' });
    }
    if (!totalAmount || totalAmount < 0) {
      return res.status(400).json({ success: false, message: 'Total amount is required' });
    }

    const newOrder = new Order({
      client: userId,
      clientOrderId,
      vendorId,
      items,
      subtotal,
      taxRate,
      taxAmount,
      deliveryFee,
      totalAmount,
      paymentMethod,
      deliveryAddress,
      status: 'Placed',
    });

    const savedOrder = await newOrder.save();
    return res.status(201).json({ success: true, savedOrder, message: "Order placed successfully" });

  } catch (error) {
    console.error('Order creation error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

exports.updateOrder = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { orderId } = req.params;

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }
    if (order.client.toString() !== userId) {
      return res.status(403).json({ success: false, message: 'You are not authorized to update this order' });
    }

    if (order.createdAt < new Date(Date.now() - 24 * 60 * 60 * 1000)) {
      return res.status(403).json({ success: false, message: 'You can only update orders within 24 hours of creation' });
    }

    const updateData = {
      ...req.body,
      status: req.body.status || order.status,
      deliveredAt: req.body.deliveredAt ? new Date(req.body.deliveredAt) : order.deliveredAt,
    };

    const updatedOrder = await Order.findByIdAndUpdate(orderId, updateData, { new: true });

    return res.status(200).json({ success: true, updatedOrder, message: "Order updated successfully" });
  } catch (error) {
    console.error('Order update error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

exports.getOrderDetails = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { orderId } = req.params;

    const order = await Order.findById(orderId).populate('client');
    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }
    
    // Compare ObjectIDs properly
    if (order.client._id.toString() !== userId.toString()) {
      return res.status(403).json({ success: false, message: 'You are not authorized' });
    }

    return res.status(200).json({ success: true, order, message: "Order data fetched Successfully" });

  } catch (error) {
    console.error('Order fetch error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.getAllOrders = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { page, limit, date } = req.query;
    const pageNumber = parseInt(page) || 1;
    const limitNumber = parseInt(limit) || 10;
    const skip = (pageNumber - 1) * limitNumber;

    let query = { client: userId };
    if (date) {
      const startOfDay = new Date(date);
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date(date);
      endOfDay.setHours(23, 59, 59, 999);
      query.createdAt = { $gte: startOfDay, $lte: endOfDay };
    }

    const orders = await Order.find(query)
      .populate('vendorId', 'name')
      .skip(skip)
      .limit(limitNumber)
      .sort({ createdAt: -1 });
    const totalOrders = await Order.countDocuments(query);

    if (orders.length === 0) {
      return res.status(204).json({ success: false, message: 'No orders found' });
    }

    const totalPages = Math.ceil(totalOrders / limitNumber);
    const hasNextPage = pageNumber < totalPages;
    const hasPreviousPage = pageNumber > 1;
    const nextPage = hasNextPage ? pageNumber + 1 : null;
    const previousPage = hasPreviousPage ? pageNumber - 1 : null;

    return res.status(200).json({
      success: true,
      orders,
      totalOrders,
      totalPages,
      pageNumber,
      limitNumber,
      hasNextPage,
      hasPreviousPage,
      nextPage,
      previousPage,
    });
  } catch (error) {
    console.error('Internal server error at order route', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};