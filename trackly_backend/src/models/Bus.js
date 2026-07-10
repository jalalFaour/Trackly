const mongoose = require('mongoose');

const busSchema = new mongoose.Schema(
  {
    companyId: { type: mongoose.Schema.Types.ObjectId, ref: 'Company', required: true, index: true },
    routeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Route', default: null },
    deviceId: { type: String, unique: true, required: true, trim: true },
    busNumber: { type: String, required: true, trim: true },
    status: {
      type: String,
      enum: ['active', 'idle', 'maintenance'],
      default: 'idle'
    },
    lastLocation: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: { type: [Number], default: [0, 0] }
    },
    lastUpdate: { type: Date, default: Date.now }
  },
  { timestamps: true }
);

busSchema.index({ lastLocation: '2dsphere' });

module.exports = mongoose.model('Bus', busSchema);
