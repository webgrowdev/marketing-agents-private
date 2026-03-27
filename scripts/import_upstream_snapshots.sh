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
DEBUG_MAPPING=0

usage() {
  cat <<'USAGE'
Uso: import_upstream_snapshots.sh [opciones]

Opciones:
  --marketingskills PATH        Snapshot local de marketingskills
  --animation-principles PATH   Snapshot local de animation-principles
  --design-skills PATH          Snapshot local de design-skills
  --dry-run                     Simular importación
  --force-overwrite             Permitir reemplazar snapshots ya importados
  --debug-mapping               Imprimir resolución de nombres por skill
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --marketingskills) MARKETINGSKILLS_PATH="$2"; shift 2 ;;
    --animation-principles) ANIMATION_PATH="$2"; shift 2 ;;
    --design-skills) DESIGN_PATH="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --force-overwrite) FORCE_OVERWRITE=1; shift ;;
    --debug-mapping) DEBUG_MAPPING=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) log_error "Argumento no reconocido: $1"; usage; exit 2 ;;
  esac
done

ROOT=$(repo_root)
STATE_DIR="${ROOT}/.import"
STATE_FILE="${STATE_DIR}/state.tsv"
ensure_dir "$STATE_DIR"
[[ -f "$STATE_FILE" ]] || printf 'timestamp\tskill\tstatus\tsource_repo\tsource_path\tresolution_method\n' > "$STATE_FILE"

declare -A REPO_PATHS=(
  [marketingskills]="$MARKETINGSKILLS_PATH"
  [animation-principles]="$ANIMATION_PATH"
  [design-skills]="$DESIGN_PATH"
)
declare -A REPO_LABELS=(
  [marketingskills]="coreyhaines31/marketingskills"
  [animation-principles]="dylantarre/animation-principles"
  [design-skills]="ihlamury/design-skills"
)
declare -A REPO_SKILLS_ROOT=()
declare -A REPO_SKILLS_LIST=()
declare -A ALIAS_MAP=()

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

normalize_slug() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+//g'
}

tokenize_slug() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/ /g' | xargs
}

add_alias() {
  local repo=$1 local_skill=$2 upstream_skill=$3
  ALIAS_MAP["${repo}:${local_skill}"]="$upstream_skill"
}

load_aliases() {
  # Marketing / growth aliases (editable)
  add_alias marketingskills "ab-test-setup" "ab-testing"
  add_alias marketingskills "analytics-tracking" "analytics"
  add_alias marketingskills "copy-editing" "editing"
  add_alias marketingskills "email-sequence" "email-marketing"
  add_alias marketingskills "page-cro" "landing-page-cro"
  add_alias marketingskills "popup-cro" "popup-optimization"
  add_alias marketingskills "programmatic-seo" "programmatic"
  add_alias marketingskills "schema-markup" "schema"

  # Motion aliases (editable)
  add_alias animation-principles "motion-designer" "motion-design"
  add_alias animation-principles "svg-animation-engineer" "svg-animation"
  add_alias design-skills "apple-ui-skills" "apple-ui"
  add_alias design-skills "video-motion-graphics" "motion-graphics"
  add_alias design-skills "dramatic-2000ms-plus" "dramatic"
}

find_skills_root() {
  local base=$1
  [[ -d "$base" ]] || return 1

  if [[ -d "$base/skills" ]]; then
    echo "$base/skills"
    return 0
  fi

  local nested
  nested=$(find "$base" -maxdepth 3 -type d -name skills | head -n 1 || true)
  if [[ -n "$nested" ]]; then
    echo "$nested"
    return 0
  fi

  return 1
}

