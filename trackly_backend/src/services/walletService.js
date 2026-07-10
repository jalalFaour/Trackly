const mongoose = require('mongoose');
const { User, Transaction, Bus } = require('../models');

/**
 * Add credit to a user's account (Top-up)
 */
async function addCredit(userId, amountInPounds, purpose = 'wallet_topup') {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    // 1. Increment user balance
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { $inc: { balance: amountInPounds } },
      { new: true, session }
    );

    if (!updatedUser) throw new Error('User not found');

    // 2. Log the credit transaction
    await Transaction.create([{
      userId,
      type: 'credit',
      amount: amountInPounds,
      purpose
    }], { session });

    await session.commitTransaction();
    return updatedUser;
  } catch (error) {
    await session.abortTransaction();
    throw error;
  } finally {
    session.endSession();
  }
}

/**
 * Deduct a micropayment charge from a user's account
 */
async function deductCredit(userId, amountInPounds, purpose, busId = null) {
  const session = await mongoose.startSession();
  session.startTransaction();

  console.log('Deducting credit:', { userId, amountInPounds, purpose, busId });

  try {
    // 1. Atomic conditional update: only deduct if balance >= amount
    const updatedUser = await User.findOneAndUpdate(
      { 
        _id: userId, 
        balance: { $gte: amountInPounds } 
      },
      { $inc: { balance: -amountInPounds } },
      { new: true, session }
    );

    // If no document matched, it means insufficient funds or user doesn't exist
    if (!updatedUser) {
      throw new Error('Insufficient funds or user not found');
    }

    const bus = await Bus.findById(busId).select('routeId').lean().exec();

    // 2. Log the debit transaction
    await Transaction.create([{
      userId,
      type: 'debit',
      amount: amountInPounds,
      busId,
      routeId: bus.routeId,
      purpose
    }], { session });

    await session.commitTransaction();
    return updatedUser;
  } catch (error) {
    await session.abortTransaction();
    throw error;
  } finally {
    session.endSession();
  }
}

module.exports = { addCredit, deductCredit };