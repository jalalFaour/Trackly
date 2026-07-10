const asyncHandler = require('../utils/asyncHandler');
const { getCompanyBuses, getBusLogsForCompany } = require('../services/busService');
const { getCompanyRoutes } = require('../services/routeService');

const showBusesPage = asyncHandler(async (req, res) => {
  const [buses, routesForAdmin] = await Promise.all([
    getCompanyBuses(req.session.companyId),
    getCompanyRoutes(req.session.companyId)
  ]);

  return res.render('buses', { buses, routesForAdmin });
});

const showBusLogsPage = asyncHandler(async (req, res) => {
  const { bus, logs } = await getBusLogsForCompany(req.session.companyId, req.params.id, req.query.limit);
  return res.render('bus-logs', { bus, logs });
});

module.exports = {
  showBusesPage,
  showBusLogsPage
};
