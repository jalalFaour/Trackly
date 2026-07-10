const { Route } = require('../models');

async function getRouteWithStopsForCompany({ companyId, routeId }) {
  return Route.findOne({ _id: routeId, companyId }).select('routeName routeLengthKm path stops createdAt updatedAt');
}

module.exports = {
  getRouteWithStopsForCompany
};

