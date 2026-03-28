#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"

# Cargar lib.sh si existe; si no, definir fallbacks mínimos
if [[ -f "${SCRIPT_DIR}/lib.sh" ]]; then
  # shellcheck source=./lib.sh
  source "${SCRIPT_DIR}/lib.sh"
fi

if ! declare -F log_info >/dev/null 2>&1; then
  log_info()  { printf '[INFO] %s\n' "$*"; }
fi
if ! declare -F log_warn >/dev/null 2>&1; then
  log_warn()  { printf '[WARN] %s\n' "$*" >&2; }
fi
if ! declare -F log_error >/dev/null 2>&1; then
  log_error() { printf '[ERROR] %s\n' "$*" >&2; }
fi
if ! declare -F ensure_dir >/dev/null 2>&1; then
  ensure_dir() { mkdir -p "$1"; }
fi
if ! declare -F repo_root >/dev/null 2>&1; then
  repo_root() {
    if git -C "${SCRIPT_DIR}/.." rev-parse --show-toplevel >/dev/null 2>&1; then
      git -C "${SCRIPT_DIR}/.." rev-parse --show-toplevel
    else
      cd "${SCRIPT_DIR}/.." && pwd
    fi
  }
fi

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
  --dry-run                     Simular importación sin escribir archivos
  --force-overwrite             Permitir reemplazar SKILL.md y UPSTREAM_SOURCE.md existentes
  --debug-mapping               Imprimir tabla completa de resolución por skill
  -h, --help                    Mostrar esta ayuda
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --marketingskills)
      MARKETINGSKILLS_PATH="${2:-}"
      shift 2
      ;;
    --animation-principles)
      ANIMATION_PATH="${2:-}"
      shift 2
      ;;
    --design-skills)
      DESIGN_PATH="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --force-overwrite)
      FORCE_OVERWRITE=1
      shift
      ;;
    --debug-mapping)
      DEBUG_MAPPING=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "Argumento no reconocido: $1"
      usage
      exit 2
      ;;
  esac
done

validate_path() {
  local name="$1"
  local path="$2"

  [[ -z "$path" ]] && return 0

  if [[ ! -d "$path" ]]; then
    log_error "Ruta inválida para ${name}: ${path}"
    exit 2
  fi
}

validate_path "marketingskills" "$MARKETINGSKILLS_PATH"
validate_path "animation-principles" "$ANIMATION_PATH"
validate_path "design-skills" "$DESIGN_PATH"

if [[ -z "$MARKETINGSKILLS_PATH" && -z "$ANIMATION_PATH" && -z "$DESIGN_PATH" ]]; then
  log_error "Debes proveer al menos una ruta de snapshot upstream"
  exit 2
fi

ROOT="$(repo_root)"
STATE_DIR="${ROOT}/.import"
STATE_FILE="${STATE_DIR}/state.tsv"
ensure_dir "$STATE_DIR"

if [[ ! -f "$STATE_FILE" ]]; then
  printf 'timestamp\tskill\taction\tsource_repo\tsource_path\tresolution_method\n' > "$STATE_FILE"
fi

declare -A REPO_BASE=(
  [marketingskills]="$MARKETINGSKILLS_PATH"
  [animation-principles]="$ANIMATION_PATH"
  [design-skills]="$DESIGN_PATH"
)

declare -A REPO_LABEL=(
  [marketingskills]="coreyhaines31/marketingskills"
  [animation-principles]="dylantarre/animation-principles"
  [design-skills]="ihlamury/design-skills"
)

declare -A ALIAS_MAP=()

# Contadores
count_imported=0
count_dry_run=0
count_skipped=0
count_unresolved=0
count_exact=0
count_nested=0
count_alias=0

add_alias() {
  local repo="$1"
  local local_skill="$2"
  local upstream_slug="$3"
  ALIAS_MAP["${repo}:${local_skill}"]="$upstream_slug"
}

load_aliases() {
  # Alias confirmados o resueltos de forma pragmática
  add_alias "design-skills" "apple-ui-skills" "apple"
  add_alias "animation-principles" "svg-animation-engineer" "web-motion-design"
  add_alias "design-skills" "elevated-design" "linear"
}

has_skills_dir() {
  local repo="$1"
  local base="${REPO_BASE[$repo]:-}"
  [[ -n "$base" && -d "${base}/skills" ]]
}

find_first_md_file() {
  local dir="$1"
  find "$dir" -maxdepth 1 -type f \( -name '*.md' -o -name '*.MD' \) | sort | head -n 1
}

find_source_markdown() {
  local dir="$1"
  local source_file=""

  if [[ -f "${dir}/SKILL.md" ]]; then
    source_file="${dir}/SKILL.md"
  else
    source_file="$(find_first_md_file "$dir")"
  fi

  [[ -n "$source_file" && -f "$source_file" ]] || return 1
  printf '%s\n' "$source_file"
}

