# RUNBOOK — Marketing Multiagente en OpenClaw (VPS Linux)

## 1) Prerrequisitos
- Ubuntu 22.04+
- Node.js 22
- npm 10+
- PostgreSQL 15+
- Redis 7+
- OpenClaw accesible por HTTP

## 2) Bootstrap
```bash
git clone https://github.com/webgrowdev/marketing-agents-private.git
cd marketing-agents-private
cp orchestrator/.env.example orchestrator/.env
cp dashboard/.env.example dashboard/.env
```

Editar `orchestrator/.env` con credenciales reales.

## 3) Instalar y migrar
```bash
./scripts/install.sh
./scripts/install_stack.sh
./scripts/verify.sh
```

## 4) Sincronizar agentes con OpenClaw
```bash
./scripts/sync_to_openclaw.sh --target-base ~/.openclaw
cat openclaw/agents.registry.yaml
```

## 5) Levantar stack
```bash
./scripts/start_stack.sh
```

## 6) Validar
```bash
./scripts/verify_stack.sh
curl http://localhost:4000/metrics/overview
curl http://localhost:4000/agents
```

## 7) Testing E2E rápido
```bash
curl -X POST http://localhost:4000/campaigns -H 'content-type: application/json' -d '{"name":"Q2 Launch","description":"Launch pipeline","priority":1}'
```
1. Crear campaña.
2. Crear tareas con `/tasks`.
3. Encolar con `/tasks/:id/queue`.
4. Confirmar eventos en `/events` y dashboard.

## 8) Operación diaria
- Monitorear `/health`, `/metrics/overview`, `/events`.
- Ejecutar resumen manual: `cd orchestrator && npm run ops:daily-summary`.
- Probar Telegram: `cd orchestrator && npm run telegram:test`.

## 9) Actualizaciones seguras
```bash
git pull
npm install
cd orchestrator && npx prisma migrate deploy && npm run build
cd ../dashboard && npm run build
```
Reiniciar procesos.
