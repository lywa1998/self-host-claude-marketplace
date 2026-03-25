#!/bin/bash
# crates-guru-search.sh - 极简 Bash 版 Crates Guru 自然语言搜索（卡片输出）

usage() {
  echo "Usage: $0 \"query\" [--min-downloads N] [--updated-within-days N] [--require-docs]"
  echo "Examples:"
  echo "  $0 \"openai client\""
  echo "  $0 \"web framework\" --require-docs"
  echo "  $0 \"orm\" --updated-within-days 365"
}

is_nonneg_int() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

QUERY_PARTS=()
MIN_DOWNLOADS=""
UPDATED_WITHIN_DAYS=""
REQUIRE_DOCS=0

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

# 简单 URL 编码（空格 -> +）
ENCODED_QUERY=$(echo "$QUERY" | sed 's/ /+/g')
URL="https://crates.guru/search?q=${ENCODED_QUERY}"

echo "Source: crates.guru"
echo "Query: \"${QUERY}\""
echo "Filters: min_downloads=${MIN_DOWNLOADS:-unsupported}, updated_within_days=${UPDATED_WITHIN_DAYS:-requested}, require_docs=${REQUIRE_DOCS}"
echo "URL: ${URL}"
echo "------------------------------------------------------------"

if [ -n "$MIN_DOWNLOADS" ]; then
  echo "Note: crates.guru 当前抓取不提供稳定下载量，--min-downloads 在此脚本中暂不强过滤。"
fi
if [ -n "$UPDATED_WITHIN_DAYS" ]; then
  echo "Note: crates.guru 已尝试根据 Updated 日期执行过滤。"
fi
if [ "$REQUIRE_DOCS" -eq 1 ]; then
  echo "Note: --require-docs 在 crates.guru 采用可推导策略（根据 crate 名生成 docs.rs 链接，非强校验）。"
fi

if [ -n "$UPDATED_WITHIN_DAYS" ]; then
  NOW_TS=$(date -u +%s)
  CUTOFF_TS=$((NOW_TS - UPDATED_WITHIN_DAYS * 86400))
else
  CUTOFF_TS=0
fi

curl -s -L \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  -H "Accept: */*" \
  -H "hx-request: true" \
  -H "hx-target: search-results" \
  "$URL" \
| awk -v cutoff_ts="$CUTOFF_TS" '
  function trim(s) { gsub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", s); return s }
  function strip_tags(s) { gsub(/<[^>]*>/, "", s); return s }

  function to_ts(date_s,    cmd, out) {
    if (date_s == "") return 0;
    cmd = "date -j -u -f %Y-%m-%d \"" date_s "\" +%s 2>/dev/null";
    cmd | getline out;
    close(cmd);
    return (out == "" ? 0 : out + 0);
  }

  function emit_card(    uts) {
    if (name == "") return;

    if (cutoff_ts > 0 && updated != "") {
      uts = to_ts(updated);
      if (uts > 0 && uts < cutoff_ts) {
        name = ""; desc = ""; updated = "";
        return;
      }
    }

    print "------------------------------------------------------------";
    print "Name: " name;
    print "Description: " (desc == "" ? "No description" : desc);
    if (updated != "") print "Updated: " updated;
    print "Links:";
    print "  crates.guru: https://crates.guru/crates/" name;
    print "  docs.rs: https://docs.rs/" name;
    print "------------------------------------------------------------";

    printed++;
    name = ""; desc = ""; updated = "";
  }

  /<strong>/ {
    emit_card();

    line = $0;
    sub(/.*<strong>/, "", line);
    sub(/<\/strong>.*/, "", line);
    name = trim(line);
    next;
  }

  /result-description/ {
    line = $0;
    sub(/.*result-description"?>/, "", line);
    sub(/<\/div>.*/, "", line);
    desc = trim(strip_tags(line));
    next;
  }

  /Updated:/ {
    line = $0;
    sub(/.*Updated:[ ]*/, "", line);
    sub(/<.*/, "", line);
    updated = trim(strip_tags(line));
    next;
  }

  /<\/article>/ {
    emit_card();
    next;
  }

  END {
    emit_card();
    if (printed == 0) {
      print "No crates matched filters.";
      print "------------------------------------------------------------";
    }
  }
' | head -n 180

echo ""
echo "Tip: crates.guru 适合语义检索，建议与 lib.rs / crates.io 交叉确认下载量与更新时间。"