# Devuelve:
# <canonical_slug>\t<alias_applied:0|1>
resolve_alias() {
  local repo="$1"
  local local_skill="$2"
  local key="${repo}:${local_skill}"

  if [[ -n "${ALIAS_MAP[$key]:-}" ]]; then
    printf '%s\t1\n' "${ALIAS_MAP[$key]}"
  else
    printf '%s\t0\n' "$local_skill"
  fi
}

# Devuelve:
# <source_file>\t<upstream_path>\t<resolution_method>
resolve_in_repo() {
  local repo="$1"
  local local_skill="$2"
  local base="${REPO_BASE[$repo]:-}"

  [[ -n "$base" ]] || return 1
  [[ -d "$base" ]] || return 1
  [[ -d "${base}/skills" ]] || return 1

  local alias_info canonical alias_applied
  alias_info="$(resolve_alias "$repo" "$local_skill")"
  canonical="$(printf '%s' "$alias_info" | cut -f1)"
  alias_applied="$(printf '%s' "$alias_info" | cut -f2)"

  local source_file=""
  local skill_dir=""
  local upstream_path=""
  local method=""

  # 1) Exact match plano: skills/<slug>
  local exact_dir="${base}/skills/${canonical}"
  if [[ -d "$exact_dir" ]]; then
    source_file="$(find_source_markdown "$exact_dir" || true)"
    if [[ -n "$source_file" ]]; then
      skill_dir="$exact_dir"
      upstream_path="${skill_dir#${base}/}"
      if [[ "$alias_applied" -eq 1 ]]; then
        method="alias"
      else
        method="exact"
      fi
      printf '%s\t%s\t%s\n' "$source_file" "$upstream_path" "$method"
      return 0
    fi
  fi

  # 2) Nested/recursive match: skills/*/<slug> o más profundo si aparece
  local nested_dir=""
  nested_dir="$(find "${base}/skills" -mindepth 2 -type d -name "$canonical" | sort | head -n 1 || true)"
  if [[ -n "$nested_dir" && -d "$nested_dir" ]]; then
    source_file="$(find_source_markdown "$nested_dir" || true)"
    if [[ -n "$source_file" ]]; then
      skill_dir="$nested_dir"
      upstream_path="${skill_dir#${base}/}"
      if [[ "$alias_applied" -eq 1 ]]; then
        method="alias"
      else
        method="nested"
      fi
      printf '%s\t%s\t%s\n' "$source_file" "$upstream_path" "$method"
      return 0
    fi
  fi

  return 1
}

# Devuelve:
# <repo>\t<source_file>\t<upstream_path>\t<resolution_method>
resolve_skill() {
  local local_skill="$1"
  shift
  local repos=("$@")

  local repo=""
  local resolved=""
  for repo in "${repos[@]}"; do
    resolved="$(resolve_in_repo "$repo" "$local_skill" || true)"
    if [[ -n "$resolved" ]]; then
      printf '%s\t%s\n' "$repo" "$resolved"
      return 0
    fi
  done

  return 1
}

# Fila TSV interna:
# <local_skill>\t<upstream_repo>\t<upstream_path>\t<method>\t<action>\t<source_file>
emit_result() {
  local local_skill="$1"
  local upstream_repo="$2"
  local upstream_path="$3"
  local method="$4"
  local action="$5"
  local source_file="${6:-}"

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$local_skill" "$upstream_repo" "$upstream_path" "$method" "$action" "$source_file"
}

print_debug_header() {
  printf 'local slug | upstream repo | upstream path | resolution method | action\n'
}

print_debug_row() {
  local local_skill="$1"
  local upstream_repo="$2"
  local upstream_path="$3"
  local method="$4"
  local action="$5"

  printf '%s | %s | %s | %s | %s\n' \
    "$local_skill" "$upstream_repo" "$upstream_path" "$method" "$action"
}

print_compact() {
  local local_skill="$1"
  local upstream_repo="$2"
  local upstream_path="$3"
  local method="$4"
  local action="$5"

  case "$action" in
    imported)
      log_info "IMPORTADO: ${local_skill} <- ${upstream_repo}:${upstream_path} (${method})"
      ;;
    dry-run)
      log_info "DRY-RUN: ${local_skill} <- ${upstream_repo}:${upstream_path} (${method})"
      ;;
    skip-existing)
      log_info "SKIP: ${local_skill} -> ${upstream_repo}:${upstream_path} (${method})"
      ;;
    not-found)
      log_error "UNRESOLVED: ${local_skill}"
      ;;
    *)
      log_info "${action}: ${local_skill}"
      ;;
  esac
}

write_import_files() {
  local source_file="$1"
  local dest_dir="$2"

  local dest_skill="${dest_dir}/SKILL.md"
  local dest_upstream="${dest_dir}/UPSTREAM_SOURCE.md"

  ensure_dir "$dest_dir"

  cp "$source_file" "$dest_skill"
  cp "$source_file" "$dest_upstream"
}

update_counters_for_method() {
  local method="$1"
  case "$method" in
    exact)  count_exact=$((count_exact + 1)) ;;
    nested) count_nested=$((count_nested + 1)) ;;
    alias)  count_alias=$((count_alias + 1)) ;;
  esac
}

