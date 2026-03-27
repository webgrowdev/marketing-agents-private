# Integración con OpenClaw

Este workspace se sincroniza como `workspaces/paid-measurement` y consume skills curadas desde `skills/`.

## Skills permitidas
- `paid-ads`
- `ad-creative`
- `analytics-tracking`
- `ab-test-setup`

## Reglas de ejecución
- Cargar primero `shared/product-marketing-context.md`.
- Limitarse a las skills permitidas del agente.
- Registrar supuestos y vacíos de información.
- Escalar a placeholder si falta capacidad verificable.