load_repo_catalog() {
  local repo=$1
  local base=${REPO_PATHS[$repo]}
  [[ -n "$base" ]] || return 0

  local skills_root
  if ! skills_root=$(find_skills_root "$base"); then
    log_warn "No se encontró carpeta skills en snapshot ${repo}: ${base}"
    REPO_SKILLS_ROOT[$repo]=""
    REPO_SKILLS_LIST[$repo]=""
    return 0
  fi

  REPO_SKILLS_ROOT[$repo]="$skills_root"
  local list
  list=$(find "$skills_root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | tr '\n' ' ')
  REPO_SKILLS_LIST[$repo]="$list"

  log_info "Snapshot ${repo}: skills_root=${skills_root}"
  if [[ "$DEBUG_MAPPING" -eq 1 ]]; then
    log_info "Snapshot ${repo}: skills_detectados=$(echo "$list" | xargs)"
  fi
}

# heuristic score by token overlap.
score_similarity() {
  local local_skill=$1 candidate=$2
  local local_tokens candidate_tokens
  local_tokens=$(tokenize_slug "$local_skill")
  candidate_tokens=$(tokenize_slug "$candidate")

  local score=0
  for lt in $local_tokens; do
    for ct in $candidate_tokens; do
      if [[ "$lt" == "$ct" ]]; then
        score=$((score + 1))
      fi
    done
  done
  echo "$score"
}

resolve_skill_folder() {
  local repo=$1 local_skill=$2
  local list="${REPO_SKILLS_LIST[$repo]:-}"
  [[ -n "$list" ]] || return 1

  # 1) exact folder match
  for candidate in $list; do
    if [[ "$candidate" == "$local_skill" ]]; then
      printf '%s\t%s\n' "$candidate" "exact match"
      return 0
    fi
  done

  # 2) explicit alias map
  local alias_key="${repo}:${local_skill}"
  local alias_value="${ALIAS_MAP[$alias_key]:-}"
  if [[ -n "$alias_value" ]]; then
    for candidate in $list; do
      if [[ "$candidate" == "$alias_value" ]]; then
        printf '%s\t%s\n' "$candidate" "alias match"
        return 0
      fi
    done
  fi

  # 3) normalized exactness (remove punctuation)
  local local_norm
  local_norm=$(normalize_slug "$local_skill")
  for candidate in $list; do
    if [[ "$(normalize_slug "$candidate")" == "$local_norm" ]]; then
      printf '%s\t%s\n' "$candidate" "normalized match"
      return 0
    fi
  done

  # 4) fallback similarity by token overlap
  local best_candidate=""
  local best_score=0
  local ties=0
  for candidate in $list; do
    local score
    score=$(score_similarity "$local_skill" "$candidate")
    if (( score > best_score )); then
      best_score=$score
      best_candidate=$candidate
      ties=0
    elif (( score == best_score && score > 0 )); then
      ties=$((ties + 1))
    fi
  done

  # Require at least 2 token overlaps and no ties.
  if (( best_score >= 2 && ties == 0 )); then
    printf '%s\t%s\n' "$best_candidate" "fuzzy match"
    return 0
  fi

  return 1
}

copy_skill_snapshot() {
  local skill=$1 repo=$2
  local dest_dir="${ROOT}/skills/${skill}"
  local dest_file="${dest_dir}/UPSTREAM_SOURCE.md"
  local skills_root="${REPO_SKILLS_ROOT[$repo]:-}"

  [[ -n "$skills_root" ]] || return 1

  local resolved
  if ! resolved=$(resolve_skill_folder "$repo" "$skill"); then
    return 1
  fi

  local upstream_folder method source_file
  upstream_folder=$(echo "$resolved" | cut -f1)
  method=$(echo "$resolved" | cut -f2)
  source_file="${skills_root}/${upstream_folder}/SKILL.md"

  if [[ ! -f "$source_file" ]]; then
    source_file=$(find "${skills_root}/${upstream_folder}" -maxdepth 1 -type f -name '*.md' | head -n 1 || true)
  fi
  [[ -n "$source_file" && -f "$source_file" ]] || return 1

  ensure_dir "$dest_dir"
  if [[ -f "$dest_file" && "$FORCE_OVERWRITE" -ne 1 ]]; then
    log_warn "Saltando ${skill}: ya existe ${dest_file} (usa --force-overwrite para reemplazar)"
    printf '%s\t%s\t%s\t%s\n' "$skill" "$upstream_folder" "$method" "skipped-existing"
    return 2
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log_info "[dry-run] local=${skill} upstream=${upstream_folder} metodo=${method}"
  else
    cp "$source_file" "$dest_file"
    local ts
    ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$ts" "$skill" "imported" "${REPO_LABELS[$repo]}" "$source_file" "$method" >> "$STATE_FILE"
    log_info "Importado local=${skill} upstream=${upstream_folder} metodo=${method}"
  fi

  printf '%s\t%s\t%s\t%s\n' "$skill" "$upstream_folder" "$method" "resolved"
  return 0
}

marketing_skills=(seo-audit ai-seo site-architecture programmatic-seo schema-markup competitor-alternatives page-cro signup-flow-cro onboarding-cro form-cro popup-cro paywall-upgrade-cro copywriting copy-editing cold-email email-sequence social-content paid-ads ad-creative analytics-tracking ab-test-setup churn-prevention free-tool-strategy referral-program revops sales-enablement launch-strategy pricing-strategy marketing-ideas marketing-psychology)
motion_skills=(motion-designer svg-animation-engineer apple-ui-skills elevated-design video-motion-graphics dramatic-2000ms-plus)

load_aliases
load_repo_catalog marketingskills
load_repo_catalog animation-principles
load_repo_catalog design-skills

imported=0
skipped=0
unresolved=0
resolution_rows=()

report_resolution() {
  local row=$1
  resolution_rows+=("$row")
  if [[ "$DEBUG_MAPPING" -eq 1 ]]; then
    IFS=$'\t' read -r local_skill upstream method status <<< "$row"
    log_info "[mapping] local=${local_skill} upstream=${upstream} metodo=${method} estado=${status}"
  fi
}

for s in "${marketing_skills[@]}"; do
  result=$(copy_skill_snapshot "$s" "marketingskills" || true)
  if [[ -n "$result" ]]; then
    report_resolution "$result"
    status=$(echo "$result" | cut -f4)
    case "$status" in
      resolved) imported=$((imported+1)) ;;
      skipped-existing) skipped=$((skipped+1)) ;;
    esac
  else
    unresolved=$((unresolved+1))
    report_resolution "$(printf "%s\t%s\t%s\t%s" "$s" "-" "unresolved" "unresolved")"
    log_warn "No resuelto local=${s} repo=marketingskills"
  fi
