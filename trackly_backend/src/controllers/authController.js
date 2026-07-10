const { authenticateCompany, registerCompany } = require('../services/authService');
const asyncHandler = require('../utils/asyncHandler');

const showLoginPage = (req, res) => {
  if (req.session.companyId) {
    return res.redirect('/');
  }

  return res.render('auth-login');
};

const showRegisterPage = (req, res) => {
  if (req.session.companyId) {
    return res.redirect('/');
  }

  return res.render('auth-register');
};

const register = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    req.session.authError = 'name, email and password are required.';
    return res.redirect('/auth/register');
  }

  try {
    const company = await registerCompany({ name, email, password });
    req.session.authSuccess = `Company created. API secret: ${company.apiSecret}`;
    return res.redirect('/auth/login');
  } catch (error) {
    req.session.authError = error.message;
    return res.redirect('/auth/register');
  }
});

const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  const company = await authenticateCompany({ email, password });

  if (!company) {
    req.session.authError = 'Invalid email or password.';
    return res.redirect('/auth/login');
  }

  req.session.companyId = String(company._id);
  req.session.company = {
    id: String(company._id),
    name: company.name,
    email: company.email
  };

  return res.redirect('/');
});

const logout = (req, res) => {
  req.session.destroy(() => {
    res.redirect('/auth/login');
  });
};

module.exports = {
  showLoginPage,
  showRegisterPage,
  register,
  login,
  logout
};
