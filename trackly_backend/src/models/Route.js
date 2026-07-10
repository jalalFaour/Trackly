const mongoose = require('mongoose');

const stopSchema = new mongoose.Schema(
  {
    // Admin-only stop label (e.g., “Stop 1”, “Main Square”)
    name: { type: String, trim: true, default: '' },

    // Ordering within the route
    order: { type: Number, default: 0 },

    // Location as GeoJSON Point
    location: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: { type: [Number], default: [0, 0] }
    }
  },
  { _id: false }
);


const routeSchema = new mongoose.Schema(
  {
    companyId: { type: mongoose.Schema.Types.ObjectId, ref: 'Company', required: true, index: true },
    routeName: { type: String, required: true, trim: true },

    // Total computed length of the route polyline (sum of segment distances)
    // Stored as kilometers.
    routeLengthKm: { type: Number, default: 0 },

    path: {
      type: { type: String, enum: ['LineString'], default: 'LineString' },
      coordinates: { type: [[Number]], default: [] }
    },
    stops: { type: [stopSchema], default: [] }
  },
  { timestamps: true }
);

routeSchema.index({ path: '2dsphere' });

module.exports = mongoose.model('Route', routeSchema);
