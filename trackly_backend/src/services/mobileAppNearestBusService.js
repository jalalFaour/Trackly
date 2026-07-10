const { Bus, LocationLog, Route } = require('../models');
const busService = require('./busService');

const STOP_ETA_SPEED_KMH = 20;

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

function toProjectedPointKm(lat, lng, originLat) {
  const toRad = (deg) => (deg * Math.PI) / 180;
  const latScaleKm = 111.32;
  const lngScaleKm = 111.32 * Math.cos(toRad(originLat));

  return {
    x: lng * lngScaleKm,
    y: lat * latScaleKm
  };
}

function roundKm(value) {
  return Math.round(value * 100) / 100;
}

function formatEtaMinutes(minutes) {
  if (!Number.isFinite(minutes)) {
    return null;
  }

  const roundedMinutes = Math.max(0, Math.round(minutes));
  const hours = Math.floor(roundedMinutes / 60);
  const mins = roundedMinutes % 60;

  if (hours <= 0) {
    return `${mins} min`;
  }

  return mins > 0 ? `${hours} hr ${mins} min` : `${hours} hr`;
}

function getProgressKmOnRoute(routeCoordinates, point) {
  if (!Array.isArray(routeCoordinates) || routeCoordinates.length < 2) {
    const error = new Error('Route path is not available for ETA estimation.');
    error.statusCode = 400;
    throw error;
  }

  let cumulativeKm = 0;
  let bestMatch = null;

  for (let index = 1; index < routeCoordinates.length; index += 1) {
    const start = routeCoordinates[index - 1];
    const end = routeCoordinates[index];

    if (!Array.isArray(start) || !Array.isArray(end) || start.length < 2 || end.length < 2) {
      continue;
    }

    const [startLng, startLat] = start;
    const [endLng, endLat] = end;

    if (![startLat, startLng, endLat, endLng, point.lat, point.lng].every(Number.isFinite)) {
      continue;
    }

    const originLat = (startLat + endLat + point.lat) / 3;
    const projectedStart = toProjectedPointKm(startLat, startLng, originLat);
    const projectedEnd = toProjectedPointKm(endLat, endLng, originLat);
    const projectedPoint = toProjectedPointKm(point.lat, point.lng, originLat);

    const deltaX = projectedEnd.x - projectedStart.x;
    const deltaY = projectedEnd.y - projectedStart.y;
    const segmentLengthKm = calcDistanceKm(startLat, startLng, endLat, endLng);

    let ratio = 0;
    const denominator = deltaX * deltaX + deltaY * deltaY;
    if (denominator > 0) {
      ratio = ((projectedPoint.x - projectedStart.x) * deltaX +
        (projectedPoint.y - projectedStart.y) * deltaY) / denominator;
    }

    const clampedRatio = Math.max(0, Math.min(1, ratio));
    const projectedX = projectedStart.x + deltaX * clampedRatio;
    const projectedY = projectedStart.y + deltaY * clampedRatio;
    const distanceToPointKm = Math.sqrt(
      (projectedPoint.x - projectedX) * (projectedPoint.x - projectedX) +
      (projectedPoint.y - projectedY) * (projectedPoint.y - projectedY)
    );
    const distanceAlongRouteKm = cumulativeKm + segmentLengthKm * clampedRatio;

    if (!bestMatch || distanceToPointKm < bestMatch.distanceToPointKm) {
      bestMatch = {
        distanceAlongRouteKm,
        distanceToPointKm
      };
    }

    cumulativeKm += segmentLengthKm;
  }

  if (!bestMatch) {
    const error = new Error('Unable to project point on route.');
    error.statusCode = 400;
    throw error;
  }

  return bestMatch;
}

function calcBearingRad(lat1, lng1, lat2, lng2) {
  const toRad = (deg) => (deg * Math.PI) / 180;

  const φ1 = toRad(lat1);
  const φ2 = toRad(lat2);
  const Δλ = toRad(lng2 - lng1);

  const y = Math.sin(Δλ) * Math.cos(φ2);
  const x = Math.cos(φ1) * Math.sin(φ2) - Math.sin(φ1) * Math.cos(φ2) * Math.cos(Δλ);
  return Math.atan2(y, x);
}

function angleDiffRad(a, b) {
  // minimal absolute difference between two angles in radians
  let d = a - b;
  while (d > Math.PI) d -= 2 * Math.PI;
  while (d < -Math.PI) d += 2 * Math.PI;
  return Math.abs(d);
}

async function getRoute(routeId) {
  const route = await Route.findById(routeId).select('routeName path stops');
  if (!route) {
    const err = new Error('Route not found.');
    err.statusCode = 404;
    throw err;
  }
  return route;
}

