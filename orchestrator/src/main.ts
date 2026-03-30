import cors from "cors";
import express from "express";
import pinoHttp from "pino-http";
import { env } from "./config/env.js";
import { logger } from "./lib/logger.js";
import { campaignsRouter } from "./modules/campaigns/campaigns.routes.js";
import { tasksRouter } from "./modules/tasks/tasks.routes.js";
import { agentsRouter } from "./modules/agents/agents.routes.js";
import { metricsRouter } from "./modules/metrics/metrics.routes.js";
import { eventsRouter } from "./modules/events/events.routes.js";
import { healthRouter } from "./modules/health/health.routes.js";
import { taskWorker } from "./jobs/task.worker.js";
import { startScheduler } from "./jobs/scheduler.js";

const app = express();
app.use(cors());
app.use(express.json({ limit: "2mb" }));
app.use(pinoHttp({ logger }));

app.use("/health", healthRouter);
app.use("/campaigns", campaignsRouter);
app.use("/tasks", tasksRouter);
app.use("/agents", agentsRouter);
app.use("/metrics", metricsRouter);
app.use("/events", eventsRouter);

app.listen(env.PORT, () => {
  logger.info({ port: env.PORT }, "Orchestrator started");
  startScheduler();
});

process.on("SIGTERM", async () => {
  await taskWorker.close();
  process.exit(0);
});
