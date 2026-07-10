function notFoundHandler(req, res) {
  if (req.path.startsWith('/api/')) {
    return res.status(404).json({ error: 'Endpoint not found' });
  }

  return res.status(404).render('404');
}

const logger = require('../utils/logger');

function errorHandler(err, req, res, next) {
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  // Log server-side errors (dev-friendly)
  logger.error(
    `HTTP ${statusCode} ${req.method} ${req.path} - ${message}` +
      (err && err.stack ? `\n${err.stack}` : '')
  );

  if (req.path.startsWith('/api/')) {
    return res.status(statusCode).json({ error: message });
  }

  return res.status(statusCode).render('error', {
    message,
    statusCode,
    // Ensure templates (partials/header.ejs) always have access
    // even if res.locals wasn't established for some reason.
    currentCompany: res.locals.currentCompany || null
  });
}

module.exports = {
  notFoundHandler,
  errorHandler
};

