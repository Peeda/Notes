#!/usr/bin/env bash
# usage: _build/build-current.sh path/to/note.md
# For an Obsidian hotkey (Shell commands plugin): builds what the open note
# belongs to and opens the PDF. A note in a folder with a `type: course` index
# builds the whole course; any other note (psets, plain notes) builds itself.
set -euo pipefail
VAULT="$(cd "$(dirname "$0")/.." && pwd)"
note="$1"
target="$note"
for f in "$(dirname "$note")"/*.md; do
  if awk 'NR==1 && $0!="---"{exit 1} NR>1 && $0=="---"{exit 1} /^type: *course *$/{found=1; exit} END{exit !found}' "$f"; then
    target="$f"; break
  fi
done
pdf="$("$VAULT/_build/build.sh" "$target" | tail -1)"
[[ "${NO_OPEN:-0}" == "1" ]] || open "$VAULT/$pdf"
echo "$pdf"
