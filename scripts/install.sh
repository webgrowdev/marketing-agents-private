#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=./lib.sh
source "${SCRIPT_DIR}/lib.sh"

log_info "Iniciando instalación base (idempotente)"
require_cmd bash
require_cmd find
require_cmd tar
require_cmd rsync

ROOT=$(repo_root)
ensure_dir "${ROOT}/backups"

# Validación rápida de carpetas clave
for d in agents skills docs shared scripts; do
  ensure_dir "${ROOT}/$d"
done

log_info "Instalación completa"
log_info "Repo: ${ROOT}"
log_info "Siguiente paso: ./scripts/verify.sh"
