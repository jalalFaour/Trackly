const asyncHandler = require('../utils/asyncHandler');
const {
  listPublicRoutes,
  listActiveBusesForRoute,
  findNearestBusForRoute
} = require('../services/busService');

const getRoutes = asyncHandler(async (req, res) => {
  const routes = await listPublicRoutes(req.query.companyId);
  return res.json({
    success: true,
    count: routes.length,
    data: routes
  });
});

const getRouteBuses = asyncHandler(async (req, res) => {
  const { route, buses } = await listActiveBusesForRoute(req.params.routeId);

  return res.json({
    success: true,
    data: {
      route,
      buses
    }
  });
});

const getNearestRouteBus = asyncHandler(async (req, res) => {
  const nearest = await findNearestBusForRoute({
    routeId: req.params.routeId,
    latitude: req.query.latitude,
    longitude: req.query.longitude
  });

  if (!nearest) {
    return res.status(404).json({
      success: false,
      message: 'No active bus found for this route.'
    });
  }

  return res.json({
    success: true,
    data: {
      bus: nearest.bus,
      distanceKm: Number(nearest.distanceKm.toFixed(3))
    }
  });
});

module.exports = {
  getRoutes,
  getRouteBuses,
  getNearestRouteBus
};
