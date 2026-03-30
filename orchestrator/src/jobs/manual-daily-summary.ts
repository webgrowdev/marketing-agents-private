import { TaskStatus } from "@prisma/client";
import { prisma } from "../db/client.js";
import { sendTelegramMessage } from "../telegram/telegram.service.js";

const completed = await prisma.task.count({ where: { status: TaskStatus.completed } });
const failed = await prisma.task.count({ where: { status: TaskStatus.failed } });
const blocked = await prisma.task.count({ where: { status: TaskStatus.blocked } });

await sendTelegramMessage(`📊 Resumen manual\nCompletadas: ${completed}\nFallidas: ${failed}\nBloqueadas: ${blocked}`);
console.log("Manual summary sent");
process.exit(0);
