#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=./lib.sh
source "${SCRIPT_DIR}/lib.sh"

TARGET_BASE="${HOME}/.openclaw"
DRY_RUN=0
CLEAN=0

usage() {
  cat <<'USAGE'
Uso: sync_to_openclaw.sh [--target-base PATH] [--dry-run] [--clean]

Opciones:
  --target-base PATH  Base de OpenClaw (default: ~/.openclaw)
  --dry-run           Simula cambios sin escribir
  --clean             Permite limpieza de archivos obsoletos dentro de cada workspace
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-base) TARGET_BASE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --clean) CLEAN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) log_error "Argumento no reconocido: $1"; usage; exit 2 ;;
  esac
done

require_cmd rsync
ROOT=$(repo_root)
AGENTS_DIR="${ROOT}/agents"
SKILLS_DIR="${ROOT}/skills"
SHARED_CONTEXT="${ROOT}/shared/product-marketing-context.md"

RSYNC_OPTS=(-a --human-readable)
[[ "$DRY_RUN" -eq 1 ]] && RSYNC_OPTS+=(--dry-run -v)
[[ "$CLEAN" -eq 1 ]] && RSYNC_OPTS+=(--delete)

log_info "Sincronizando hacia ${TARGET_BASE}"

for agent_path in "${AGENTS_DIR}"/*; do
  [[ -d "$agent_path" ]] || continue
  agent=$(basename "$agent_path")
  workspace="${TARGET_BASE}/workspaces/${agent}"
  ensure_dir "${workspace}/agent"
  ensure_dir "${workspace}/skills"
  ensure_dir "${workspace}/shared"

  rsync "${RSYNC_OPTS[@]}" "${agent_path}/" "${workspace}/agent/"

  # Extrae skills declaradas en README del agente (líneas tipo - `skill`)
  while IFS= read -r skill; do
    [[ -z "$skill" ]] && continue
    src="${SKILLS_DIR}/${skill}/"
    dst="${workspace}/skills/${skill}/"
    if [[ -d "${src}" ]]; then
      ensure_dir "$dst"
      rsync "${RSYNC_OPTS[@]}" "${src}" "${dst}"
    else
      log_warn "Skill no encontrada en repo para ${agent}: ${skill}"
    fi
  done < <(sed -n 's/^- `\(.*\)`$/\1/p' "${agent_path}/README.md")

  rsync "${RSYNC_OPTS[@]}" "${SHARED_CONTEXT}" "${workspace}/shared/product-marketing-context.md"
  log_info "Workspace sincronizado: ${workspace}"
done

log_info "Sync finalizada"
if [[ "$DRY_RUN" -eq 1 ]]; then
  log_info "Modo dry-run: no se escribieron cambios"
fi
log_info "Próximo paso: ejecutar verify.sh en repo y validar workspaces en OpenClaw"
