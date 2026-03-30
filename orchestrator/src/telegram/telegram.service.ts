import axios from "axios";
import { env } from "../config/env.js";

const telegramApi = axios.create({
  baseURL: `https://api.telegram.org/bot${env.TELEGRAM_BOT_TOKEN}`
});

export async function sendTelegramMessage(text: string) {
  await telegramApi.post("/sendMessage", {
    chat_id: env.TELEGRAM_CHAT_ID,
    text,
    parse_mode: "Markdown"
  });
}
