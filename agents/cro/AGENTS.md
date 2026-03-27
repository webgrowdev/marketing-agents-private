# Integración con OpenClaw

Este workspace se sincroniza como `workspaces/cro` y consume skills curadas desde `skills/`.

## Skills permitidas
- `page-cro`
- `signup-flow-cro`
- `onboarding-cro`
- `form-cro`
- `popup-cro`
- `paywall-upgrade-cro`

## Reglas de ejecución
- Cargar primero `shared/product-marketing-context.md`.
- Limitarse a las skills permitidas del agente.
- Registrar supuestos y vacíos de información.
- Escalar a placeholder si falta capacidad verificable.
