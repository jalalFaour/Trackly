function defaultPaging() {
  return {
    totalRecords: 0,
    pageSize: 12,
    pageNumber: 1,
    firstPage: -1,
    lastPage: -1,
    previousPage: -1,
    nextPage: -1,
    totalPages: -1,
    firstItem: -1,
    lastItem: -1,
    withPaging: true
  };
}

function buildResponse({
  isSuccess,
  key = '',
  message = '',
  paging = null,
  data = null,
  dataList = null
}) {
  return {
    isSuccess,
    key,
    message,
    paging: paging ?? defaultPaging(),
    data,
    dataList
  };
}

module.exports = {
  buildResponse
};