done

for s in "${motion_skills[@]}"; do
  result=$(copy_skill_snapshot "$s" "animation-principles" || true)
  if [[ -z "$result" ]]; then
    result=$(copy_skill_snapshot "$s" "design-skills" || true)
  fi

  if [[ -n "$result" ]]; then
    report_resolution "$result"
    status=$(echo "$result" | cut -f4)
    case "$status" in
      resolved) imported=$((imported+1)) ;;
      skipped-existing) skipped=$((skipped+1)) ;;
    esac
  else
    unresolved=$((unresolved+1))
    report_resolution "$(printf "%s\t%s\t%s\t%s" "$s" "-" "unresolved" "unresolved")"
    log_warn "No resuelto local=${s} repo=motion"
  fi
done

log_info "Importación finalizada. resolved=${imported}, skipped=${skipped}, unresolved=${unresolved}"
if [[ "$DRY_RUN" -eq 1 ]]; then
  log_info "Modo dry-run: no se escribieron archivos"
else
  log_info "Registro: ${STATE_FILE}"
  log_info "Siguiente paso: ./scripts/verify.sh y revisión manual de docs/skills-map.md"
fi

if [[ "$DEBUG_MAPPING" -eq 1 ]]; then
  echo ""
  echo "Resumen mapping (local\tupstream\tmetodo\testado):"
  for row in "${resolution_rows[@]}"; do
    echo "$row"
  done
fi
