# Integración con OpenClaw

Este workspace se sincroniza como `workspaces/motion-pro` y consume skills curadas desde `skills/`.

## Skills permitidas
- `motion-designer`
- `video-motion-graphics`
- `dramatic-2000ms-plus`
- `apple-ui-skills`

## Reglas de ejecución
- Cargar primero `shared/product-marketing-context.md`.
- Limitarse a las skills permitidas del agente.
- Registrar supuestos y vacíos de información.
- Escalar a placeholder si falta capacidad verificable.
