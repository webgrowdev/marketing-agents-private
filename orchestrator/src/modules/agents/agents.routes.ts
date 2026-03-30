import { Router } from "express";
import { prisma } from "../../db/client.js";

export const agentsRouter = Router();

agentsRouter.get("/", async (_req, res) => {
  const agents = await prisma.agent.findMany({
    include: {
      tasks: true,
      runs: { orderBy: { startedAt: "desc" }, take: 5 }
    }
  });
  res.json(agents);
});

agentsRouter.get("/:slug", async (req, res) => {
  const agent = await prisma.agent.findUnique({
    where: { slug: req.params.slug },
    include: {
      tasks: { orderBy: { createdAt: "desc" }, take: 25 },
      runs: { orderBy: { startedAt: "desc" }, take: 25 },
      logs: { orderBy: { createdAt: "desc" }, take: 25 }
    }
  });
  if (!agent) return res.status(404).json({ error: "Agent not found" });
  res.json(agent);
});
