# Seguridad operacional

## Por qué este repo reduce riesgo
- Evita clonar upstreams en producción: menos superficie de supply-chain.
- Congela versión curada de skills: cambios explícitos vía Git privado.
- Aísla agentes por workspace: menor blast radius ante errores.

## Antes de importar cambios upstream
1. Revisar licencia y permisos de uso.
2. Comparar diffs de contenido y prompts.
3. Eliminar referencias a secretos o endpoints no autorizados.
4. Probar en entorno staging antes de producción.

## Manejo de secretos
- No guardar tokens en este repo.
- Usar variables de entorno o secret manager del VPS.
- Confirmar que backups no incluyan archivos de credenciales externos.

## Buenas prácticas VPS
- Usuario no-root para operación diaria.
- Permisos mínimos en `~/.openclaw`.
- Backups cifrados fuera del host.
- Rotación y revisión de logs de sincronización.
