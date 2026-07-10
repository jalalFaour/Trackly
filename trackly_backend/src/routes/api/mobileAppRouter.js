const express = require('express');

const mobileAppController = require('../../controllers/mobileAppController');
const mobileAppNearestBusController = require('../../controllers/mobileAppNearestBusController');
const { requireMobileAuth } = require('../../middlewares/mobileJwtAuth');

const router = express.Router();

// Auth
router.post('/auth/signup', mobileAppController.signup);
router.post('/auth/login', mobileAppController.login);
router.get('/profile', requireMobileAuth, mobileAppController.profile);

// Wallet
router.post('/wallet/add-credit', requireMobileAuth, mobileAppController.addCredit);
router.post('/wallet/deduct', requireMobileAuth, mobileAppController.deductCredit);
router.get('/wallet/balance', requireMobileAuth, mobileAppController.getBalance);
router.get('/wallet/deduct-price', mobileAppController.deductPrice);

// Routes (public across all companies)
router.get('/routes', requireMobileAuth, mobileAppController.getAllCompaniesRoutes);

// Nearest bus (SSE stream)
// Body: { routeId, latitude, longitude }
router.post(
  '/nearest-bus/stream',
  requireMobileAuth,
  mobileAppNearestBusController.streamNearestBusForRoute
);

router.post(
  '/routes/stop-eta',
  // requireMobileAuth,
  mobileAppNearestBusController.getStopEtaForRoute
);

module.exports = router;
