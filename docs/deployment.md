# Deployment en VPS Linux

## Pasos recomendados
1. Copiar el repo privado al VPS (`git clone` privado o `rsync` seguro).
2. Ejecutar instalación base:
   ```bash
   ./scripts/install.sh
   ```
3. Verificar estructura:
   ```bash
   ./scripts/verify.sh
   ```
4. Sincronizar a OpenClaw:
   ```bash
   ./scripts/sync_to_openclaw.sh --target-base ~/.openclaw
   ```

## Verificación post-sync
- Confirmar directorios por agente en `~/.openclaw/workspaces/`.
- Revisar que cada workspace tenga `agent/`, `skills/` y `shared/product-marketing-context.md`.

## Rutas esperadas de OpenClaw
- Base: `~/.openclaw`
- Workspaces: `~/.openclaw/workspaces/<agent>`
