import { Router } from "express";
import { prisma } from "../../db/client.js";
import { enqueueTask } from "./tasks.service.js";

export const tasksRouter = Router();

tasksRouter.get("/", async (_req, res) => {
  const tasks = await prisma.task.findMany({ include: { agent: true, campaign: true }, orderBy: { createdAt: "desc" } });
  res.json(tasks);
});

tasksRouter.post("/", async (req, res) => {
  const task = await prisma.task.create({ data: req.body });
  res.status(201).json(task);
});

tasksRouter.post("/:id/queue", async (req, res) => {
  const result = await enqueueTask(req.params.id);
  res.json(result);
});

// webhook from OpenClaw with run output
tasksRouter.post("/:id/openclaw-result", async (req, res) => {
  const { status, output, errorMessage, durationMs, openclawRunId } = req.body;
  const taskId = req.params.id;
  const task = await prisma.task.update({
    where: { id: taskId },
    data: {
      status,
      finishedAt: new Date(),
      blockedReason: status === "blocked" ? errorMessage : null
    },
    include: { agent: true, campaign: true }
  });

  await prisma.taskRun.create({
    data: {
      taskId,
      agentId: task.agentId,
      status,
      output,
      errorMessage,
      durationMs,
      openclawRunId,
      finishedAt: new Date()
    }
  });

  await prisma.taskLog.create({
    data: {
      taskId,
      agentId: task.agentId,
      level: status === "failed" ? "error" : "info",
      message: output ?? errorMessage ?? "Task updated from OpenClaw"
    }
  });

  res.json({ ok: true });
});
