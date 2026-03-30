# Arquitectura final del stack

## Capas
1. **OpenClaw Runtime**: ejecuta agentes aislados por workspace (`~/.openclaw/workspaces/<agent>`).
2. **Orchestrator (Node.js + TS + Express)**: control central de campañas/tareas, estados, dependencias, retries, eventos y webhooks OpenClaw.
3. **Jobs Layer (BullMQ + Redis + cron)**: cola, reintentos, y automatización programada (daily brief, campaign review, blocked checks, executive summary).
4. **Data Layer (PostgreSQL + Prisma)**: campañas, tareas, runs, logs, eventos, métricas.
5. **Executive Reporting (Telegram Bot API)**: alertas críticas y reportes diarios/manuales.
6. **Dashboard (Next.js + Tailwind)**: vistas CEO, PM, agentes, activity feed, métricas.

## Aislamiento OpenClaw
- Cada agente se sincroniza con `scripts/sync_to_openclaw.sh`.
- Registro declarativo en `openclaw/agents.registry.yaml`.
- Binding por agente `agent:<slug>` y callback por tarea.

## Flujo operacional
1. PM crea campaña.
2. PM/API crea tareas con dependencia/priority.
3. Orchestrator encola tareas (`queued`).
4. Worker dispara hook OpenClaw y marca `running`.
5. OpenClaw retorna callback; task pasa a `completed|failed|blocked|cancelled`.
6. Eventos/logs/runs se guardan en PostgreSQL.
7. Dashboard y Telegram consumen estado actualizado.
