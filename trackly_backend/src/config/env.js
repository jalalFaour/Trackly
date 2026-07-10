const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(process.cwd(), '.env') });

const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: Number(process.env.PORT || 3000),
  mongoUri: process.env.MONGO_URI || '',

  sessionSecret: process.env.SESSION_SECRET || 'change-this-in-env',
  telegramBotToken: process.env.TELEGRAM_BOT_TOKEN || '',
  telegramDefaultChatId: process.env.TELEGRAM_DEFAULT_CHAT_ID || '',

  // Mobile demo payment price (stored in cents)
  DEDUCT_PRICE_IN_POUNDS: Number(process.env.DEDUCT_PRICE_IN_POUNDS || 25),

  JWT_ACCESS_SECRET: process.env.JWT_ACCESS_SECRET || 'change-this-access-secret',
  JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET || 'change-this-refresh-secret',
  JWT_ACCESS_EXPIRES_IN: process.env.JWT_ACCESS_EXPIRES_IN || '15d',
  JWT_REFRESH_EXPIRES_IN: process.env.JWT_REFRESH_EXPIRES_IN || '30d'
};


module.exports = env;
