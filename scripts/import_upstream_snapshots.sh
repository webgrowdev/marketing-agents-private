#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=./lib.sh
source "${SCRIPT_DIR}/lib.sh"

MARKETINGSKILLS_PATH=""
ANIMATION_PATH=""
DESIGN_PATH=""
DRY_RUN=0
FORCE_OVERWRITE=0

usage() {
  cat <<'USAGE'
Uso: import_upstream_snapshots.sh [opciones]

Opciones:
  --marketingskills PATH        Snapshot local de marketingskills
  --animation-principles PATH   Snapshot local de animation-principles
  --design-skills PATH          Snapshot local de design-skills
  --dry-run                     Simular importación
  --force-overwrite             Permitir reemplazar snapshots ya importados
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --marketingskills) MARKETINGSKILLS_PATH="$2"; shift 2 ;;
    --animation-principles) ANIMATION_PATH="$2"; shift 2 ;;
    --design-skills) DESIGN_PATH="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --force-overwrite) FORCE_OVERWRITE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) log_error "Argumento no reconocido: $1"; usage; exit 2 ;;
  esac
done

ROOT=$(repo_root)
STATE_DIR="${ROOT}/.import"
STATE_FILE="${STATE_DIR}/state.tsv"
ensure_dir "$STATE_DIR"
[[ -f "$STATE_FILE" ]] || printf 'timestamp\tskill\tstatus\tsource_repo\tsource_path\n' > "$STATE_FILE"

validate_path() {
  local name=$1 path=$2
  [[ -z "$path" ]] && return 0
  [[ -d "$path" ]] || { log_error "Ruta inválida para ${name}: ${path}"; exit 2; }
}

validate_path marketingskills "$MARKETINGSKILLS_PATH"
validate_path animation-principles "$ANIMATION_PATH"
validate_path design-skills "$DESIGN_PATH"

if [[ -z "$MARKETINGSKILLS_PATH" && -z "$ANIMATION_PATH" && -z "$DESIGN_PATH" ]]; then
  log_error "Debes proveer al menos una ruta de snapshot upstream"
  exit 2
fi

copy_skill_snapshot() {
  local skill=$1 repo=$2 base=$3
  local dest_dir="${ROOT}/skills/${skill}"
  local dest_file="${dest_dir}/UPSTREAM_SOURCE.md"
  local found=""
  [[ -d "$base" ]] || return 1

  # Heurística flexible: directorio con slug o archivo markdown con nombre del skill
  found=$(find "$base" -type f \( -name 'SKILL.md' -o -name '*.md' \) | grep -E "/${skill}/|${skill}\.md$" | head -n 1 || true)
  [[ -n "$found" ]] || return 1

  ensure_dir "$dest_dir"
  if [[ -f "$dest_file" && "$FORCE_OVERWRITE" -ne 1 ]]; then
    log_warn "Saltando ${skill}: ya existe ${dest_file} (usa --force-overwrite para reemplazar)"
    return 2
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log_info "[dry-run] importaría ${skill} desde ${found}"
  else
    cp "$found" "$dest_file"
    local ts
    ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    printf '%s\t%s\t%s\t%s\t%s\n' "$ts" "$skill" "imported" "$repo" "$found" >> "$STATE_FILE"
    log_info "Importado ${skill} desde ${repo}"
  fi
  return 0
}

marketing_skills=(seo-audit ai-seo site-architecture programmatic-seo schema-markup competitor-alternatives page-cro signup-flow-cro onboarding-cro form-cro popup-cro paywall-upgrade-cro copywriting copy-editing cold-email email-sequence social-content paid-ads ad-creative analytics-tracking ab-test-setup churn-prevention free-tool-strategy referral-program revops sales-enablement launch-strategy pricing-strategy marketing-ideas marketing-psychology)
motion_skills=(motion-designer svg-animation-engineer apple-ui-skills elevated-design video-motion-graphics dramatic-2000ms-plus)

imported=0
missing=0

for s in "${marketing_skills[@]}"; do
  if copy_skill_snapshot "$s" "coreyhaines31/marketingskills" "$MARKETINGSKILLS_PATH"; then
    imported=$((imported+1))
  else
    missing=$((missing+1))
    log_warn "No encontrado en snapshot marketingskills: $s"
  fi
done

for s in "${motion_skills[@]}"; do
  ok=1
  copy_skill_snapshot "$s" "dylantarre/animation-principles" "$ANIMATION_PATH" || ok=0
  if [[ "$ok" -eq 0 ]]; then
    copy_skill_snapshot "$s" "ihlamury/design-skills" "$DESIGN_PATH" || ok=0
  fi
  if [[ "$ok" -eq 1 ]]; then
    imported=$((imported+1))
  else
    missing=$((missing+1))
    log_warn "No encontrado en snapshots motion: $s"
  fi
done

log_info "Importación finalizada. imported=${imported}, missing=${missing}"
if [[ "$DRY_RUN" -eq 1 ]]; then
  log_info "Modo dry-run: no se escribieron archivos"
else
  log_info "Registro: ${STATE_FILE}"
  log_info "Siguiente paso: ./scripts/verify.sh y revisión manual de docs/skills-map.md"
fi
