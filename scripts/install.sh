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
require_cmd npm

ROOT=$(repo_root)
ensure_dir "${ROOT}/backups"

for d in agents skills docs shared scripts orchestrator dashboard openclaw; do
  ensure_dir "${ROOT}/$d"
done

log_info "Instalación base completa"
log_info "Siguiente paso: ./scripts/install_stack.sh"
