#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=./lib.sh
source "${SCRIPT_DIR}/lib.sh"

OUT_DIR="$(repo_root)/backups"
TARGET="repo"

usage() {
  cat <<'USAGE'
Uso: backup.sh [--out-dir PATH] [--target repo|openclaw] [--openclaw-base PATH]
USAGE
}

OPENCLAW_BASE="${HOME}/.openclaw"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --out-dir) OUT_DIR="$2"; shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    --openclaw-base) OPENCLAW_BASE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) log_error "Argumento no reconocido: $1"; usage; exit 2 ;;
  esac
done

ensure_dir "$OUT_DIR"
ts=$(date -u +%Y%m%dT%H%M%SZ)
archive="${OUT_DIR}/marketing-agents-private-${TARGET}-${ts}.tar.gz"

if [[ "$TARGET" == "repo" ]]; then
  tar --exclude='.git' --exclude='backups' -czf "$archive" -C "$(repo_root)" .
elif [[ "$TARGET" == "openclaw" ]]; then
  tar -czf "$archive" -C "$OPENCLAW_BASE" workspaces || { log_error "No se pudo respaldar ${OPENCLAW_BASE}/workspaces"; exit 1; }
else
  log_error "target inválido: $TARGET"
  exit 2
fi

log_info "Backup generado: $archive"
