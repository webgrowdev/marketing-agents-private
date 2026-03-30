import dotenv from "dotenv";
import { z } from "zod";

dotenv.config({ path: process.env.ENV_FILE ?? ".env" });

const schema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().default(4000),
  DATABASE_URL: z.string().min(1),
  REDIS_URL: z.string().min(1),
  OPENCLAW_BASE_URL: z.string().url(),
  OPENCLAW_API_KEY: z.string().min(1),
  OPENCLAW_TIMEOUT_MS: z.coerce.number().default(120000),
  TELEGRAM_BOT_TOKEN: z.string().min(1),
  TELEGRAM_CHAT_ID: z.string().min(1),
  CRON_DAILY_BRIEF: z.string().default("0 8 * * *"),
  CRON_CAMPAIGN_REVIEW: z.string().default("0 12 * * *"),
  CRON_BLOCKED_CHECK: z.string().default("*/30 * * * *"),
  CRON_EXEC_SUMMARY: z.string().default("0 18 * * *")
});

export const env = schema.parse(process.env);
