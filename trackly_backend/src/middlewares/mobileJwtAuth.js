const jwt = require('jsonwebtoken');
const env = require('../config/env');

function sendUnauthorized(res, message) {
  return res.status(401).json({
    isSuccess: false,
    key: 'AUTH_UNAUTHORIZED',
    message: message || 'Unauthorized',
    paging: null,
    data: null,
    dataList: null
  });
}

function requireMobileAuth(req, res, next) {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      return sendUnauthorized(res, 'Missing access token');
    }

    const token = header.slice('Bearer '.length).trim();
    const payload = jwt.verify(token, env.JWT_ACCESS_SECRET);

    req.mobileUserId = payload.sub;
    return next();
  } catch (err) {
    return sendUnauthorized(res, 'Invalid or expired access token');
  }
}

module.exports = {
  requireMobileAuth
};

