const express = require('express');
const { requireSessionAuth } = require('../../middlewares/authMiddleware');
const { addClient } = require('../../services/realtime/sseBroker');

const router = express.Router();

// SSE stream for real-time updates (dashboard/admin)
router.get('/sse', requireSessionAuth, (req, res) => {
  res.set({
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    Connection: 'keep-alive'
  });
  res.flushHeaders();

  // initial comment to keep connection active in some proxies
  res.write(': connected\n\n');

  addClient(res);
});

module.exports = router;

