const asyncHandler = require('../utils/asyncHandler');
const { getCompanyRoutes } = require('../services/routeService');
const {
  createBusForCompany,
  getBusForCompany,
  updateBusForCompany,
  deleteBusForCompany
} = require('../services/busService');


const showAddBusPage = asyncHandler(async (req, res) => {
  const routesForAdmin = await getCompanyRoutes(req.session.companyId);
  return res.render('add-bus', { routesForAdmin });
});

const showEditBusPage = asyncHandler(async (req, res) => {
  const [bus, routesForAdmin] = await Promise.all([
    getBusForCompany(req.session.companyId, req.params.id),
    getCompanyRoutes(req.session.companyId)
  ]);

  return res.render('edit-bus', { bus, routesForAdmin });
});

const createBus = asyncHandler(async (req, res) => {
  const {
    deviceId,
    busNumber,
    status,
    routeId
  } = req.body || {};

  const bus = await createBusForCompany({
    companyId: req.session.companyId,
    deviceId,
    busNumber,
    status,
    routeId: routeId === '' ? null : routeId
  });

  return res.status(201).json({
    success: true,
    bus
  });
});

const updateBus = asyncHandler(async (req, res) => {
  const {
    deviceId,
    busNumber,
    status,
    routeId
  } = req.body || {};

  const bus = await updateBusForCompany({
    companyId: req.session.companyId,
    busId: req.params.id,
    deviceId,
    busNumber,
    status,
    routeId: routeId === '' ? null : routeId
  });

  return res.json({
    success: true,
    bus
  });
});

const deleteBus = asyncHandler(async (req, res) => {
  await deleteBusForCompany({
    companyId: req.session.companyId,
    busId: req.params.id
  });

  return res.json({
    success: true,
    message: 'Bus deleted successfully.'
  });
});

module.exports = {
  showAddBusPage,
  showEditBusPage,
  createBus,
  updateBus,
  deleteBus
};


