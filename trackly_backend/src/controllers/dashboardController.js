const asyncHandler = require('../utils/asyncHandler');
const {
  getCompanyRoutes,
  createRouteForCompany
} = require('../services/routeService');
const { getRouteWithStopsForCompany } = require('../services/routeAdminService');

const {
  getCompanyRevenueAnalytics,
  getRouteRevenueAnalytics
} = require('../services/revenueAnalyticsService');

const showDashboard = asyncHandler(async (req, res) => {

  const [routes, companyRevenueAnalytics, routeRevenueAnalytics] = await Promise.all([
    getCompanyRoutes(req.session.companyId),
    getCompanyRevenueAnalytics({
      companyId: req.session.companyId
    }),
    getRouteRevenueAnalytics({
      companyId: req.session.companyId,
      limit: 50
    })
  ]);

  return res.render('dashboard', {
    routes,
    revenueAnalytics: companyRevenueAnalytics,
    routeRevenueAnalytics
  });
});

const showAddRoutePage = (req, res) => {
  return res.render('add-route');
};

const { listActiveBusesForRoute } = require('../services/busService');

const showRoutePage = asyncHandler(async (req, res) => {
  const route = await getRouteWithStopsForCompany({
    companyId: req.session.companyId,
    routeId: req.params.id
  });

  if (!route) {
    return res.redirect('/');
  }

  const { buses } = await listActiveBusesForRoute(req.params.id);

  // Safety: only show buses that belong to the current company
  const companyBuses = Array.isArray(buses)
    ? buses.filter(b => String(b.companyId) === String(req.session.companyId))
    : [];

  return res.render('view-route', { route, buses: companyBuses });
});


const showManageStopsPage = asyncHandler(async (req, res) => {
  const route = await getRouteWithStopsForCompany({
    companyId: req.session.companyId,
    routeId: req.params.id
  });

  if (!route) {
    return res.redirect('/');
  }

  return res.render('manage-route-stops', { route });
});


const createRoute = asyncHandler(async (req, res) => {
  const { routeName, coordinates } = req.body;

  const route = await createRouteForCompany({
    companyId: req.session.companyId,
    routeName,
    coordinates
  });

  return res.status(201).json({
    success: true,
    route
  });
});

module.exports = {
  showDashboard,
  showAddRoutePage,
  showRoutePage,
  showManageStopsPage,
  createRoute
};

