const express = require('express');
const dashboardController = require('../../controllers/dashboardController');
const busController = require('../../controllers/busController');
const busAdminController = require('../../controllers/busAdminController');
const { requireSessionAuth } = require('../../middlewares/authMiddleware');


const router = express.Router();

router.use(requireSessionAuth);
router.get('/', dashboardController.showDashboard);
router.get('/add-route', dashboardController.showAddRoutePage);
router.get('/add-bus', busAdminController.showAddBusPage);


router.get('/view-route/:id', dashboardController.showRoutePage);
router.get('/view-route/:id/stops', dashboardController.showManageStopsPage);


router.get('/buses', busController.showBusesPage);
router.get('/buses/:id/logs', busController.showBusLogsPage);
router.post('/api/routes', dashboardController.createRoute);
router.post('/api/buses', busAdminController.createBus);
router.get('/buses/:id/edit', busAdminController.showEditBusPage);

module.exports = router;
