const { createLogger, format, transports } = require('winston');

const env = process.env.NODE_ENV || 'development';

const logger = createLogger({
  level: env === 'production' ? 'info' : 'debug',
  format: format.combine(
    format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
    format.errors({ stack: true }),
    format.printf(({ timestamp, level, message, stack }) => {
      const base = `${timestamp} [${level.toUpperCase()}] ${message}`;
      return stack ? `${base}\n${stack}` : base;
    })
  ),
  transports: [
    new transports.Console({
      handleExceptions: true
    })
  ],
  exitOnError: false
});

module.exports = logger;

