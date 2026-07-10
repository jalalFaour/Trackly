function requireSessionAuth(req, res, next) {
  if (!req.session.companyId) {
    // SSE/API routes must not redirect (redirect breaks EventSource stream)
    if (req.headers.accept && req.headers.accept.includes('text/event-stream')) {
      return res.status(401).end();
    }

    return res.redirect('/auth/login');
  }

  return next();
}


function exposeSessionToViews(req, res, next) {
  res.locals.currentCompany = req.session.company || null;
  res.locals.authError = req.session.authError || null;
  res.locals.authSuccess = req.session.authSuccess || null;
  // Used by EJS layouts/partials (e.g. sidebar active link)
  res.locals.currentPath = req.path;
  delete req.session.authError;
  delete req.session.authSuccess;
  next();
}

module.exports = {
  requireSessionAuth,
  exposeSessionToViews
};
