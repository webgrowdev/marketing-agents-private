import { TaskStatus } from "@prisma/client";
import { Router } from "express";
import { prisma } from "../../db/client.js";

export const metricsRouter = Router();

metricsRouter.get("/overview", async (_req, res) => {
  const total = await prisma.task.count();
  const completed = await prisma.task.count({ where: { status: TaskStatus.completed } });
  const failed = await prisma.task.count({ where: { status: TaskStatus.failed } });
  const blocked = await prisma.task.count({ where: { status: TaskStatus.blocked } });
  const throughput = await prisma.task.count({
    where: { status: TaskStatus.completed, finishedAt: { gte: new Date(Date.now() - 24 * 3600 * 1000) } }
  });

  const avgDuration = await prisma.taskRun.aggregate({ _avg: { durationMs: true } });
  const perAgent = await prisma.task.groupBy({ by: ["agentId"], _count: { id: true }, where: { status: TaskStatus.completed } });

  res.json({
    total,
    successRate: total ? completed / total : 0,
    failedRate: total ? failed / total : 0,
    blockedTasks: blocked,
    throughput,
    averageCompletionTimeMs: avgDuration._avg.durationMs ?? 0,
    tasksCompletedPerAgent: perAgent
  });
});
