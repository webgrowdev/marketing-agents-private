# Integración con OpenClaw

Este workspace se sincroniza como `workspaces/content-copy` y consume skills curadas desde `skills/`.

## Skills permitidas
- `copywriting`
- `copy-editing`
- `cold-email`
- `email-sequence`
- `social-content`

## Reglas de ejecución
- Cargar primero `shared/product-marketing-context.md`.
- Limitarse a las skills permitidas del agente.
- Registrar supuestos y vacíos de información.
- Escalar a placeholder si falta capacidad verificable.
