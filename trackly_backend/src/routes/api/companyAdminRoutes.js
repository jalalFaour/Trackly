const express = require('express');
const asyncHandler = require('../../utils/asyncHandler');
const adminCompanyController = require('../../controllers/adminCompanyController');
const { requireSessionAuth } = require('../../middlewares/authMiddleware');

const router = express.Router();

router.use(requireSessionAuth);

// Bus assignment
router.post('/assign-bus', adminCompanyController.assignBus);
// Fetch routes for admin pages (used by bus assignment UI)
router.get('/routes', adminCompanyController.getCompanyRoutesForAdmin);

// Bus CRUD (edit/delete)
router.put('/buses/:id', adminCompanyController.updateBus);
router.delete('/buses/:id', adminCompanyController.deleteBus);

// Stop management
router.post('/routes/:routeId/stops', adminCompanyController.addStop);
router.put('/routes/:routeId/stops/:stopIndex', adminCompanyController.updateStop);
router.delete('/routes/:routeId/stops/:stopIndex', adminCompanyController.deleteStop);
router.post('/routes/:routeId/stops/reorder', adminCompanyController.reorderStops);

module.exports = router;

