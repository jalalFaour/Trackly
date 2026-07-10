const asyncHandler = require('../utils/asyncHandler');
const { buildResponse } = require('../utils/mobileResponse');
const { setSseHeaders, writeSseEvent } = require('../utils/sseMobile');
const mobileAppNearestBusService = require('../services/mobileAppServiceNearestBus');

function handleErrorForSse(res, err) {
  const statusCode = err.statusCode || 500;
  const payload = {
    isSuccess: false,
    key: `ERR_SSE_${statusCode}`,
    message: err.message || 'Internal Server Error',
    data: null,
    dataList: null
  };

  writeSseEvent(res, 'error', payload);
  writeSseEvent(res, 'done', { ok: false });
  res.end();
}

// SSE: /api/mobile/nearest-bus/stream
const streamNearestBusForRoute = asyncHandler(async (req, res) => {
  const { routeId, latitude, longitude } = req.body || {};

  // SSE headers
  setSseHeaders(res);

  // Validate early
  if (!routeId) {
    return handleErrorForSse(res, Object.assign(new Error('routeId is required'), { statusCode: 400 }));
  }

  if (latitude === undefined || longitude === undefined) {
    return handleErrorForSse(res, Object.assign(new Error('latitude and longitude are required'), { statusCode: 400 }));
  }

  // Live updates: keep SSE open and re-calc periodically.
  // The hardware ingestion already broadcasts bus updates, but this endpoint currently recomputes
  // nearest bus on an interval for reliability.
  const { addClient } = require('../services/realtime/sseBroker');
  addClient(res);


  let ended = false;
  const stop = () => {
    ended = true;
    try {
      res.end();
    } catch (_) {}
  };

  // Recompute on a timer for reliability (browser/proxy buffering can hide events).
  // Interval can be tuned. Keep it short enough for “live”, but not too chatty.
  const intervalMs = 5000;

  const tick = async () => {
    if (ended) return;
    try {
      const payload = await mobileAppNearestBusService.streamNearestBusForRoute({
        routeId,
        latitude,
        longitude
      });

      writeSseEvent(res, 'nearest-bus', {
        route: payload.route,
        nearestBus: payload.nearestBus
      });
    } catch (err) {
      writeSseEvent(
        res,
        'error',
        {
          isSuccess: false,
          key: `ERR_SSE_${err.statusCode || 500}`,
          message: err.message || 'Internal Server Error',
          data: null,
          dataList: null
        }
      );
      writeSseEvent(res, 'done', { ok: false });
      stop();
    }
  };

  // First emit immediately
  await tick();

  const intervalId = setInterval(() => {
    // Avoid overlapping ticks
    tick();
  }, intervalMs);

  res.on('close', () => {
    clearInterval(intervalId);
    ended = true;
  });

  // Do NOT end response here (keep SSE open)
  return;
  
});

const getStopEtaForRoute = asyncHandler(async (req, res) => {
  try {
    const { routeId, stopIndex, busLatitude, busLongitude } = req.body || {};

    if (!routeId) {
      const error = new Error('routeId is required');
      error.statusCode = 400;
      throw error;
    }

    if (stopIndex === undefined || stopIndex === null) {
      const error = new Error('stopIndex is required');
      error.statusCode = 400;
      throw error;
    }

    if (busLatitude === undefined || busLongitude === undefined) {
      const error = new Error('busLatitude and busLongitude are required');
      error.statusCode = 400;
      throw error;
    }

    const eta = await mobileAppNearestBusService.getStopEtaForRoute({
      routeId,
      stopIndex,
      busLatitude,
      busLongitude
    });

    return res.json(
      buildResponse({
        isSuccess: true,
        key: 'STOP_ETA_SUCCESS',
        message: 'Stop ETA estimated',
        paging: null,
        data: eta,
        dataList: null
      })
    );
  } catch (err) {
    const statusCode = err.statusCode || 500;
    return res.status(statusCode).json(
      buildResponse({
        isSuccess: false,
        key: `ERR_${statusCode}`,
        message: err.message || 'Internal Server Error',
        paging: null,
        data: null,
        dataList: null
      })
    );
  }
});

module.exports = {
  streamNearestBusForRoute,
  getStopEtaForRoute
};

