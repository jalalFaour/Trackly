const axios = require('axios');
const env = require('../config/env');

async function sendTelegramMessage({ chatId, text }) {
  if (!env.telegramBotToken) {
    const error = new Error('Missing TELEGRAM_BOT_TOKEN in environment.');
    error.statusCode = 500;
    throw error;
  }

  const finalChatId = chatId || env.telegramDefaultChatId;
  if (!finalChatId) {
    const error = new Error('chatId is required or set TELEGRAM_DEFAULT_CHAT_ID.');
    error.statusCode = 400;
    throw error;
  }

  const url = `https://api.telegram.org/bot${env.telegramBotToken}/sendMessage`;
  const response = await axios.post(url, {
    chat_id: finalChatId,
    text
  });

  return response.data;
}

module.exports = {
  sendTelegramMessage
};
