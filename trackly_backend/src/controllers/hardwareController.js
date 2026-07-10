const asyncHandler = require('../utils/asyncHandler');
const env = require('../config/env');
const { ingestHardwareLocation } = require('../services/hardwareService');
const { sendTelegramMessage } = require('../services/telegramService');

const ingestLocation = asyncHandler(async (req, res) => {
  const result = await ingestHardwareLocation(req.body);

  return res.status(201).json({
    success: true,
    message: 'Hardware location ingested',
    data: {
      companyId: result.companyId,
      busId: result.bus._id,
      logId: result.locationLog._id,
      deviceId: result.bus.deviceId,
      location: result.bus.lastLocation,
      lastUpdate: result.bus.lastUpdate
    }
  });
});

const testWithTelegram = asyncHandler(async (req, res) => {
  const result = await ingestHardwareLocation(req.body);
  const chatId = req.body.chatId || env.telegramDefaultChatId;

  const text = [
    'Bus location received',
    `deviceId: ${result.bus.deviceId}`,
    `busNumber: ${result.bus.busNumber}`,
    `companyId: ${result.companyId}`,
    `lng: ${result.bus.lastLocation.coordinates[0]}`,
    `lat: ${result.bus.lastLocation.coordinates[1]}`,
    `speed: ${result.locationLog.speed}`,
    `timestamp: ${result.locationLog.timestamp.toISOString()}`,
    `googleMaps: https://www.google.com/maps/search/?api=1&query=${result.bus.lastLocation.coordinates[1]},${result.bus.lastLocation.coordinates[0]}`,
    `googleMapsTest: https://www.google.com/maps?q=${result.bus.lastLocation.coordinates[1]},${result.bus.lastLocation.coordinates[0]}`
  ].join('\n');

  const telegramResult = await sendTelegramMessage({
    chatId,
    text
  });

  return res.status(201).json({
    success: true,
    message: 'Stored and sent to Telegram',
    data: {
      busId: result.bus._id,
      logId: result.locationLog._id,
      telegramChatId: chatId,
      telegram: telegramResult
    }
  });
});

module.exports = {
  ingestLocation,
  testWithTelegram
};
