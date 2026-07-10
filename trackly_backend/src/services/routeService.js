const { Route } = require('../models');

async function getCompanyRoutes(companyId) {
  return Route.find({ companyId }).sort({ createdAt: -1 });
}

function calcDistanceKm(lat1, lng1, lat2, lng2) {
  const toRad = (deg) => (deg * Math.PI) / 180;
  const earthKm = 6371;

  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) * Math.sin(dLng / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return earthKm * c;
}

function calcRouteLengthKmFromLineStringCoordinates(coordinates) {
  // GeoJSON LineString coordinates format: [[lng, lat], [lng, lat], ...]
  if (!Array.isArray(coordinates) || coordinates.length < 2) return 0;

  let totalKm = 0;
  for (let i = 1; i < coordinates.length; i++) {
    const prev = coordinates[i - 1];
    const curr = coordinates[i];
    if (!Array.isArray(prev) || !Array.isArray(curr) || prev.length < 2 || curr.length < 2) continue;

    const [prevLng, prevLat] = prev;
    const [currLng, currLat] = curr;

    if (![prevLat, prevLng, currLat, currLng].every(Number.isFinite)) continue;

    totalKm += calcDistanceKm(prevLat, prevLng, currLat, currLng);
  }

  // Keep stable numbers (avoid huge floating noise in UI)
  return Math.round(totalKm * 100) / 100;
}

async function createRouteForCompany({ companyId, routeName, coordinates }) {
  if (!routeName || !String(routeName).trim()) {
    const error = new Error('routeName is required.');
    error.statusCode = 400;
    throw error;
  }

  if (!Array.isArray(coordinates) || coordinates.length < 2) {
    const error = new Error('Route needs at least 2 points.');
    error.statusCode = 400;
    throw error;
  }

  const routeLengthKm = calcRouteLengthKmFromLineStringCoordinates(coordinates);

  return Route.create({
    companyId,
    routeName,
    routeLengthKm,
    path: {
      type: 'LineString',
      coordinates
    }
  });
}

async function getRouteByIdForCompany(routeId, companyId) {
  return Route.findOne({ _id: routeId, companyId });
}

module.exports = {
  getCompanyRoutes,
  createRouteForCompany,
  getRouteByIdForCompany
};
