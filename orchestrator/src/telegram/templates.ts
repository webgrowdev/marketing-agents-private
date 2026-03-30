export const telegramTemplates = {
  campaignStarted: (campaign: string) => `🚀 Campaña iniciada: *${campaign}*`,
  campaignCompleted: (campaign: string) => `✅ Campaña completada: *${campaign}*`,
  agentBlocked: (agent: string, task: string) => `⛔ Agente bloqueado: *${agent}*\nTarea: ${task}`,
  criticalError: (msg: string) => `🔥 Error crítico\n${msg}`,
  dailySummary: (summary: string) => `📊 Resumen ejecutivo diario\n${summary}`
};
