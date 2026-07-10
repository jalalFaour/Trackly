const clients = new Set();

function addClient(res) {
  const client = { res, id: Date.now() + Math.random() };
  clients.add(client);

  // remove on close
  res.on('close', () => {
    clients.delete(client);
  });

  return client;
}

function broadcast(event) {
  const payload = typeof event === 'string' ? event : JSON.stringify(event);

  for (const client of clients) {
    try {
      client.res.write(`event: message\n`);
      client.res.write(`data: ${payload}\n\n`);
    } catch (e) {
      // ignore individual client failures; close will clean up
      console.log('Failed to send SSE message to client:', e.message);
    }
  }
}

module.exports = {
  addClient,
  broadcast
};

