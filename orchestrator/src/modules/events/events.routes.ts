import { Router } from "express";
import { prisma } from "../../db/client.js";

export const eventsRouter = Router();

eventsRouter.get("/", async (_req, res) => {
  const events = await prisma.systemEvent.findMany({
    orderBy: { createdAt: "desc" },
    take: 200
  });
  res.json(events);
});
