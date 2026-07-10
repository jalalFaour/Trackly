const { Bus, Company, LocationLog } = require('../models');

function assertValidCoordinates(latitude, longitude) {
  const lat = Number(latitude);
  const lng = Number(longitude);
  const valid = Number.isFinite(lat) && Number.isFinite(lng);

  if (!valid) {
    const error = new Error('latitude and longitude must be valid numbers.');
    error.statusCode = 400;
    throw error;
  }

  return { lat, lng };
}

async function ingestHardwareLocation(payload) {
  const {
    apiSecret,
    deviceId,
    busNumber,
    routeId = null,
    latitude,
    longitude,
    speed = 0,
    timestamp
  } = payload;

  if (!apiSecret || !deviceId) {
    const error = new Error('apiSecret and deviceId are required.');
    error.statusCode = 400;
    throw error;
  }

  const company = await Company.findOne({ apiSecret });
  if (!company) {
    const error = new Error('Invalid apiSecret.');
    error.statusCode = 401;
    throw error;
  }

  const { lat, lng } = assertValidCoordinates(latitude, longitude);

  const bus = await Bus.findOneAndUpdate(
    { deviceId },
    {
      companyId: company._id,
      routeId,
      deviceId,
      busNumber: busNumber || deviceId,
      status: 'active',
      lastLocation: {
        type: 'Point',
        coordinates: [lng, lat]
      },
      lastUpdate: timestamp ? new Date(timestamp) : new Date()
    },
    {
      upsert: true,
      new: true,
      setDefaultsOnInsert: true,
      runValidators: true
    }
  );

  const locationLog = await LocationLog.create({
    busId: bus._id,
    location: {
      type: 'Point',
      coordinates: [lng, lat]
    },
    speed: Number(speed) || 0,
    timestamp: timestamp ? new Date(timestamp) : new Date()
  });

  // Real-time broadcast (SSE)
  try {
    const { broadcast } = require('./realtime/sseBroker');
    broadcast({
      type: 'bus_location_updated',
      companyId: company._id,
      bus: {
        _id: bus._id,
        deviceId: bus.deviceId,
        busNumber: bus.busNumber,
        routeId: bus.routeId,
        status: bus.status,
        lastLocation: bus.lastLocation,
        lastUpdate: bus.lastUpdate
      },
      locationLog: {
        _id: locationLog._id,
        speed: locationLog.speed,
        timestamp: locationLog.timestamp,
        location: locationLog.location
      }
    });
  } catch (e) {
    // ignore realtime failures
    console.log('Failed to broadcast bus location update:', e.message);
  }

  return {
    companyId: company._id,
    bus,
    locationLog
  };
}

module.exports = {
  ingestHardwareLocation
};
