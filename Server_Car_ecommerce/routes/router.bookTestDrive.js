const express = require('express');
const router = express.Router();
const { createTestDriveBooking } = require('../controllers/controller.bookTestDrive');

router.post('/book-test-drive', createTestDriveBooking);

module.exports = router;