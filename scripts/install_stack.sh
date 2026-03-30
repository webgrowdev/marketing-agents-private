#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(cd -- "${SCRIPT_DIR}/.." && pwd)

cd "$ROOT"

command -v npm >/dev/null || { echo "npm requerido"; exit 1; }
command -v psql >/dev/null || echo "[WARN] psql no disponible (solo necesario para checks avanzados)"

npm install

cd orchestrator
npx prisma generate
npx prisma migrate deploy
npm run prisma:seed

cd "$ROOT"
echo "✅ Stack dependencies y DB listos"
