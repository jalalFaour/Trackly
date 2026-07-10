const mongoose = require('mongoose');


const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true },
  password: { type: String, required: true },
  balance: { type: Number, required: true, default: 0 } // Stored in cents (integer)
});


module.exports = mongoose.model('User', userSchema);
