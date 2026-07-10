const morgan = require('morgan');
const logger = require('../utils/logger');

// Dev-friendly HTTP request logger.
// Logs: METHOD URL STATUS ms
module.exports = function requestLoggerMiddleware(req, res, next) {
  // Use morgan in "dev"-like format but route through winston.
  const morganFormat = ':method :url :status :response-time ms';

  return morgan(morganFormat, {
    // Only log completed responses
    immediate: false,
    skip: (r) => r.path && r.path.startsWith('/public/')
  })(req, res, (err) => {
    // morgan uses next for parsing errors; in those cases still proceed to error handler
    if (err) return next(err);
    return next();
  });
};

// Note: We rely on morgan's internal logging; to send to winston we hook stdout.
// If you later want strict winston-only output, replace this middleware with a custom
// res finish listener and call logger directly.

