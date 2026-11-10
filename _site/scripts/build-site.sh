#!/usr/bin/env bash
# Build the website: _site/scripts/build-site.sh [--serve]   -> _site/public
# Run _site/scripts/setup.sh once first.
set -euo pipefail
SITE="$(cd "$(dirname "$0")/.." && pwd)"
Q="$SITE/.quartz"
[[ -d "$Q/node_modules" ]] || { echo "Quartz not installed; run _site/scripts/setup.sh" >&2; exit 1; }

"$SITE/scripts/stage.sh"
cp "$SITE/scripts/quartz.config.yaml" "$Q/quartz.config.yaml"
cp "$SITE/scripts/custom.scss" "$Q/quartz/styles/custom.scss"

# Dark mode by default: the darkmode plugin follows the OS setting and has no option for it, so
# patch its first-visit theme to "dark". The toggle (stored in localStorage) still wins.
for f in "$Q"/.quartz/plugins/darkmode/dist/index.js "$Q"/.quartz/plugins/darkmode/dist/components/index.js; do
  [[ -f "$f" ]] && perl -i -pe 's/window\.matchMedia\("\(prefers-color-scheme: light\)"\)\.matches\?"light":"dark"/"dark"/' "$f"
done
grep -q 'prefers-color-scheme: light' "$Q"/.quartz/plugins/darkmode/dist/index.js &&
  echo "build-site: warning: dark-by-default patch did not apply (darkmode plugin changed?)" >&2

# Quartz v5's explorer, search and graph plugins assume the site is at the domain root: they
# fetch "/static/contentIndex.json" and build links as "/"+slug, which break when the site lives
# under a path (peeda.github.io/Notes/). Prefix those from baseUrl; --serve previews at the root
# of localhost, so no prefix there. Re-runnable: each pattern also matches an earlier prefix.
prefix=""
if [[ " $* " != *" --serve "* ]]; then
  base=$(sed -nE 's/^ *baseUrl: *"?([^" #]+)"?.*/\1/p' "$SITE/scripts/quartz.config.yaml")
  [[ "$base" == */* ]] && prefix="/${base#*/}"
fi
# Both the built bundles (dist/) and the .inline.ts sources Quartz compiles page scripts from.
plugin_files=("$Q"/.quartz/plugins/*/dist/index.js "$Q"/.quartz/plugins/*/dist/components/index.js
              "$Q"/.quartz/plugins/*/src/components/scripts/*.inline.ts)
PREFIX="$prefix" perl -i -pe '
  s{fetch\((\s*)(\\?)"(?:/[^"\\]*)?/static/contentIndex\.json(\\?)"}{fetch($1$2"$ENV{PREFIX}/static/contentIndex.json$3"}g;
  s{(\.href\s*=\s*|new URL\(\s*)(\\?)"(?:/[^"\\]*)?/(\\?)"(\s*)\+}{$1$2"$ENV{PREFIX}/$3"$4+}g;
' "${plugin_files[@]}" 2>/dev/null || true
left=$( (cat "${plugin_files[@]}" 2>/dev/null | grep -oE '(\.href\s*=\s*|new URL\(\s*)\\?"/\\?"\s*\+' || true) | wc -l | tr -d ' ')
[[ -n "$prefix" && "$left" != 0 ]] && echo "build-site: warning: $left root-absolute link(s) left in plugins" >&2

# Hack (see typst-preamble.mjs): prepend preamble.typ to every formula, and make Typst errors
# render as red inline spans instead of aborting the whole build.
export QUARTZ_DIR="$Q" TYPST_PREAMBLE_FILE="$SITE/preamble.typ"
export NODE_OPTIONS="${NODE_OPTIONS:-} --import $SITE/scripts/typst-preamble.mjs"

cd "$Q"
rm -rf "$SITE/public"
LOG="$SITE/build.log"
npx quartz build -d "$Q/content" -o "$SITE/public" "$@" 2>&1 | tee "$LOG"
status=${PIPESTATUS[0]}
n=$( (grep -rho 'class="typst-error"' "$SITE/public" 2>/dev/null || true) | wc -l | tr -d ' ')
echo "build-site: $n formula(s) failed to compile (red in the page); log in $LOG"
(( status == 0 )) || exit "$status"

# Locked notes' real names: encrypted list + page script that shows them after an unlock
PW="${SITE_PASSWORD:-}"
[[ -z "$PW" && -f "$SITE/password" ]] && PW="$(head -n1 "$SITE/password")"
SITE_PASSWORD="$PW" node "$SITE/scripts/locked-titles.mjs" "$SITE/.locked-titles.tsv" "$SITE/public" "$prefix"

# Leak checks. On any failure the output is deleted, so nothing unsafe can be deployed.
fail() { rm -rf "$SITE/public"; echo "build-site: $*; output deleted" >&2; exit 1; }

# 1. Control: the search must find text that is supposed to be public, or a "no leak" below
#    would prove nothing.
pub_files=$(grep -rLE '^password:' "$Q/content" --include='*.md' | grep -v '/index\.md$' || true)
control=$( (printf '%s\n' "$pub_files" | tr '\n' '\0' | xargs -0 grep -hoE '^[A-Za-z][A-Za-z ,]{18,}[A-Za-z]' 2>/dev/null || true) | head -1)
[[ -n "$control" ]] || fail "leak check is broken: no public text to use as a control"
grep -rqF -- "$control" "$SITE/public" ||
  fail "leak check is broken: public text \"$control\" not found in the output"

# 2. Every phrase of every locked note (stage.sh: .locked-samples) must be absent from the output
#    (pages, search index, RSS, sitemap, scripts). Phrases that also occur in a public note are
#    skipped: finding those proves nothing.
leaks=0; checked=0
while IFS= read -r phrase; do
  [[ -n "$phrase" ]] || continue
  if [[ -n "$pub_files" ]] && printf '%s\n' "$pub_files" | tr '\n' '\0' | xargs -0 grep -qF -- "$phrase" 2>/dev/null; then
    continue
  fi
  checked=$((checked + 1))
  if grep -rqF -- "$phrase" "$SITE/public"; then
    echo "build-site: LEAK: \"$phrase\" from a locked note is readable in $(grep -rlF -- "$phrase" "$SITE/public" | head -1)" >&2
    leaks=$((leaks + 1))
  fi
done < <(sort -u "$SITE/.locked-samples")
(( leaks == 0 )) || fail "$leaks phrase(s) from locked notes are readable"

# 3. Every locked page must be encrypted: its <article> holds only the encrypted block. This also
#    covers notes that are nearly all math and give few phrases.
unenc=0; pages=0
while IFS=$'\t' read -r slug _; do
  [[ -n "$slug" ]] || continue
  pages=$((pages + 1))
  f="$SITE/public/$slug.html"
  if [[ ! -f "$f" ]] || ! perl -0777 -ne '
      my @a = /<article\b[^>]*>(.*?)<\/article>/sg; exit 1 unless @a;
      for (@a) { s/<div class="encrypted-page[^"]*" data-encrypted="[A-Za-z0-9+\/=]+" data-iterations="\d+"><\/div>//; exit 1 if /\S/ }
      exit 0' "$f"; then
    echo "build-site: NOT ENCRYPTED: $slug" >&2; unenc=$((unenc + 1))
  fi
done < "$SITE/.locked-titles.tsv"
(( unenc == 0 )) || fail "$unenc locked page(s) are not fully encrypted"

echo "build-site: leak check ok: $pages locked page(s) encrypted, $checked phrase(s) absent, control phrase found"
