const asyncHandler = require('../utils/asyncHandler');
const { buildResponse } = require('../utils/mobileResponse');
const mobileAppService = require('../services/mobileAppService');

function getKeyFromError(err) {
  return err && err.statusCode ? `ERR_${err.statusCode}` : 'ERR_UNKNOWN';
}

function handleError(err, res) {
  console.log('Error in mobileAppController:', err);
  const statusCode = err.statusCode || 500;
  return res.status(statusCode).json(
    buildResponse({
      isSuccess: false,
      key: getKeyFromError(err),
      message: err.message || 'Internal Server Error',
      paging: null,
      data: null,
      dataList: null
    })
  );

}

const signup = asyncHandler(async (req, res) => {
  try {
    const { name, phone, password } = req.body;
    await mobileAppService.signup({ name, phone, password });

    return res.json(
      buildResponse({
        isSuccess: true,
        key: 'SIGNUP_SUCCESS',
        message: 'Signup successful',
        paging: null,
        data: { success: true },
        dataList: null
      })
    );
  } catch (err) {
    return handleError(err, res);
  }
});

const login = asyncHandler(async (req, res) => {
  try {
    const { phone, password } = req.body;
    const { user, tokens } = await mobileAppService.login({ phone, password });

    return res.json(
      buildResponse({
        isSuccess: true,
        key: 'LOGIN_SUCCESS',
        message: 'Login successful',
        paging: null,
        data: {
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          user: { id: String(user._id), name: user.name, phone: user.phone, balance: user.balance }
        },
        dataList: null
      })
    );
  } catch (err) {
    return handleError(err, res);
  }
});

const profile = asyncHandler(async (req, res) => {
  try {
    const profileData = await mobileAppService.getProfile(req.mobileUserId);

    return res.json(
      buildResponse({
        isSuccess: true,
        key: 'PROFILE_SUCCESS',
        message: 'Profile fetched',
        paging: null,
        data: profileData,
        dataList: null
      })
    );
  } catch (err) {
    return handleError(err, res);
  }
});

const addCredit = asyncHandler(async (req, res) => {
  try {
    const { amount } = req.body; // amount in Syrian pounds (integer)
    console.log('Received amount:', amount);
    if (amount === undefined || amount === null) {
      const err = new Error('amount is required');
      err.statusCode = 400;
      throw err;
    }

    const data = await mobileAppService.addCreditDemo({
      userId: req.mobileUserId,
      amountInPounds: amount
    });

    return res.json(
      buildResponse({
        isSuccess: true,
        key: 'ADD_CREDIT_SUCCESS',
        message: 'Credit added',
        paging: null,
        data,
        dataList: null
      })
    );
  } catch (err) {
    return handleError(err, res);
  }
});

const deductCredit = asyncHandler(async (req, res) => {
  try {
    const { busId } = req.body;
    if (!busId) {
      const err = new Error('busId is required');
      err.statusCode = 400;
      throw err;
    }

    const data = await mobileAppService.deductForBus({
      userId: req.mobileUserId,
      busId
    });

    return res.json(
      buildResponse({
        isSuccess: true,
        key: 'DEDUCT_SUCCESS',
        message: 'Credit deducted',
        paging: null,
        data,
        dataList: null
      })
    );
  } catch (err) {
    return handleError(err, res);
  }
});

const deductPrice = asyncHandler(async (req, res) => {
  try {
    const priceInPounds = mobileAppService.getDeductPriceInPounds();

    return res.json(
      buildResponse({
        isSuccess: true,
        key: 'DEDUCT_PRICE_SUCCESS',
        message: 'Deduct price fetched',
        paging: null,
        data: { priceInPounds },
        dataList: null
      })
    );
  } catch (err) {
    return handleError(err, res);
  }
});

const getAllCompaniesRoutes = asyncHandler(async (req, res) => {
  try {
    const routes = await mobileAppService.getAllCompaniesRoutes();

    return res.json(
      buildResponse({
        isSuccess: true,
        key: 'GET_ALL_ROUTES_SUCCESS',
        message: 'Routes fetched',
        paging: null,
        data: null,
        dataList: routes
        // {
        //   routes,
        //   // count: routes.length
        // }
      })
    );
  } catch (err) {
    return handleError(err, res);
  }
});

const getBalance = asyncHandler(async (req, res) => {
  try {
    const result = await mobileAppService.getBalanceAndTransactions(req.mobileUserId);

    return res.json(
      buildResponse({
        isSuccess: true,
        key: 'GET_BALANCE_SUCCESS',
        message: 'Balance fetched',
        paging: null,
        data: { balance: result.balance, transactions: result.dataList },
        dataList: null
      })
    );
  } catch (err) {
    return handleError(err, res);
  }
});

module.exports = {
  signup,
  login,
  profile,
  addCredit,
  deductCredit,
  deductPrice,
  getAllCompaniesRoutes,
  getBalance
};







