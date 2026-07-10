const bcrypt = require('bcryptjs');
const { Company } = require('../models');

async function registerCompany({ name, email, password }) {
  const existing = await Company.findOne({ email: String(email).toLowerCase() });
  if (existing) {
    const error = new Error('Email is already used.');
    error.statusCode = 409;
    throw error;
  }

  const hashedPassword = await bcrypt.hash(password, 10);
  const company = await Company.create({
    name,
    email,
    password: hashedPassword
  });

  return company;
}

async function authenticateCompany({ email, password }) {
  const company = await Company.findOne({ email: String(email).toLowerCase() });
  if (!company) {
    return null;
  }

  const valid = await bcrypt.compare(password, company.password);
  if (!valid) {
    return null;
  }

  return company;
}

module.exports = {
  registerCompany,
  authenticateCompany
};
