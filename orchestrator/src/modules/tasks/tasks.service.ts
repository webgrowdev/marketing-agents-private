import { TaskStatus } from "@prisma/client";
import { prisma } from "../../db/client.js";
import { taskQueue } from "../../jobs/queue.js";

export async function enqueueTask(taskId: string) {
  const task = await prisma.task.findUnique({ where: { id: taskId }, include: { dependsOn: true } });
  if (!task) throw new Error("Task not found");

  if (task.dependsOn && task.dependsOn.status !== TaskStatus.completed) {
    await prisma.task.update({
      where: { id: taskId },
      data: { status: TaskStatus.blocked, blockedReason: `Dependency ${task.dependsOn.id} not completed` }
    });
    return { blocked: true };
  }

  await prisma.task.update({ where: { id: taskId }, data: { status: TaskStatus.queued, queuedAt: new Date() } });
  await taskQueue.add("agent-task", { taskId }, { attempts: task.maxRetries + 1, priority: task.priority });
  return { queued: true };
}
