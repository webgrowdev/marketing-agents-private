#!/usr/bin/env bash
set -euo pipefail

# Resolve known PR conflicts for this repository by preferring this branch's versions.
# Usage:
#   ./scripts/resolve_pr_conflicts.sh          # keep ours (default)
#   ./scripts/resolve_pr_conflicts.sh --theirs # keep target branch version

MODE="ours"
if [[ "${1:-}" == "--theirs" ]]; then
  MODE="theirs"
elif [[ "${1:-}" == "--ours" || -z "${1:-}" ]]; then
  MODE="ours"
else
  echo "Uso: $0 [--ours|--theirs]" >&2
  exit 2
fi

# Files reported by GitHub conflict checker in this PR.
FILES=(
  .gitignore
  LICENSE_NOTES.md
  Makefile
  README.md
  agents/motion-pro/AGENTS.md
  agents/motion-pro/README.md
  docs/agents.md
  docs/deployment.md
  docs/placeholders.md
  docs/skills-map.md
  docs/upstream-sources.md
  scripts/verify.sh
  skills/ab-test-setup/SKILL.md
  skills/ad-creative/SKILL.md
  skills/ai-seo/SKILL.md
  skills/analytics-tracking/SKILL.md
  skills/apple-ui-skills/SKILL.md
  skills/churn-prevention/SKILL.md
  skills/cold-email/SKILL.md
  skills/competitor-alternatives/SKILL.md
  skills/copy-editing/SKILL.md
  skills/copywriting/SKILL.md
  skills/dramatic-2000ms-plus/SKILL.md
  skills/email-sequence/SKILL.md
  skills/form-cro/SKILL.md
)

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: no estás dentro de un repositorio git." >&2
  exit 1
fi

if ! git diff --name-only --diff-filter=U | grep -q .; then
  echo "No hay conflictos en el índice local."
  echo "Tip: ejecuta este script después de hacer merge/rebase del branch objetivo."
  exit 0
fi

for f in "${FILES[@]}"; do
  if git diff --name-only --diff-filter=U | grep -qx "$f"; then
    git checkout "--${MODE}" -- "$f"
    git add "$f"
    echo "Resuelto ($MODE): $f"
  fi
done

remaining=$(git diff --name-only --diff-filter=U | wc -l | tr -d ' ')
if [[ "$remaining" -gt 0 ]]; then
  echo "Quedan $remaining conflicto(s) sin resolver. Revisar manualmente." >&2
  git diff --name-only --diff-filter=U
  exit 1
fi

echo "Conflictos resueltos para la lista conocida."
