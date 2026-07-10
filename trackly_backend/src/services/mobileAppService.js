const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const env = require('../config/env');
const { User } = require('../models');
const { Transaction } = require('../models');
const walletService = require('./walletService');

function centsFromSYR(value) {
  const num = Number(value);
  if (!Number.isFinite(num) || num < 0) {
    const err = new Error('Amount must be a valid non-negative number');
    err.statusCode = 400;
    throw err;
  }
  // Input is in Syrian pounds. Store in cents.
  return num;
}

function buildTokens({ userId }) {
  const accessToken = jwt.sign(
    { sub: userId },
    env.JWT_ACCESS_SECRET,
    { expiresIn: env.JWT_ACCESS_EXPIRES_IN }
  );

  const refreshToken = jwt.sign(
    { sub: userId },
    env.JWT_REFRESH_SECRET,
    { expiresIn: env.JWT_REFRESH_EXPIRES_IN }
  );

  return { accessToken, refreshToken };
}

async function signup({ name, phone, password }) {
  if (!name || !phone || !password) {
    const err = new Error('name, phone and password are required');
    err.statusCode = 400;
    throw err;
  }

  const phoneStr = String(phone).trim();
  const existing = await User.findOne({ phone: phoneStr });
  if (existing) {
    const err = new Error('phone is already registered');
    err.statusCode = 409;
    throw err;
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  const user = await User.create({
    name: String(name).trim(),
    phone: phoneStr,
    password: hashedPassword,
    balance: 0
  });

  return user;
}

async function login({ phone, password }) {
  if (!phone || !password) {
    const err = new Error('phone and password are required');
    err.statusCode = 400;
    throw err;
  }

  const phoneStr = String(phone).trim();
  const user = await User.findOne({ phone: phoneStr });
  if (!user) {
    const err = new Error('Invalid phone or password');
    err.statusCode = 401;
    throw err;
  }

  const valid = await bcrypt.compare(password, user.password);
  if (!valid) {
    const err = new Error('Invalid phone or password');
    err.statusCode = 401;
    throw err;
  }

  const tokens = buildTokens({ userId: String(user._id) });
  return { user, tokens };
}

async function getProfile(userId) {
  const user = await User.findById(userId).select('name phone balance');
  if (!user) {
    const err = new Error('User not found');
    err.statusCode = 404;
    throw err;
  }

  return {
    user: {
      id: String(user._id),
      name: user.name,
      phone: user.phone
    },
    balance: user.balance
  };
}

async function addCreditDemo({ userId, amountInPounds }) {
  const amountInCents = centsFromSYR(amountInPounds);

  // Demo: no card info storage and no validation.
  const updatedUser = await walletService.addCredit(userId, amountInCents, 'wallet_topup_demo');
  return { balance: updatedUser.balance };
}

async function deductForBus({ userId, busId, amountInPounds = null }) {
  // Task says deduct price comes from .env variable.

  const amountToDeduct = amountInPounds != null
    ? amountInPounds
    : getDeductPriceInPounds();

  console.log('Deducting for bus payment:', { userId, busId, amountToDeduct });

  const updatedUser = await walletService.deductCredit(
    userId,
    amountToDeduct,
    'bus_payment',
    busId || null
  );

  return { balance: updatedUser.balance, deductedAmount: amountToDeduct };
}

function getDeductPriceInPounds() {
  return env.DEDUCT_PRICE_IN_POUNDS;
}

const { listPublicRoutes } = require('./busService');

async function getAllCompaniesRoutes() {
  // Returns routes from ALL companies (no companyId filter)
  return listPublicRoutes();
}

async function getBalanceAndTransactions(userId) {
  const [user, transactions] = await Promise.all([
    User.findById(userId).select('balance'),
    Transaction.find({ userId })
      .sort({ timestamp: -1 })
  ]);

  if (!user) {
    const err = new Error('User not found');
    err.statusCode = 404;
    throw err;
  }

  const dataList = transactions.map((t) => ({
    id: String(t._id),
    type: t.type,
    amount: t.amount,
    busId: t.busId ? String(t.busId) : null,
    purpose: t.purpose,
    timestamp: t.timestamp
  }));

  return {
    balance: user.balance,
    dataList
  };
}

module.exports = {
  signup,
  login,
  getProfile,
  addCreditDemo,
  deductForBus,
  getDeductPriceInPounds,
  buildTokens,
  getAllCompaniesRoutes,
  getBalanceAndTransactions
};








