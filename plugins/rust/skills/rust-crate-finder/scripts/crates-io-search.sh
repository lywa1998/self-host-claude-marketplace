#!/bin/bash
# crates-io-search.sh - 用自然语言或关键词在 crates.io 搜索 Rust crates（纯 Bash + curl）

usage() {
  echo "Usage: $0 \"query\" [--min-downloads N] [--updated-within-days N] [--require-docs] [--per-page N]"
  echo "Examples:"
  echo "  $0 \"openai client\""
  echo "  $0 \"async web framework\" --min-downloads 10000 --updated-within-days 365"
  echo "  $0 \"high performance json\" --require-docs --per-page 15"
}

is_nonneg_int() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

trim_left() {
  local v="$1"
  v="${v#"${v%%[![:space:]]*}"}"
  printf '%s' "$v"
}

url_encode() {
  local s="$1"
  local out=""
  local c hex
  local i
  for ((i = 0; i < ${#s}; i++)); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) out+="$c" ;;
      ' ') out+="%20" ;;
      *)
        printf -v hex '%%%02X' "'$c"
        out+="$hex"
        ;;
    esac
  done
  printf '%s' "$out"
}

json_get_number() {
  local obj="$1"
  local key="$2"
  local rest="${obj#*\"$key\":}"
  [[ "$rest" == "$obj" ]] && { printf ''; return; }
  rest="$(trim_left "$rest")"
  if [[ "$rest" =~ ^([0-9]+) ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    printf ''
  fi
}

json_get_string() {
  local obj="$1"
  local key="$2"
  local rest="${obj#*\"$key\":}"
  local out=""
  local esc=0
  local ch hex
  local i

  [[ "$rest" == "$obj" ]] && { printf ''; return; }
  rest="$(trim_left "$rest")"

  if [[ "${rest:0:4}" == "null" ]]; then
    printf ''
    return
  fi

  [[ "${rest:0:1}" == '"' ]] || { printf ''; return; }
  rest="${rest:1}"

  for ((i = 0; i < ${#rest}; i++)); do
    ch="${rest:i:1}"

    if ((esc)); then
      case "$ch" in
        '"') out+='"' ;;
        '\\') out+='\\' ;;
        '/') out+='/' ;;
        'b') out+='' ;;
        'f') out+='' ;;
        'n') out+=' ' ;;
        'r') out+='' ;;
        't') out+=' ' ;;
        'u')
          hex="${rest:i+1:4}"
          if [[ "$hex" =~ ^[0-9a-fA-F]{4}$ ]]; then
            out+='?'
            ((i += 4))
          else
            out+='u'
          fi
          ;;
        *) out+="$ch" ;;
      esac
      esc=0
      continue
    fi

    if [[ "$ch" == '\\' ]]; then
      esc=1
      continue
    fi

    if [[ "$ch" == '"' ]]; then
      break
    fi

    out+="$ch"
  done

  printf '%s' "$out"
}

date_to_ts() {
  local date_s="$1"
  local ts
  [[ -z "$date_s" ]] && { printf ''; return; }
  ts=$(date -j -u -f "%Y-%m-%d" "$date_s" +%s 2>/dev/null)
  printf '%s' "$ts"
}

