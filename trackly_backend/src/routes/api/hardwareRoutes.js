const express = require('express');
const hardwareController = require('../../controllers/hardwareController');
const publicApiController = require('../../controllers/publicApiController');

const router = express.Router();

router.post('/hardware/location', hardwareController.ingestLocation);
router.post('/test/telegram', hardwareController.testWithTelegram);
router.get('/public/routes', publicApiController.getRoutes);
router.get('/public/routes/:routeId/buses', publicApiController.getRouteBuses);
router.get('/public/routes/:routeId/nearest', publicApiController.getNearestRouteBus);

module.exports = router;
