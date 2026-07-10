const { buildResponse } = require('./mobileResponse');

function getKeyFromError(err) {
  if (!err) return 'ERR_UNKNOWN';
  if (err.statusCode) return `ERR_${err.statusCode}`;
  return 'ERR_UNKNOWN';
}

function wrapError({ err }) {
  return buildResponse({
    isSuccess: false,
    key: getKeyFromError(err),
    message: err?.message || 'Internal Server Error',
    paging: null,
    data: null,
    dataList: null
  });
}

module.exports = {
  wrapError
};

