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
exit "$status"
