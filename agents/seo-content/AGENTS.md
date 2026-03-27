# Integración con OpenClaw

Este workspace se sincroniza como `workspaces/seo-content` y consume skills curadas desde `skills/`.

## Skills permitidas
- `seo-audit`
- `ai-seo`
- `site-architecture`
- `programmatic-seo`
- `schema-markup`
- `competitor-alternatives`

## Reglas de ejecución
- Cargar primero `shared/product-marketing-context.md`.
- Limitarse a las skills permitidas del agente.
- Registrar supuestos y vacíos de información.
- Escalar a placeholder si falta capacidad verificable.
