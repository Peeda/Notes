#!/usr/bin/env bash
# Install pinned Quartz v5 into _site/.quartz, with rehype-typst 0.7.0 (Typst 0.14.2, as in
# Typst Mate). Adapted from ~/Programming/typst_obsidian_testing/obsidian-typst-e2e/scripts/setup.sh.
set -euo pipefail
SITE="$(cd "$(dirname "$0")/.." && pwd)"
Q="$SITE/.quartz"

QUARTZ_REPO=https://github.com/jackyzha0/quartz.git
QUARTZ_TAG=v5.0.0
QUARTZ_COMMIT=ab346fa66a895e12d63a308e70ce330ba795822a
LATEX_PLUGIN_COMMIT=5b9b86415be06395a855d01e8899d625e5131d5b   # quartz-community/latex v1.0.0
REHYPE_TYPST=@myriaddreamin/rehype-typst@0.7.0

nmaj=$(node --version | sed -E 's/^v([0-9]+).*/\1/')
(( nmaj >= 22 )) || { echo "Quartz $QUARTZ_TAG requires Node >= 22" >&2; exit 1; }

if [[ ! -d "$Q/.git" ]]; then
  git -c advice.detachedHead=false clone -q --depth 1 --branch "$QUARTZ_TAG" "$QUARTZ_REPO" "$Q"
fi
[[ "$(git -C "$Q" rev-parse HEAD)" == "$QUARTZ_COMMIT" ]] || { echo "unexpected Quartz commit in $Q" >&2; exit 1; }

cd "$Q"
[[ -d node_modules ]] || npm ci --no-audit --no-fund

# Pin the latex plugin to v1.0.0, which uses Quartz's own rehype-typst (peer dependency).
node -e '
  const fs = require("fs"), f = "quartz.lock.json", l = JSON.parse(fs.readFileSync(f));
  if (l.plugins.latex.commit !== process.argv[1]) {
    l.plugins.latex.commit = process.argv[1];
    fs.writeFileSync(f, JSON.stringify(l, null, 2) + "\n");
  }' "$LATEX_PLUGIN_COMMIT"
if [[ -d .quartz/plugins/latex ]] &&
   [[ "$(git -C .quartz/plugins/latex rev-parse HEAD)" != "$LATEX_PLUGIN_COMMIT" ]]; then
  rm -rf .quartz/plugins/latex
fi
cp "$SITE/scripts/quartz.config.yaml" quartz.config.yaml
npx quartz plugin restore 2>&1 | grep -v "directory exists, skipping" || true

npm install --no-save --no-audit --no-fund "$REHYPE_TYPST"
echo "setup done"
