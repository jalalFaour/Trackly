const { Bus, LocationLog, Route } = require('../models');

function toNumber(value, fieldName) {
  const num = Number(value);
  if (!Number.isFinite(num)) {
    const error = new Error(`${fieldName} must be a valid number.`);
    error.statusCode = 400;
    throw error;
  }
  return num;
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

async function getCompanyBuses(companyId) {
  return Bus.find({ companyId })
    .populate('routeId', 'routeName')
    .sort({ lastUpdate: -1 });
}

async function getBusLogsForCompany(companyId, busId, limit = 50) {
  const bus = await Bus.findOne({ _id: busId, companyId });
  if (!bus) {
    const error = new Error('Bus not found for your company.');
    error.statusCode = 404;
    throw error;
  }

  const logs = await LocationLog.find({ busId: bus._id })
    .sort({ timestamp: -1 })
    .limit(Math.min(Number(limit) || 50, 200));

  return { bus, logs };
}

async function listPublicRoutes(companyId) {
  const query = {};
  if (companyId) {
    query.companyId = companyId;
  }

  return Route.find(query)
    .select('companyId routeName routeLengthKm path stops createdAt updatedAt')
    .populate('companyId', 'name')
    .sort({ createdAt: -1 });
}

async function listActiveBusesForRoute(routeId) {
  const route = await Route.findById(routeId).select('routeName companyId');
  if (!route) {
    const error = new Error('Route not found.');
    error.statusCode = 404;
    throw error;
  }

  const buses = await Bus.find({
    routeId,
    status: 'active'
  })
    .select('deviceId busNumber status lastLocation lastUpdate companyId routeId')
    .sort({ lastUpdate: -1 });

  return {
    route,
    buses
  };
}

async function findNearestBusForRoute({ routeId, latitude, longitude }) {
  const { buses } = await listActiveBusesForRoute(routeId);

  const lat = toNumber(latitude, 'latitude');
  const lng = toNumber(longitude, 'longitude');

  if (buses.length === 0) {
    return null;
  }

  let nearest = null;

  for (const bus of buses) {
    const [busLng, busLat] = bus.lastLocation.coordinates;

    if (!Number.isFinite(busLat) || !Number.isFinite(busLng)) {
      continue;
    }

    const distanceKm = calcDistanceKm(lat, lng, busLat, busLng);

    if (!nearest || distanceKm < nearest.distanceKm) {
      nearest = {
        bus,
        distanceKm
      };
    }
  }

  return nearest;
}

async function createBusForCompany({ companyId, deviceId, busNumber, status = 'idle', routeId = null }) {
  if (!deviceId || !String(deviceId).trim()) {
    const error = new Error('deviceId is required.');
    error.statusCode = 400;
    throw error;
  }

  if (!busNumber || !String(busNumber).trim()) {
    const error = new Error('busNumber is required.');
    error.statusCode = 400;
    throw error;
  }

  if (!['active', 'idle', 'maintenance'].includes(status)) {
    const error = new Error('status must be one of: active, idle, maintenance.');
    error.statusCode = 400;
    throw error;
  }

  // Ensure deviceId uniqueness (schema has unique index, but we provide a clearer error)
  const existing = await Bus.findOne({ deviceId: String(deviceId).trim() });
  if (existing) {
    const error = new Error('A bus with this deviceId already exists.');
    error.statusCode = 409;
    throw error;
  }

  let normalizedRouteId = null;
  if (routeId) {
    const route = await Route.findOne({ _id: routeId, companyId }).select('_id');
    if (!route) {
      const error = new Error('Route not found for your company.');
      error.statusCode = 404;
      throw error;
    }
    normalizedRouteId = route._id;
  }

  const bus = await Bus.create({
    companyId,
    deviceId: String(deviceId).trim(),
    busNumber: String(busNumber).trim(),
    status,
    routeId: normalizedRouteId
  });

  return bus;
}

async function getBusForCompany(companyId, busId) {
  const bus = await Bus.findOne({ _id: busId, companyId }).populate('routeId', 'routeName');
  if (!bus) {
    const error = new Error('Bus not found for your company.');
    error.statusCode = 404;
    throw error;
  }
  return bus;
}

async function updateBusForCompany({ companyId, busId, deviceId, busNumber, status, routeId }) {
  if (!deviceId || !String(deviceId).trim()) {
    const error = new Error('deviceId is required.');
    error.statusCode = 400;
    throw error;
  }

  if (!busNumber || !String(busNumber).trim()) {
    const error = new Error('busNumber is required.');
    error.statusCode = 400;
    throw error;
  }

  if (!['active', 'idle', 'maintenance'].includes(status)) {
    const error = new Error('status must be one of: active, idle, maintenance.');
    error.statusCode = 400;
    throw error;
  }

  const existingBus = await getBusForCompany(companyId, busId);

  const normalizedDeviceId = String(deviceId).trim();
  if (normalizedDeviceId !== String(existingBus.deviceId)) {
    const conflict = await Bus.findOne({ deviceId: normalizedDeviceId, _id: { $ne: busId } });
    if (conflict) {
      const error = new Error('A bus with this deviceId already exists.');
      error.statusCode = 409;
      throw error;
    }
  }

  let normalizedRouteId = null;
  if (routeId) {
    const route = await Route.findOne({ _id: routeId, companyId }).select('_id');
    if (!route) {
      const error = new Error('Route not found for your company.');
      error.statusCode = 404;
      throw error;
    }
    normalizedRouteId = route._id;
  }

  existingBus.deviceId = normalizedDeviceId;
  existingBus.busNumber = String(busNumber).trim();
  existingBus.status = status;
  existingBus.routeId = normalizedRouteId;

  await existingBus.save();
  return existingBus;
}

async function deleteBusForCompany({ companyId, busId }) {
  const bus = await Bus.findOne({ _id: busId, companyId }).select('_id');
  if (!bus) {
    const error = new Error('Bus not found for your company.');
    error.statusCode = 404;
    throw error;
  }

  // Remove the bus (and related logs will remain unless you add cascading deletes)
  await Bus.deleteOne({ _id: busId, companyId });
  return true;
}

module.exports = {
  getCompanyBuses,
  getBusLogsForCompany,
  listPublicRoutes,
  listActiveBusesForRoute,
  findNearestBusForRoute,
  createBusForCompany,
  getBusForCompany,
  updateBusForCompany,
  deleteBusForCompany
};


