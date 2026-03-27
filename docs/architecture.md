# Arquitectura del repositorio

## Capas lógicas
1. `agents/`: definición operativa por agente, aislada por workspace.
2. `skills/`: skills curadas (importadas, adaptadas o placeholders explícitos).
3. `shared/`: contexto reusable entre agentes.
4. `scripts/`: automatización de instalación, verificación, sync y backup.
5. `docs/`: documentación interna de operación y gobierno.

## Principio de aislamiento
Cada agente se sincroniza a `~/.openclaw/workspaces/<agent>/` con tres subcarpetas: `agent/`, `skills/`, `shared/`. Esto reduce acoplamiento y facilita rollback por workspace.

## Despliegue en VPS
El VPS solo necesita una copia del repo privado + utilidades estándar (`bash`, `rsync`, `tar`). No se clonan upstreams en producción.
