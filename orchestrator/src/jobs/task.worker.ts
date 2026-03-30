import { TaskStatus } from "@prisma/client";
import { Worker } from "bullmq";
import { prisma } from "../db/client.js";
import { connection } from "./queue.js";
import { triggerAgentTask } from "../services/openclaw.service.js";
import { logEvent } from "../modules/events/events.service.js";
import { sendTelegramMessage } from "../telegram/telegram.service.js";
import { telegramTemplates } from "../telegram/templates.js";

export const taskWorker = new Worker(
  "agent-tasks",
  async (job) => {
    const task = await prisma.task.findUnique({ where: { id: job.data.taskId }, include: { agent: true, campaign: true } });
    if (!task) throw new Error("Task not found");

    await prisma.task.update({ where: { id: task.id }, data: { status: TaskStatus.running, startedAt: new Date() } });

    try {
      const response = await triggerAgentTask({
        agentSlug: task.agent.slug,
        taskId: task.id,
        title: task.title,
        description: task.description,
        payload: task.payload
      });

      await prisma.taskRun.create({
        data: {
          taskId: task.id,
          agentId: task.agentId,
          status: TaskStatus.running,
          openclawRunId: response.runId,
          output: response.output
        }
      });

      await logEvent({ type: "task.dispatched", severity: "info", message: `Task ${task.id} dispatched to ${task.agent.slug}`, campaignId: task.campaignId, taskId: task.id });
      return response;
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown worker error";
      await prisma.task.update({ where: { id: task.id }, data: { status: TaskStatus.failed, retries: { increment: 1 } } });
      await prisma.taskLog.create({ data: { taskId: task.id, agentId: task.agentId, level: "error", message } });
      await logEvent({ type: "task.failed", severity: "critical", message, campaignId: task.campaignId, taskId: task.id });
      await sendTelegramMessage(telegramTemplates.criticalError(`Task ${task.title} failed: ${message}`));
      throw error;
    }
  },
  { connection }
);
