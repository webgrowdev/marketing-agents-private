import axios from "axios";
import { env } from "../config/env.js";

const openclaw = axios.create({
  baseURL: env.OPENCLAW_BASE_URL,
  timeout: env.OPENCLAW_TIMEOUT_MS,
  headers: {
    Authorization: `Bearer ${env.OPENCLAW_API_KEY}`,
    "Content-Type": "application/json"
  }
});

export async function triggerAgentTask(input: {
  agentSlug: string;
  taskId: string;
  title: string;
  description: string;
  payload: unknown;
}) {
  const response = await openclaw.post("/hooks/agent-task", input);
  return response.data as { runId: string; status: string; output?: string };
}
