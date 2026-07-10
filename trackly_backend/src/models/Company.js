const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const companySchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, unique: true, required: true, lowercase: true, trim: true },
    password: { type: String, required: true },
    apiSecret: { type: String, default: () => uuidv4() }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Company', companySchema);
