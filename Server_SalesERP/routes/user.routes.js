const express = require('express');

const { authenticate } = require('../middlewares/authentication');
const { loginUser, registerUser, findUserDetails, forgotPassword, getUserInfo, updateUserInfo } = require('../controllers/user.controllers');

const router = express.Router();

router.post("/login", loginUser);
router.post("/register", registerUser);
router.post('/passwordReset', forgotPassword);
router.get('/info', authenticate, getUserInfo);
router.get('/:id', authenticate, findUserDetails);
router.post('/:id/update', authenticate, updateUserInfo);

module.exports = router;
