# Deployment en VPS Linux (flujo offline-first)

## 1) Preparar snapshots upstream (fuera del VPS si hace falta)
En una máquina con internet, descargar/copiar snapshots locales de:
- `marketingskills`
- `animation-principles`
- `design-skills`

## 2) Importar snapshots al repo privado
```bash
./scripts/import_upstream_snapshots.sh \
  --marketingskills /path/to/marketingskills \
  --animation-principles /path/to/animation-principles \
  --design-skills /path/to/design-skills
```

## 3) Instalar y verificar
```bash
./scripts/install.sh
./scripts/verify.sh
```

## 4) Sincronizar con OpenClaw
```bash
./scripts/sync_to_openclaw.sh --target-base ~/.openclaw
```

## 5) Validar workspaces
Confirmar en `~/.openclaw/workspaces/<agent>/` la presencia de:
- `agent/`
- `skills/`
- `shared/product-marketing-context.md`
