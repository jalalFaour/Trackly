const mongoose = require('mongoose');
const { Transaction, Route } = require('../models');

function parseDateOrDefault(d, fallbackDate) {
  if (!d) return fallbackDate;
  const dt = new Date(d);
  return Number.isFinite(dt.getTime()) ? dt : fallbackDate;
}

function boundsFromRange({ from, to }) {
  const now = new Date();
  const defaultFrom = new Date(now);
  defaultFrom.setDate(defaultFrom.getDate() - 30);
  const defaultTo = now;

  const fromDate = parseDateOrDefault(from, defaultFrom);
  const toDate = parseDateOrDefault(to, defaultTo);

  return { fromDate, toDate };
}

async function getCompanyRevenueAnalytics({ companyId, from, to }) {
  if (!companyId) throw new Error('companyId is required');

  const { fromDate, toDate } = boundsFromRange({ from, to });

  // Company revenue = total revenue income for this company.
  // In this system, route payments are recorded as Transaction.type = 'debit'.
  const [row] = await Transaction.aggregate([
    {
      $match: {
        type: 'debit',
        timestamp: { $gte: fromDate, $lte: toDate },
        routeId: { $ne: null }
      }
    },
    {
      $lookup: {
        from: 'routes',
        localField: 'routeId',
        foreignField: '_id',
        as: 'route'
      }
    },
    {
      $unwind: {
        path: '$route',
        preserveNullAndEmptyArrays: false
      }
    },
    {
      $match: {
        'route.companyId': new mongoose.Types.ObjectId(companyId)
      }
    },
    {
      $group: {
        _id: null,
        revenue: { $sum: '$amount' },
        transactionsCount: { $sum: 1 }
      }
    },
    {
      $project: {
        _id: 0,
        revenue: 1,
        transactionsCount: 1
      }
    }
  ]);

  return {
    from: fromDate,
    to: toDate,
    ...(row || { revenue: 0, transactionsCount: 0 })
  };
}

async function getRouteRevenueAnalytics({ companyId, from, to, limit = 1000 }) {
  if (!companyId) throw new Error('companyId is required');

  const { fromDate, toDate } = boundsFromRange({ from, to });

  // Revenue by route = total revenue income for each route for this company.
  const rows = await Transaction.aggregate([
    {
      $match: {
        type: 'debit',
        timestamp: { $gte: fromDate, $lte: toDate },
        routeId: { $ne: null }
      }
    },
    {
      $lookup: {
        from: 'routes',
        localField: 'routeId',
        foreignField: '_id',
        as: 'route'
      }
    },
    {
      $unwind: {
        path: '$route',
        preserveNullAndEmptyArrays: false
      }
    },
    {
      $match: {
        'route.companyId': new mongoose.Types.ObjectId(companyId)
      }
    },
    {
      $group: {
        _id: '$routeId',
        revenue: { $sum: '$amount' },
        transactionsCount: { $sum: 1 }
      }
    },
    {
      $lookup: {
        from: 'routes',
        localField: '_id',
        foreignField: '_id',
        as: 'routeDoc'
      }
    },
    { $unwind: '$routeDoc' },
    {
      $project: {
        _id: 0,
        routeId: '$_id',
        routeName: '$routeDoc.routeName',
        revenue: 1,
        transactionsCount: 1
      }
    },
    {
      $sort: { revenue: -1 }
    },
    {
      $limit: Number(limit)
    }
  ]);

  return {
    from: fromDate,
    to: toDate,
    routes: rows
  };
}

module.exports = {
  getCompanyRevenueAnalytics,
  getRouteRevenueAnalytics
};

