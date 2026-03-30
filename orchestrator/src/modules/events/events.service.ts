import { EventSeverity } from "@prisma/client";
import { prisma } from "../../db/client.js";

export async function logEvent(input: {
  type: string;
  severity: EventSeverity;
  message: string;
  campaignId?: string;
  taskId?: string;
  metadata?: unknown;
}) {
  return prisma.systemEvent.create({ data: input });
}
