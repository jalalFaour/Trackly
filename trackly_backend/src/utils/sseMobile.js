function setSseHeaders(res) {
  res.set({
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    Connection: 'keep-alive'
  });

  // Some proxies buffer; flush to push immediately.
  if (typeof res.flushHeaders === 'function') {
    res.flushHeaders();
  }

  // Keep connection active
  res.write(': connected\n\n');
}

function writeSseEvent(res, event, data) {
  if (!res || res.writableEnded) return;

  if (event) {
    res.write(`event: ${event}\n`);
  }
  res.write(`data: ${JSON.stringify(data)}\n\n`);
}

module.exports = {
  setSseHeaders,
  writeSseEvent
};

