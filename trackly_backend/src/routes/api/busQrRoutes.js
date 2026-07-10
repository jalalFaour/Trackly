const express = require('express');
const QRCode = require('qrcode');
const asyncHandler = require('../../utils/asyncHandler');
const { requireSessionAuth } = require('../../middlewares/authMiddleware');

const router = express.Router();

// Generate QR code PNG for the bus id (text only)
router.get('/:id/qrcode.png', requireSessionAuth, asyncHandler(async (req, res) => {
  const text = req.params.id;

  const pngBuffer = await QRCode.toBuffer(text, {
    type: 'png',
    errorCorrectionLevel: 'M',
    width: 300,
    margin: 2
  });

  res.setHeader('Content-Type', 'image/png');
  res.setHeader('Content-Disposition', `attachment; filename="bus-${text}.png"`);
  res.send(pngBuffer);
}));

module.exports = router;

