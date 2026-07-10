// Backward-compatible service module (used by controller)
const {
  getNearestBusStreamPayload,
  getStopEtaForRoute
} = require('./mobileAppNearestBusService');

async function streamNearestBusForRoute({ routeId, latitude, longitude }) {
  return getNearestBusStreamPayload({ routeId, latitude, longitude });
}

module.exports = {
  streamNearestBusForRoute,
  getStopEtaForRoute
};

