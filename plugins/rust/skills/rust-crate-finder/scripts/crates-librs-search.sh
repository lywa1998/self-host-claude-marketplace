#!/bin/bash
# crates-librs-search.sh - 用自然语言在 lib.rs 搜索 Rust crates（卡片输出）

usage() {
  echo "Usage: $0 \"query\" [--min-downloads N] [--updated-within-days N] [--require-docs]"
  echo "Examples:"
  echo "  $0 \"openai client\""
  echo "  $0 \"async web framework with websocket\" --min-downloads 10000"
  echo "  $0 \"json parser\" --require-docs"
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

MIN_DOWNLOADS=${MIN_DOWNLOADS:-0}

# URL 编码：空格转 %20（lib.rs 支持）
ENCODED=$(echo "$QUERY" | sed 's/ /%20/g')
URL="https://lib.rs/search?q=${ENCODED}"

echo "Source: lib.rs"
echo "Query: \"${QUERY}\""
echo "Filters: min_downloads=${MIN_DOWNLOADS}, updated_within_days=${UPDATED_WITHIN_DAYS:-unsupported}, require_docs=${REQUIRE_DOCS}"
echo "URL: ${URL}"
echo "------------------------------------------------------------"

if [ -n "$UPDATED_WITHIN_DAYS" ]; then
  echo "Note: lib.rs 搜索结果页通常不含稳定的更新时间字段，--updated-within-days 在此脚本中暂不强过滤。"
fi
if [ "$REQUIRE_DOCS" -eq 1 ]; then
  echo "Note: --require-docs 在 lib.rs 采用可推导策略（根据 crate 名生成 docs.rs 链接，非强校验）。"
fi

curl -s -L \
  -H "User-Agent: Mozilla/5.0 (compatible; librs-bash/1.0)" \
  "$URL" \
| awk -v min_dl="$MIN_DOWNLOADS" '
  function strip_tags(s) { gsub(/<[^>]*>/, "", s); return s }
  function trim(s) { gsub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", s); return s }

  function emit_card(    dl_num) {
    if (name == "") return;

    dl_num = (recent_downloads == "" ? 0 : recent_downloads + 0);
    if (dl_num < min_dl) {
      name = ""; version = ""; desc = ""; recent_downloads = ""; downloads_display = "";
      return;
    }

    print "------------------------------------------------------------";
    if (version != "") {
      print "Name: " name " (v" version ")";
    } else {
      print "Name: " name;
    }
    print "Description: " (desc == "" ? "No description" : desc);
    if (downloads_display != "" || recent_downloads != "") {
      line = "Downloads: " (downloads_display == "" ? "unknown" : downloads_display);
      if (recent_downloads != "") line = line " | Recent: " recent_downloads;
      print line;
    }
    print "Links:";
    print "  lib.rs: https://lib.rs/crates/" name;
    print "  docs.rs: https://docs.rs/" name;
    print "------------------------------------------------------------";

    printed++;
    name = ""; version = ""; desc = ""; recent_downloads = ""; downloads_display = "";
  }

  {
    if ($0 ~ /<a href="\/crates\//) {
      emit_card();
      line = $0;
      sub(/.*<a href="\/crates\//, "", line);
      sub(/".*/, "", line);
      name = trim(line);
      next;
    }

    if ($0 ~ /<p class=desc>/) {
      line = $0;
      sub(/.*<p class=desc>/, "", line);
      sub(/<\/p>.*/, "", line);
      line = strip_tags(line);
      desc = trim(line);
      next;
    }

    if ($0 ~ /class="version/ || $0 ~ /class=version/) {
      line = $0;
      line = strip_tags(line);
      gsub(/[ \t]/, "", line);
      sub(/^v/, "", line);
      version = trim(line);
      next;
    }

    if ($0 ~ /class=downloads/ && $0 ~ /recent downloads/) {
      line = $0;
      if (match(line, /title="[0-9]+ recent downloads"/)) {
        tmp = substr(line, RSTART, RLENGTH);
        gsub(/[^0-9]/, "", tmp);
        recent_downloads = tmp;
      }

      shown = $0;
      sub(/.*class=downloads[^>]*>/, "", shown);
      sub(/<\/span>.*/, "", shown);
      shown = strip_tags(shown);
      downloads_display = trim(shown);
      next;
    }

    if ($0 ~ /<\/li>/) {
      emit_card();
      next;
    }
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
echo "Tip: lib.rs 质量分与相关性不错；建议与 crates.io 交叉确认下载量与更新时间。"
