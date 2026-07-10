const asyncHandler = require('../utils/asyncHandler');
const {
  assignBusToRoute,
  addStopToRoute,
  updateStopInRoute,
  deleteStopFromRoute,
  reorderStopsInRoute
} = require('../services/adminCompanyService');
const { getRouteWithStopsForCompany } = require('../services/routeAdminService');


const assignBus = asyncHandler(async (req, res) => {
  const { busId, routeId } = req.body;

  const bus = await assignBusToRoute({
    companyId: req.session.companyId,
    busId,
    routeId: routeId === null ? null : routeId
  });

  return res.json({
    success: true,
    bus
  });
});

const getRouteStops = asyncHandler(async (req, res) => {
  const { routeId } = req.params;
  const route = await getRouteWithStopsForCompany({
    companyId: req.session.companyId,
    routeId
  });

  if (!route) {
    return res.status(404).json({ success: false, message: 'Route not found for your company.' });
  }

  return res.json({ success: true, route });
});


const addStop = asyncHandler(async (req, res) => {
  const { routeId } = req.params;
  const route = await addStopToRoute({
    companyId: req.session.companyId,
    routeId,
    stop: req.body
  });

  return res.json({ success: true, route });
});

const updateStop = asyncHandler(async (req, res) => {
  const { routeId, stopIndex } = req.params;
  const route = await updateStopInRoute({
    companyId: req.session.companyId,
    routeId,
    stopIndex,
    stop: req.body
  });

  return res.json({ success: true, route });
});

const deleteStop = asyncHandler(async (req, res) => {
  const { routeId, stopIndex } = req.params;
  const route = await deleteStopFromRoute({
    companyId: req.session.companyId,
    routeId,
    stopIndex
  });

  return res.json({ success: true, route });
});

const reorderStops = asyncHandler(async (req, res) => {
  const { routeId } = req.params;
  const route = await reorderStopsInRoute({
    companyId: req.session.companyId,
    routeId,
    orderedStopIndexes: req.body.orderedStopIndexes
  });

  return res.json({ success: true, route });
});

const { getCompanyRoutes } = require('../services/routeService');

const busAssignmentUIRoutes = asyncHandler(async (req, res) => {
  const routes = await getCompanyRoutes(req.session.companyId);
  return res.json({ success: true, routes });
});


const {
  updateBusForCompany,
  deleteBusForCompany,
  getBusForCompany
} = require('../services/busService');

const updateBus = asyncHandler(async (req, res) => {
  const { deviceId, busNumber, status, routeId } = req.body || {};

  const bus = await updateBusForCompany({
    companyId: req.session.companyId,
    busId: req.params.id,
    deviceId,
    busNumber,
    status,
    routeId: routeId === '' ? null : routeId
  });

  return res.json({ success: true, bus });
});

const deleteBus = asyncHandler(async (req, res) => {
  await deleteBusForCompany({
    companyId: req.session.companyId,
    busId: req.params.id
  });

  return res.json({ success: true, message: 'Bus deleted successfully.' });
});

module.exports = {
  assignBus,
  getRouteStops,
  addStop,
  updateStop,
  deleteStop,
  reorderStops,
  getCompanyRoutesForAdmin: busAssignmentUIRoutes,
  updateBus,
  deleteBus,
  getBusForCompany
};


