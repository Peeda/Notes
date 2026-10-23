#!/usr/bin/env bash
# usage: _build/build.sh note.md [note2.md ...]
# Writes each PDF under _pdf/, mirroring the vault layout
# (notes/MATH4320/HW1.md -> _pdf/notes/MATH4320/HW1.pdf); notes under psets/
# go to psets/_pdf/ instead, so private output stays in the private repo.
# KEEP_TYP=1 keeps the intermediate Typst source next to the PDF (.<note>.typ).
set -euo pipefail
VAULT="$(cd "$(dirname "$0")/.." && pwd)"
# Obsidian allows a list right after a line of text (e.g. under "> [!lemma]")
FROM=markdown+wikilinks_title_after_pipe+lists_without_preceding_blankline-latex_macros-raw_tex

for note in "$@"; do
  abs="$(cd "$(dirname "$note")" && pwd)/$(basename "$note")"
  rel="${abs#"$VAULT"/}"
  case "$rel" in
    psets/*) out="$VAULT/psets/_pdf/${rel#psets/}" ;;
    *)       out="$VAULT/_pdf/$rel" ;;
  esac
  out="${out%.md}.pdf"
  mkdir -p "$(dirname "$out")"
  tmp="$(dirname "$out")/.$(basename "$out" .pdf).typ"

  pandoc "$abs" -f "$FROM" -t typst --wrap=preserve \
    --template "$VAULT/_build/template.typ" \
    --lua-filter "$VAULT/_build/obsidian.lua" \
    -o "$tmp"
  typst compile --root "$VAULT" "$tmp" "$out"
  [[ "${KEEP_TYP:-0}" == "1" ]] || rm "$tmp"
  echo "${out#"$VAULT"/}"
done
