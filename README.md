# marketing-agents-private

Stack de agencia de marketing multiagente listo para producción sobre OpenClaw, con orquestación central, observabilidad, reporting por Telegram y dashboard ejecutivo.

## Componentes
- `agents/`: 8 agentes originales + `marketing-pm` + `executive-reporter`.
- `openclaw/agents.registry.yaml`: registro de bindings/sesiones/workspaces.
- `orchestrator/`: API Express + BullMQ + Prisma + scheduler + Telegram.
- `dashboard/`: Next.js + Tailwind (CEO, PM, agentes, actividad, métricas).
- `scripts/`: instalación, arranque, verificación y sync.
- `docs/runbook-openclaw-vps.md`: guía paso a paso desde cero.

## Inicio rápido
```bash
cp orchestrator/.env.example orchestrator/.env
cp dashboard/.env.example dashboard/.env
./scripts/install.sh
./scripts/install_stack.sh
./scripts/sync_to_openclaw.sh --target-base ~/.openclaw
./scripts/start_stack.sh
./scripts/verify_stack.sh
```

## Estado de tareas soportado
`pending`, `queued`, `running`, `blocked`, `failed`, `completed`, `cancelled`.

## Jobs programados
- Daily brief
- Campaign review
- Blocked check
- Executive summary

## Telegram
- Script de prueba: `cd orchestrator && npm run telegram:test`
- Resumen manual: `cd orchestrator && npm run ops:daily-summary`

## Runbook completo
Ver `docs/runbook-openclaw-vps.md`.
