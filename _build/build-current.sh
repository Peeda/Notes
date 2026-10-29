#!/usr/bin/env bash
# usage: _build/build-current.sh path/to/note.md
# For an Obsidian hotkey (Shell commands plugin): builds what the open note
# belongs to and opens the PDF. A note in a folder with a `type: course`,
# `type: book` or `type: research` index builds the whole folder, and so does a note in a folder
# with a `type: paper` index or in its Proofs/ subfolder; any other note
# (psets, plain notes) builds itself.
set -euo pipefail
VAULT="$(cd "$(dirname "$0")/.." && pwd)"
note="$1"
target="$note"
is_index() {
  awk -v types="$2" 'NR==1 && $0!="---"{exit 1} NR>1 && $0=="---"{exit 1} $0 ~ "^type: *(" types ") *$"{found=1; exit} END{exit !found}' "$1"
}
dir="$(dirname "$note")"
for f in "$dir"/*.md; do
  if is_index "$f" "course|book|research|paper"; then target="$f"; break; fi
done
if [[ "$target" == "$note" && "$(basename "$dir")" == "Proofs" ]]; then
  for f in "$(dirname "$dir")"/*.md; do
    if is_index "$f" "paper"; then target="$f"; break; fi
  done
fi
pdf="$("$VAULT/_build/build.sh" "$target" | tail -1)"
[[ "${NO_OPEN:-0}" == "1" ]] || open "$VAULT/$pdf"
echo "$pdf"
