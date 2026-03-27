#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=./lib.sh
source "${SCRIPT_DIR}/lib.sh"

ROOT=$(repo_root)
errors=0

must_exist=(
  README.md LICENSE_NOTES.md Makefile
  docs/architecture.md docs/agents.md docs/skills-map.md docs/upstream-sources.md docs/security.md docs/maintenance.md docs/deployment.md docs/placeholders.md
  shared/product-marketing-context.md
  scripts/install.sh scripts/import_upstream_snapshots.sh scripts/sync_to_openclaw.sh scripts/resolve_pr_conflicts.sh scripts/verify.sh scripts/backup.sh scripts/lib.sh
)

for f in "${must_exist[@]}"; do
  if [[ ! -e "${ROOT}/${f}" ]]; then
    log_error "Falta requerido: ${f}"
    errors=$((errors+1))
  fi
done

for d in "${ROOT}/skills"/*; do
  [[ -d "$d" ]] || continue
  bn=$(basename "$d")
  if [[ "$bn" != "placeholders" && ! -f "$d/SKILL.md" ]]; then
    log_error "Skill sin SKILL.md: $bn"
    errors=$((errors+1))
  fi
done

for a in seo-content cro content-copy paid-measurement growth-retention sales-gtm strategy motion-pro; do
  for af in README.md IDENTITY.md AGENTS.md SOUL.md; do
    [[ -f "${ROOT}/agents/${a}/${af}" ]] || { log_error "Agente ${a} incompleto: falta ${af}"; errors=$((errors+1)); }
  done
done

if [[ "$errors" -gt 0 ]]; then
  log_error "Verificación fallida con ${errors} error(es)"
  exit 1
fi

log_info "Verificación OK"
