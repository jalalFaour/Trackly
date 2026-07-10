const mongoose = require('mongoose');

const locationLogSchema = new mongoose.Schema(
  {
    busId: { type: mongoose.Schema.Types.ObjectId, ref: 'Bus', required: true, index: true },
    location: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: { type: [Number], default: [0, 0] }
    },
    speed: { type: Number, default: 0 },
    timestamp: { type: Date, default: Date.now, expires: '7d' }
  },
  { timestamps: true }
);

module.exports = mongoose.model('LocationLog', locationLogSchema);
