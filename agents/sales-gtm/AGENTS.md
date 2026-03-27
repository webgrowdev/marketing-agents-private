# Integración con OpenClaw

Este workspace se sincroniza como `workspaces/sales-gtm` y consume skills curadas desde `skills/`.

## Skills permitidas
- `revops`
- `sales-enablement`
- `launch-strategy`
- `pricing-strategy`

## Reglas de ejecución
- Cargar primero `shared/product-marketing-context.md`.
- Limitarse a las skills permitidas del agente.
- Registrar supuestos y vacíos de información.
- Escalar a placeholder si falta capacidad verificable.
