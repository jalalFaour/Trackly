const express = require('express');
const authController = require('../../controllers/authController');

const router = express.Router();

router.get('/login', authController.showLoginPage);
router.get('/register', authController.showRegisterPage);
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/logout', authController.logout);

module.exports = router;
