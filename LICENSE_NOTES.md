# Notas de licencia y atribución

## Fuentes declaradas
- https://github.com/coreyhaines31/marketingskills
- https://github.com/dylantarre/animation-principles
- https://github.com/ihlamury/design-skills

## Estado actual de importación
- No hay importación upstream verificada directamente desde este entorno por restricción de egress (`403 CONNECT tunnel failed`).
- Los skills permanecen en estado `internal placeholder (pending snapshot import)` hasta curación offline/manual.

## Placeholders motion explícitos
- motion-designer
- svg-animation-engineer
- apple-ui-skills
- elevated-design
- video-motion-graphics
- dramatic-2000ms-plus

## Flujo recomendado de cumplimiento
1. Descargar snapshots upstream en entorno con internet.
2. Importar con `scripts/import_upstream_snapshots.sh`.
3. Revisar licencias y atribución de cada skill importada/adaptada.
4. Actualizar este archivo y `docs/upstream-sources.md` con el estado final.
