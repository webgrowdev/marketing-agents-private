import { Queue } from "bullmq";
import IORedis from "ioredis";
import { env } from "../config/env.js";

export const connection = new IORedis(env.REDIS_URL, { maxRetriesPerRequest: null });

export const taskQueue = new Queue("agent-tasks", { connection });
