import cron from "node-cron";
import { TaskStatus } from "@prisma/client";
import { env } from "../config/env.js";
import { prisma } from "../db/client.js";
import { sendTelegramMessage } from "../telegram/telegram.service.js";
import { telegramTemplates } from "../telegram/templates.js";

export function startScheduler() {
  cron.schedule(env.CRON_DAILY_BRIEF, async () => {
    const completed = await prisma.task.count({ where: { status: TaskStatus.completed, finishedAt: { gte: new Date(Date.now() - 24 * 3600 * 1000) } } });
    const failed = await prisma.task.count({ where: { status: TaskStatus.failed, updatedAt: { gte: new Date(Date.now() - 24 * 3600 * 1000) } } });
    await sendTelegramMessage(telegramTemplates.dailySummary(`Completadas: ${completed}\nFallidas: ${failed}\nPróximo paso: revisar bloqueos.`));
  });

  cron.schedule(env.CRON_BLOCKED_CHECK, async () => {
    const blocked = await prisma.task.findMany({ where: { status: TaskStatus.blocked }, take: 10, include: { agent: true } });
    for (const task of blocked) {
      await sendTelegramMessage(telegramTemplates.agentBlocked(task.agent.slug, task.title));
    }
  });

  cron.schedule(env.CRON_CAMPAIGN_REVIEW, async () => {
    const active = await prisma.campaign.count({ where: { status: "active" } });
    await sendTelegramMessage(`🧭 Revisión campañas: ${active} campañas activas.`);
  });

  cron.schedule(env.CRON_EXEC_SUMMARY, async () => {
    const campaigns = await prisma.campaign.findMany({ where: { status: "active" }, take: 5 });
    await sendTelegramMessage(`📌 Resumen ejecutivo\nActivas: ${campaigns.length}\nSugerencia: cerrar pendientes críticas.`);
  });
}
