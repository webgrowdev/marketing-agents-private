#!/usr/bin/env bash
set -euo pipefail

# Librería compartida para scripts del repositorio.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/.." && pwd)

log_info() { printf '[INFO] %s\n' "$*"; }
log_warn() { printf '[WARN] %s\n' "$*"; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  local c=$1
  command -v "$c" >/dev/null 2>&1 || { log_error "Comando requerido no disponible: $c"; return 1; }
}

ensure_dir() {
  local d=$1
  mkdir -p "$d"
}

repo_root() {
  printf '%s\n' "$REPO_ROOT"
}

is_true() {
  case "${1:-}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}