async function findNearestBusThatHasNotReachedYet({ routeId, latitude, longitude }) {
  // Heuristic:
  // 1) select nearest by distance
  // 2) keep only buses that are likely still approaching the user by looking at recent movement direction.
  // If none match, fall back to absolute nearest.

  const lat = toNumber(latitude, 'latitude');
  const lng = toNumber(longitude, 'longitude');

  const nearest = await busService.findNearestBusForRoute({ routeId, latitude: lat, longitude: lng });
  if (!nearest) return null;

  const { buses } = await busService.listActiveBusesForRoute(routeId);
  if (!buses || buses.length === 0) return nearest;

  // Look at each bus's last two location logs to estimate motion bearing.
  // For performance: limit to small set closest candidates.
  const candidates = buses
    .map((bus) => {
      const [busLng, busLat] = bus.lastLocation.coordinates;
      if (!Number.isFinite(busLat) || !Number.isFinite(busLng)) {
        return { bus, distanceKm: Infinity };
      }
      return {
        bus,
        distanceKm: calcDistanceKm(lat, lng, busLat, busLng)
      };
    })
    .sort((a, b) => a.distanceKm - b.distanceKm)
    .slice(0, 8);

  let bestApproaching = null;

  for (const candidate of candidates) {
    const { bus } = candidate;
    const last = await LocationLog.find({ busId: bus._id })
      .sort({ timestamp: -1 })
      .limit(2);

    if (!last || last.length < 2) continue;

    const [l1, l2] = last; // l1 newest, l2 older
    const [lng1, lat1] = l1.location.coordinates;
    const [lng2, lat2] = l2.location.coordinates;

    if (![lat1, lng1, lat2, lng2].every(Number.isFinite)) continue;

    // motion bearing from older -> newer
    const motionBearing = calcBearingRad(lat2, lng2, lat1, lng1);
    // bearing from bus (newest position) -> user
    const userBearing = calcBearingRad(lat1, lng1, lat, lng);

    const diff = angleDiffRad(motionBearing, userBearing);

    // If motion roughly points toward user, we assume not reached yet.
    // Threshold ~ 45 degrees.
    if (diff <= Math.PI / 4) {
      if (!bestApproaching || candidate.distanceKm < bestApproaching.distanceKm) {
        bestApproaching = { bus, distanceKm: candidate.distanceKm };
      }
    }
  }

  return bestApproaching || nearest;
}

async function getNearestBusStreamPayload({ routeId, latitude, longitude }) {
  const [route, nearest] = await Promise.all([
    getRoute(routeId),
    findNearestBusThatHasNotReachedYet({ routeId, latitude, longitude })
  ]);

  return {
    route: {
      id: String(route._id),
      routeName: route.routeName,
      path: route.path,
      stops: route.stops
    },
    nearestBus: nearest
      ? {
          id: String(nearest.bus._id),
          deviceId: nearest.bus.deviceId,
          busNumber: nearest.bus.busNumber,
          status: nearest.bus.status,
          lastLocation: nearest.bus.lastLocation,
          lastUpdate: nearest.bus.lastUpdate,
          distanceKm: nearest.distanceKm
        }
      : null
  };
}

async function getStopEtaForRoute({ routeId, stopIndex, busLatitude, busLongitude }) {
  const lat = toNumber(busLatitude, 'busLatitude');
  const lng = toNumber(busLongitude, 'busLongitude');
  const normalizedStopIndex = Number(stopIndex);

  if (!Number.isInteger(normalizedStopIndex) || normalizedStopIndex < 0) {
    const error = new Error('stopIndex must be a valid zero-based index.');
    error.statusCode = 400;
    throw error;
  }

  const route = await Route.findById(routeId).select('routeName path stops');
  if (!route) {
    const error = new Error('Route not found.');
    error.statusCode = 404;
    throw error;
  }

  const stop = Array.isArray(route.stops) ? route.stops[normalizedStopIndex] : null;
  if (!stop) {
    const error = new Error('Stop not found for this route.');
    error.statusCode = 404;
    throw error;
  }

  const stopCoordinates = stop.location && Array.isArray(stop.location.coordinates)
    ? stop.location.coordinates
    : null;

  if (!stopCoordinates || stopCoordinates.length < 2) {
    const error = new Error('Stop coordinates are not available.');
    error.statusCode = 400;
    throw error;
  }

  const routeCoordinates = route.path && Array.isArray(route.path.coordinates)
    ? route.path.coordinates
    : [];

  const busProgress = getProgressKmOnRoute(routeCoordinates, { lat, lng });
  const stopProgress = getProgressKmOnRoute(routeCoordinates, {
    lat: stopCoordinates[1],
    lng: stopCoordinates[0]
  });

  const remainingKm = stopProgress.distanceAlongRouteKm - busProgress.distanceAlongRouteKm;
  const isPassed = remainingKm < 0;
  const distanceKm = isPassed ? Math.abs(remainingKm) : remainingKm;
  const etaMinutes = isPassed ? null : (distanceKm / STOP_ETA_SPEED_KMH) * 60;

  return {
    routeId: String(route._id),
    routeName: route.routeName,
    stop: {
      index: normalizedStopIndex,
      name: stop.name || '',
      order: stop.order || 0,
      location: stop.location
    },
    busLocation: {
      latitude: lat,
      longitude: lng
    },
    speedKmh: STOP_ETA_SPEED_KMH,
    routeDistanceKm: roundKm(busProgress.distanceAlongRouteKm),
    stopDistanceKm: roundKm(stopProgress.distanceAlongRouteKm),
    remainingDistanceKm: roundKm(distanceKm),
    etaMinutes: etaMinutes == null ? null : roundKm(etaMinutes),
    etaText: isPassed ? 'Bus has already passed this stop.' : formatEtaMinutes(etaMinutes),
    status: isPassed ? 'passed' : 'upcoming'
  };
}

module.exports = {
  getNearestBusStreamPayload,
  getStopEtaForRoute
};