extract_objects_from_array() {
  local text="$1"
  local depth=0
  local in_str=0
  local esc=0
  local ch
  local current=""
  local i

  for ((i = 0; i < ${#text}; i++)); do
    ch="${text:i:1}"

    if ((in_str)); then
      if ((depth > 0)); then
        current+="$ch"
      fi

      if ((esc)); then
        esc=0
      elif [[ "$ch" == '\\' ]]; then
        esc=1
      elif [[ "$ch" == '"' ]]; then
        in_str=0
      fi
      continue
    fi

    if [[ "$ch" == '"' ]]; then
      in_str=1
      if ((depth > 0)); then
        current+="$ch"
      fi
      continue
    fi

    if [[ "$ch" == '{' ]]; then
      if ((depth == 0)); then
        current=""
      fi
      ((depth++))
      current+="$ch"
      continue
    fi

    if [[ "$ch" == '}' ]]; then
      if ((depth > 0)); then
        current+="$ch"
      fi
      ((depth--))
      if ((depth == 0 && ${#current} > 0)); then
        printf '%s\n' "$current"
        current=""
      fi
      continue
    fi

    if ((depth > 0)); then
      current+="$ch"
    fi
  done
}

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

QUERY_PARTS=()
MIN_DOWNLOADS=0
UPDATED_WITHIN_DAYS=""
REQUIRE_DOCS=0
PER_PAGE=10

while [ $# -gt 0 ]; do
  case "$1" in
    --min-downloads)
      [ -n "$2" ] || { echo "Error: --min-downloads requires a value."; exit 1; }
      is_nonneg_int "$2" || { echo "Error: --min-downloads must be a non-negative integer."; exit 1; }
      MIN_DOWNLOADS="$2"; shift 2 ;;
    --updated-within-days)
      [ -n "$2" ] || { echo "Error: --updated-within-days requires a value."; exit 1; }
      is_nonneg_int "$2" || { echo "Error: --updated-within-days must be a non-negative integer."; exit 1; }
      UPDATED_WITHIN_DAYS="$2"; shift 2 ;;
    --require-docs)
      REQUIRE_DOCS=1; shift ;;
    --per-page|--per_page)
      [ -n "$2" ] || { echo "Error: --per-page requires a value."; exit 1; }
      is_nonneg_int "$2" || { echo "Error: --per-page must be a non-negative integer."; exit 1; }
      PER_PAGE="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    --)
      shift; QUERY_PARTS+=("$@"); break ;;
    *)
      QUERY_PARTS+=("$1"); shift ;;
  esac
done

QUERY="${QUERY_PARTS[*]}"
if [ -z "$QUERY" ]; then
  usage
  exit 1
fi

CUTOFF_TS=0
if [ -n "$UPDATED_WITHIN_DAYS" ]; then
  NOW_TS=$(date -u +%s)
  CUTOFF_TS=$((NOW_TS - UPDATED_WITHIN_DAYS * 86400))
fi

ENCODED="$(url_encode "$QUERY")"
URL="https://crates.io/api/v1/crates?q=${ENCODED}&per_page=${PER_PAGE}"

echo "Source: crates.io"
echo "Query: \"${QUERY}\""
echo "Filters: min_downloads=${MIN_DOWNLOADS}, updated_within_days=${UPDATED_WITHIN_DAYS:-none}, require_docs=${REQUIRE_DOCS}"
echo "URL: ${URL}"
echo "------------------------------------------------------------"

JSON_RESPONSE=$(curl -s -L \
  -H "User-Agent: crates-io-bash/1.0" \
  -H "Accept: application/json" \
  "$URL")

if [ -z "$JSON_RESPONSE" ]; then
  echo "Error: empty response from crates.io"
  echo ""
  echo "Tip: crates.io 结果按相关性排序；可在浏览器中访问 URL 查看更多排序选项（sort=downloads、sort=recent-updates 等）。"
  exit 0
fi

CRATES_SEGMENT="${JSON_RESPONSE#*\"crates\":[}"
if [ "$CRATES_SEGMENT" = "$JSON_RESPONSE" ]; then
  echo "Error: failed to parse crates list from response"
  echo ""
  echo "Tip: crates.io 结果按相关性排序；可在浏览器中访问 URL 查看更多排序选项（sort=downloads、sort=recent-updates 等）。"
  exit 0
fi
CRATES_SEGMENT="${CRATES_SEGMENT%%],\"meta\"*}"

PRINTED=0
while IFS= read -r CRATE_OBJ; do
  [ -z "$CRATE_OBJ" ] && continue

  NAME="$(json_get_string "$CRATE_OBJ" "name")"
  VERSION="$(json_get_string "$CRATE_OBJ" "max_version")"
  DESCRIPTION="$(json_get_string "$CRATE_OBJ" "description")"
  DOWNLOADS="$(json_get_number "$CRATE_OBJ" "downloads")"
  RECENT_DOWNLOADS="$(json_get_number "$CRATE_OBJ" "recent_downloads")"
  UPDATED_AT="$(json_get_string "$CRATE_OBJ" "updated_at")"
  DOCUMENTATION="$(json_get_string "$CRATE_OBJ" "documentation")"

  DOWNLOADS=${DOWNLOADS:-0}
  RECENT_DOWNLOADS=${RECENT_DOWNLOADS:-0}
  DESCRIPTION=${DESCRIPTION:-No description}

  if ((DOWNLOADS < MIN_DOWNLOADS)); then
    continue
  fi

  UPDATED_DATE="${UPDATED_AT%%T*}"
  if ((CUTOFF_TS > 0)); then
    UPDATED_TS="$(date_to_ts "$UPDATED_DATE")"
    if [ -z "$UPDATED_TS" ] || ((UPDATED_TS < CUTOFF_TS)); then
      continue
    fi
  fi

  if ((REQUIRE_DOCS == 1)) && [ -z "$DOCUMENTATION" ]; then
    continue
  fi

  echo "------------------------------------------------------------"
  echo "Name: ${NAME} (v${VERSION})"
  echo "Description: ${DESCRIPTION}"
  echo "Downloads: ${DOWNLOADS} | Recent: ${RECENT_DOWNLOADS}"
  [ -n "$UPDATED_DATE" ] && echo "Updated: ${UPDATED_DATE}"
  echo "Links:"
  echo "  crates.io: https://crates.io/crates/${NAME}"
  echo "  docs.rs: https://docs.rs/${NAME}"
  echo "------------------------------------------------------------"
  PRINTED=1
done < <(extract_objects_from_array "$CRATES_SEGMENT")

if [ "$PRINTED" -eq 0 ]; then
  echo "No crates matched filters."
  echo "------------------------------------------------------------"
fi

echo ""
echo "Tip: crates.io 结果按相关性排序；可在浏览器中访问 URL 查看更多排序选项（sort=downloads、sort=recent-updates 等）。"
