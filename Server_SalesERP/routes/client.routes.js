const express = require('express');
const {
  createClient,
  getAllClients,
  getClientDetails,
  getClientHistoryDetails,
  updateClient,
  checkVendorName
} = require('../controllers/client.controllers');

const router = express.Router();

router.post('/add', createClient);
router.put('/update/:vendorId', updateClient);

router.get('/getall', getAllClients);
router.get('/get/:vendorId', getClientDetails);
router.get('/get/:vendorId/history', getClientHistoryDetails);
router.post('/checkVendorName', checkVendorName);

module.exports = router;
