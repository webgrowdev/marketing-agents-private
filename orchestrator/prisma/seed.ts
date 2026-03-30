import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const baseAgents = [
  "seo-content",
  "cro",
  "content-copy",
  "paid-measurement",
  "growth-retention",
  "sales-gtm",
  "strategy",
  "motion-pro",
  "marketing-pm",
  "executive-reporter"
];

async function main() {
  for (const slug of baseAgents) {
    await prisma.agent.upsert({
      where: { slug },
      update: {},
      create: {
        slug,
        displayName: slug.replace(/-/g, " "),
        workspacePath: `~/.openclaw/workspaces/${slug}`,
        openclawBinding: `agent:${slug}`
      }
    });
  }
}

main().finally(async () => {
  await prisma.$disconnect();
});
