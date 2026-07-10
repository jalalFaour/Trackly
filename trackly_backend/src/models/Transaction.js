const mongoose = require('mongoose');

// Transaction Schema
const transactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  type: { type: String, enum: ['credit', 'debit'], required: true },
  amount: { type: Number, required: true }, // Stored in pounds
  busId: { type : mongoose.Schema.Types.ObjectId, ref: 'Bus' }, // Optional reference to a bus
  routeId: {type : mongoose.Schema.Types.ObjectId, ref: 'Route'},
  purpose: { type: String, required: true },
  timestamp: { type: Date, default: Date.now }
});


// Compound index for quick ledger lookups per user
transactionSchema.index({ userId: 1, timestamp: -1 });

module.exports = mongoose.model('Transaction', transactionSchema);
