const express = require('express');
const { createUser, loginUser } = require('../controllers/auth.controllers');

const router = express.Router();

router.post('/login', loginUser);
router.post('/signup', createUser);

module.exports = router;
