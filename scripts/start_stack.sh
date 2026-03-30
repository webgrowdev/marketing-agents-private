#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(cd -- "${SCRIPT_DIR}/.." && pwd)

cd "$ROOT"

if [[ "${1:-}" == "--prod" ]]; then
  npm run build
  (cd orchestrator && npm run start) &
  (cd dashboard && npm run start) &
else
  (cd orchestrator && npm run dev) &
  (cd dashboard && npm run dev) &
fi

wait
