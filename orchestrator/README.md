# Orchestrator

API central para campañas/tareas, cola BullMQ, worker OpenClaw, scheduler y Telegram.

## Endpoints
- `GET /health`
- `GET|POST /campaigns`
- `GET|POST /tasks`
- `POST /tasks/:id/queue`
- `POST /tasks/:id/openclaw-result`
- `GET /agents`
- `GET /agents/:slug`
- `GET /events`
- `GET /metrics/overview`
