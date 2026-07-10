const { Bus, Route } = require('../models');

function toObjectId(value, fieldName) {
  // keep it lightweight; Mongoose will validate cast when querying
  if (!value) {
    const err = new Error(`${fieldName} is required.`);
    err.statusCode = 400;
    throw err;
  }
  return value;
}

function toNumber(value, fieldName) {
  const num = Number(value);
  if (!Number.isFinite(num)) {
    const err = new Error(`${fieldName} must be a valid number.`);
    err.statusCode = 400;
    throw err;
  }
  return num;
}

async function assignBusToRoute({ companyId, busId, routeId }) {
  toObjectId(companyId, 'companyId');
  toObjectId(busId, 'busId');

  let route = null;
  if (routeId !== null && routeId !== undefined) {
    toObjectId(routeId, 'routeId');
    route = await Route.findOne({ _id: routeId, companyId }).select('_id routeName');
    if (!route) {
      const err = new Error('Route not found for your company.');
      err.statusCode = 404;
      throw err;
    }
  }

  const bus = await Bus.findOne({ _id: busId, companyId });
  if (!bus) {
    const err = new Error('Bus not found for your company.');
    err.statusCode = 404;
    throw err;
  }

  bus.routeId = route ? route._id : null;
  await bus.save();

  return bus;
}

async function addStopToRoute({ companyId, routeId, stop }) {
  toObjectId(routeId, 'routeId');

  const route = await Route.findOne({ _id: routeId, companyId });
  if (!route) {
    const err = new Error('Route not found for your company.');
    err.statusCode = 404;
    throw err;
  }

  const { name, order, latitude, longitude } = stop || {};
  if (latitude === undefined || longitude === undefined) {
    const err = new Error('Stop latitude and longitude are required.');
    err.statusCode = 400;
    throw err;
  }

  const lat = toNumber(latitude, 'latitude');
  const lng = toNumber(longitude, 'longitude');

  // If order not provided, append to end
  const nextOrder = order !== undefined && order !== null ? toNumber(order, 'order') : (route.stops?.length || 0);

  route.stops.push({
    name: name !== undefined && name !== null ? String(name) : '',
    order: nextOrder,
    location: {
      type: 'Point',
      coordinates: [lng, lat]
    }
  });

  // Normalize ordering (stable)
  route.stops.sort((a, b) => (a.order ?? 0) - (b.order ?? 0));

  // Re-write order to match array index
  route.stops = route.stops.map((s, i) => ({
    name: s.name,
    order: i,
    location: s.location
  }));

  await route.save();
  return route;
}

async function updateStopInRoute({ companyId, routeId, stopIndex, stop }) {
  toObjectId(routeId, 'routeId');

  const route = await Route.findOne({ _id: routeId, companyId });
  if (!route) {
    const err = new Error('Route not found for your company.');
    err.statusCode = 404;
    throw err;
  }

  const idx = toNumber(stopIndex, 'stopIndex');
  if (idx < 0 || idx >= route.stops.length) {
    const err = new Error('Invalid stopIndex.');
    err.statusCode = 400;
    throw err;
  }

  const current = route.stops[idx];
  const { name, order, latitude, longitude } = stop || {};

  if (name !== undefined) current.name = String(name);
  if (order !== undefined && order !== null) current.order = toNumber(order, 'order');
  if (latitude !== undefined || longitude !== undefined) {
    if (latitude === undefined || longitude === undefined) {
      const err = new Error('Both latitude and longitude are required when updating a stop location.');
      err.statusCode = 400;
      throw err;
    }
    const lat = toNumber(latitude, 'latitude');
    const lng = toNumber(longitude, 'longitude');
    current.location = { type: 'Point', coordinates: [lng, lat] };
  }

  route.stops.sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
  route.stops = route.stops.map((s, i) => ({ ...s, order: i }));

  await route.save();
  return route;
}

async function deleteStopFromRoute({ companyId, routeId, stopIndex }) {
  toObjectId(routeId, 'routeId');

  const route = await Route.findOne({ _id: routeId, companyId });
  if (!route) {
    const err = new Error('Route not found for your company.');
    err.statusCode = 404;
    throw err;
  }

  const idx = toNumber(stopIndex, 'stopIndex');
  if (idx < 0 || idx >= route.stops.length) {
    const err = new Error('Invalid stopIndex.');
    err.statusCode = 400;
    throw err;
  }

  route.stops.splice(idx, 1);
  route.stops = route.stops.map((s, i) => ({ ...s, order: i }));

  await route.save();
  return route;
}

async function reorderStopsInRoute({ companyId, routeId, orderedStopIndexes }) {
  toObjectId(routeId, 'routeId');

  const route = await Route.findOne({ _id: routeId, companyId });
  if (!route) {
    const err = new Error('Route not found for your company.');
    err.statusCode = 404;
    throw err;
  }

  if (!Array.isArray(orderedStopIndexes) || orderedStopIndexes.length !== route.stops.length) {
    const err = new Error('orderedStopIndexes must be an array containing all stop indexes.');
    err.statusCode = 400;
    throw err;
  }

  const idxs = orderedStopIndexes.map((x) => toNumber(x, 'stopIndex'));
  const max = route.stops.length - 1;
  if (idxs.some((i) => i < 0 || i > max)) {
    const err = new Error('orderedStopIndexes contains invalid index.');
    err.statusCode = 400;
    throw err;
  }

  const reordered = idxs.map((i) => route.stops[i]);
  route.stops = reordered.map((s, i) => ({ ...s, order: i }));

  await route.save();
  return route;
}

module.exports = {
  assignBusToRoute,
  addStopToRoute,
  updateStopInRoute,
  deleteStopFromRoute,
  reorderStopsInRoute
};

