# Integración con OpenClaw

Este workspace se sincroniza como `workspaces/growth-retention` y consume skills curadas desde `skills/`.

## Skills permitidas
- `churn-prevention`
- `free-tool-strategy`
- `referral-program`

## Reglas de ejecución
- Cargar primero `shared/product-marketing-context.md`.
- Limitarse a las skills permitidas del agente.
- Registrar supuestos y vacíos de información.
- Escalar a placeholder si falta capacidad verificable.
