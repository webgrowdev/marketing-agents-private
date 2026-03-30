#!/usr/bin/env bash
set -euo pipefail

curl -fsS http://localhost:4000/health >/dev/null && echo "orchestrator: ok"
curl -fsS http://localhost:3000 >/dev/null && echo "dashboard: ok"
