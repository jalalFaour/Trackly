const mongoose = require('mongoose');
const env = require('./env');

async function connectDatabase() {
  if (!env.mongoUri) {
    throw new Error(
      'MONGO_URI is missing. Set it in .env (example: mongodb+srv://<user>:<pass>@<cluster>.mongodb.net/<db>?retryWrites=true&w=majority)'
    );
  }

  // Helpful options for Atlas SRV connections.
  await mongoose.connect(env.mongoUri);

  console.log('Connected to MongoDB');
}


module.exports = { connectDatabase };
