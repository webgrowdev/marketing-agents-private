# Mantenimiento

## Actualizar skills
1. Abrir rama de trabajo.
2. Traer cambios upstream en entorno de auditoría (no producción).
3. Adaptar `SKILL.md` al formato interno.
4. Actualizar `docs/skills-map.md`, `docs/upstream-sources.md` y `LICENSE_NOTES.md`.
5. Ejecutar `./scripts/verify.sh` y revisar diffs.

## Incorporar nuevos agentes
- Crear `agents/<slug>/README.md`, `IDENTITY.md`, `AGENTS.md`, `SOUL.md`.
- Asignar skills explícitas.
- Ajustar `docs/agents.md` y, si aplica, scripts de sync.

## Revisar diffs de upstream
- Registrar fecha de inspección y commit de referencia.
- Documentar breaking changes de naming/estructura.
- Preferir migraciones incrementales.

## Gestión de placeholders
- Tratar cada placeholder como deuda explícita.
- Definir responsable y fecha objetivo de cierre.
- Mantener instrucciones de completado dentro de cada `SKILL.md`.
