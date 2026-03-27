# marketing-agents-private

Repositorio privado curado para operar agentes de marketing en OpenClaw con control total de cambios, trazabilidad y aislamiento por agente.

## Estado real de curación
Este entorno no tiene acceso saliente confiable a GitHub (error `403 CONNECT tunnel failed`). Por diseño, **no se finge curación**: los skills están listos para importación offline/manual asistida.

## Por qué existe
- Evitar dependencia directa de upstream en producción.
- Mantener una base estable y auditada para operación en VPS.
- Permitir customizaciones internas sin perder trazabilidad.

## Estructura
- `agents/`: 8 agentes listos para OpenClaw.
- `skills/`: skills en estado placeholder/importables offline.
- `shared/`: contexto común reusable.
- `scripts/`: install, verify, import snapshots, sync y backup.
- `docs/`: arquitectura, seguridad, mantenimiento y fuentes.

## Flujo recomendado sin acceso remoto desde Codex
1. Descargar snapshots locales de upstream en una máquina con internet.
2. Ejecutar importación offline/manual asistida (con mapping y diagnóstico opcional):
   ```bash
   ./scripts/import_upstream_snapshots.sh \
     --dry-run --debug-mapping \
     --marketingskills /path/to/marketingskills \
     --animation-principles /path/to/animation-principles \
     --design-skills /path/to/design-skills
   ```
   El importador resuelve cada slug local por este orden: **exact match → alias match → normalized/fuzzy match → unresolved**.
   Cuando el resultado sea correcto, repetir sin `--dry-run` (y usar `--force-overwrite` solo si querés reemplazar `UPSTREAM_SOURCE.md` existentes).
3. Verificar estructura y estados:
   ```bash
   ./scripts/verify.sh
   ```
4. Sincronizar a OpenClaw:
   ```bash
   ./scripts/sync_to_openclaw.sh --target-base ~/.openclaw
   ```

## Agentes incluidos
`seo-content`, `cro`, `content-copy`, `paid-measurement`, `growth-retention`, `sales-gtm`, `strategy`, `motion-pro`.

## Motion skills objetivo (completo)
`motion-designer`, `svg-animation-engineer`, `apple-ui-skills`, `elevated-design`, `video-motion-graphics`, `dramatic-2000ms-plus`.

## Mantenimiento
Ver `docs/maintenance.md` y `docs/deployment.md`.

## Resolver conflictos de PR (GitHub "This branch has conflicts")
Si GitHub marca conflictos, haz merge/rebase del branch objetivo localmente y luego:
```bash
./scripts/resolve_pr_conflicts.sh --ours
```
Usa `--theirs` si querés priorizar la versión del branch objetivo en esos archivos.
