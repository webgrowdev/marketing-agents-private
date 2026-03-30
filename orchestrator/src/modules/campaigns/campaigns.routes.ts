import { Router } from "express";
import { prisma } from "../../db/client.js";
import { logEvent } from "../events/events.service.js";
import { sendTelegramMessage } from "../../telegram/telegram.service.js";
import { telegramTemplates } from "../../telegram/templates.js";

export const campaignsRouter = Router();

campaignsRouter.get("/", async (_req, res) => {
  const campaigns = await prisma.campaign.findMany({ orderBy: { createdAt: "desc" } });
  res.json(campaigns);
});

campaignsRouter.post("/", async (req, res) => {
  const campaign = await prisma.campaign.create({ data: req.body });
  await logEvent({
    type: "campaign.started",
    severity: "info",
    message: `Campaign ${campaign.name} started`,
    campaignId: campaign.id
  });
  await sendTelegramMessage(telegramTemplates.campaignStarted(campaign.name));
  res.status(201).json(campaign);
});