record_state() {
  local local_skill="$1"
  local action="$2"
  local repo_label="$3"
  local source_path="$4"
  local method="$5"

  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$ts" "$local_skill" "$action" "$repo_label" "$source_path" "$method" >> "$STATE_FILE"
}

# SIEMPRE devuelve 0.
# El estado viaja en la fila TSV impresa.
import_skill() {
  local local_skill="$1"
  shift
  local repos=("$@")

  local dest_dir="${ROOT}/skills/${local_skill}"
  local dest_upstream="${dest_dir}/UPSTREAM_SOURCE.md"

  local resolved=""
  local repo=""
  local source_file=""
  local upstream_path=""
  local method=""
  local repo_label=""

  resolved="$(resolve_skill "$local_skill" "${repos[@]}" || true)"

  if [[ -z "$resolved" ]]; then
    emit_result "$local_skill" "-" "-" "unresolved" "not-found" "-"
    return 0
  fi

  repo="$(printf '%s' "$resolved" | cut -f1)"
  source_file="$(printf '%s' "$resolved" | cut -f2)"
  upstream_path="$(printf '%s' "$resolved" | cut -f3)"
  method="$(printf '%s' "$resolved" | cut -f4)"
  repo_label="${REPO_LABEL[$repo]:-$repo}"

  # Resolver primero, recién después decidir skip
  if [[ -f "$dest_upstream" && "$FORCE_OVERWRITE" -ne 1 ]]; then
    emit_result "$local_skill" "$repo_label" "$upstream_path" "$method" "skip-existing" "$source_file"
    return 0
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    emit_result "$local_skill" "$repo_label" "$upstream_path" "$method" "dry-run" "$source_file"
    return 0
  fi

  write_import_files "$source_file" "$dest_dir"
  record_state "$local_skill" "imported" "$repo_label" "$source_file" "$method"
  emit_result "$local_skill" "$repo_label" "$upstream_path" "$method" "imported" "$source_file"
  return 0
}

process_result_row() {
  local row="$1"

  local local_skill=""
  local upstream_repo=""
  local upstream_path=""
  local method=""
  local action=""
  local source_file=""

  IFS=$'\t' read -r local_skill upstream_repo upstream_path method action source_file <<< "$row"

  case "$action" in
    imported)
      count_imported=$((count_imported + 1))
      update_counters_for_method "$method"
      ;;
    dry-run)
      count_dry_run=$((count_dry_run + 1))
      update_counters_for_method "$method"
      ;;
    skip-existing)
      count_skipped=$((count_skipped + 1))
      update_counters_for_method "$method"
      ;;
    not-found)
      count_unresolved=$((count_unresolved + 1))
      ;;
  esac

  if [[ "$DEBUG_MAPPING" -eq 1 ]]; then
    print_debug_row "$local_skill" "$upstream_repo" "$upstream_path" "$method" "$action"
  else
    print_compact "$local_skill" "$upstream_repo" "$upstream_path" "$method" "$action"
  fi
}

marketing_skills=(
  seo-audit
  ai-seo
  site-architecture
  programmatic-seo
  schema-markup
  competitor-alternatives
  page-cro
  signup-flow-cro
  onboarding-cro
  form-cro
  popup-cro
  paywall-upgrade-cro
  copywriting
  copy-editing
  cold-email
  email-sequence
  social-content
  paid-ads
  ad-creative
  analytics-tracking
  ab-test-setup
  churn-prevention
  free-tool-strategy
  referral-program
  revops
  sales-enablement
  launch-strategy
  pricing-strategy
  marketing-ideas
  marketing-psychology
)

motion_skills=(
  motion-designer
  svg-animation-engineer
  apple-ui-skills
  elevated-design
  video-motion-graphics
  dramatic-2000ms-plus
)

load_aliases

# Preflight útil
for repo in marketingskills animation-principles design-skills; do
  base="${REPO_BASE[$repo]:-}"
  [[ -z "$base" ]] && continue
  if has_skills_dir "$repo"; then
    log_info "Snapshot detectado para ${repo}: ${base}/skills"
  else
    log_warn "Snapshot sin subárbol skills/ para ${repo}: ${base}"
  fi
done

if [[ "$DEBUG_MAPPING" -eq 1 ]]; then
  print_debug_header
fi

for skill in "${marketing_skills[@]}"; do
  row="$(import_skill "$skill" marketingskills)"
  process_result_row "$row"
done

for skill in "${motion_skills[@]}"; do
  row="$(import_skill "$skill" animation-principles design-skills)"
  process_result_row "$row"
done

log_info "Importación finalizada."
log_info "exact=${count_exact}, nested=${count_nested}, alias=${count_alias}, unresolved=${count_unresolved}"
log_info "imported=${count_imported}, dry-run=${count_dry_run}, skipped=${count_skipped}, unresolved=${count_unresolved}"

if [[ "$DRY_RUN" -eq 1 ]]; then
  log_info "Modo dry-run: no se escribieron archivos"
else
  log_info "Registro: ${STATE_FILE}"
fi