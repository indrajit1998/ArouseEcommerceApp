const express = require('express');
const { authenticate } = require('../middlewares/authentication');
const {
  createOrder,
  getOrderDetails,
  updateOrder,
  getAllOrders
} = require('../controllers/order.controllers');

const router = express.Router();

router.post('/add', authenticate, createOrder);
router.put('/update/:id', authenticate, updateOrder);
router.get('/get/:id', authenticate, getOrderDetails);
router.get('/getall', authenticate, getAllOrders);

module.exports = router;
