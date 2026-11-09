#!/usr/bin/env bash
# Stage the public part of the vault for Quartz: copy notes/ (Markdown and images only) as the
# site root, and attachments/ as attachments/, into _site/.quartz/content, and write _site/preamble.typ, the Typst preamble prepended to
# every formula. Nothing else in the vault is read (misc/, psets/, typst/, examples/ never are).
set -euo pipefail
SITE="$(cd "$(dirname "$0")/.." && pwd)"
VAULT="$(cd "$SITE/.." && pwd)"
C="$SITE/.quartz/content"   # inside Quartz's own git repo: Quartz skips gitignored files, and the vault ignores _site/

rm -rf "$C"; mkdir -p "$C"
img='--include=*.png --include=*.jpg --include=*.jpeg --include=*.gif --include=*.svg --include=*.webp'
# shellcheck disable=SC2086
rsync -a --prune-empty-dirs --include='*/' --include='*.md' $img --exclude='*' "$VAULT/notes/" "$C/"
[[ -d "$VAULT/attachments" ]] && rsync -a "$VAULT/attachments/" "$C/attachments/"

# Home page, unless notes/index.md exists
[[ -e "$C/index.md" ]] || printf -- '---\ntitle: Notes\n---\n' > "$C/index.md"

# Per-note rewrites on the copies
find "$C" -name '*.md' -print0 | while IFS= read -r -d '' f; do
  # psets never go public, even if one lands in notes/ by mistake
  if head -20 "$f" | grep -qE '^type: *pset'; then rm "$f"; continue; fi
  # notes/ is the site root, one level up: ../../attachments/x.png -> ../attachments/x.png
  perl -i -pe 's{(\]\(|\[\[)((?:\.\./)+)attachments/}{$1 . substr($2, 3) . "attachments/"}ge' "$f"
  # ![](../Proof%20Overview.md#^b5) ->![[../Proof Overview#^b5]] so Quartz transcludes the block
  perl -i -pe 's{!\[[^\]]*\]\(([^()]+?)\.md(#[^)]*)?\)}{ my ($n,$a)=($1,$2//""); $n=~s/%20/ /g; "![[$n$a]]" }ge' "$f"
  # Titled results read as in the PDFs: "[!lemma] B.1 Title" -> "Lemma B.1 (Title)",
  # "[!theorem] Title" -> "Theorem (Title)". Quartz shows only the title otherwise.
  perl -i -pe 's{^((?:> ?)+)\[!(theorem|lemma|definition|problem|remark)\]([-+]?) +(\S.*?)\s*$}{
    my ($q,$k,$fold,$t)=($1,$2,$3,$4); my $K=ucfirst $k;
    if ($t =~ /^\Q$K\E\b/i) { "$q\[!$k\]$fold $t\n" }
    elsif ($t =~ /^((?:[A-Z]|\d+)(?:\.\d+)+|\d+)\.?(?:\s+(.*))?$/) { "$q\[!$k\]$fold $K $1" . (defined $2 && length $2 ? " ($2)" : "") . "\n" }
    else { "$q\[!$k\]$fold $K ($t)\n" } }ge' "$f"
done

# Folders without an index.md get one, so the explorer and folder pages show a plain name
find "$C" -type d -print0 | while IFS= read -r -d '' d; do
  [[ "$d" == "$C" || "$d" == "$C/attachments"* || -e "$d/index.md" ]] && continue
  printf -- '---\ntitle: "%s"\n---\n' "$(basename "$d")" > "$d/index.md"
done

# Preamble: vault macros, every tag file, every frontmatter `definitions:` entry
P="$SITE/preamble.typ"
{
  echo '#set text(font: "New Computer Modern")'
  cat "$VAULT/_build/macros.typ"
  for t in "$VAULT"/_build/tags/*.typ; do
    [[ "$(basename "$t")" == example-course.typ ]] && continue
    printf '\n// ---- %s\n' "$(basename "$t")"; cat "$t"
  done
  printf '\n// ---- definitions:\n'
  find "$VAULT/notes" -name '*.md' -print0 | xargs -0 awk '
    FNR==1 { fm=0; defs=0 }
    /^---$/ { fm++; next }
    fm==1 && /^definitions:/ { defs=1; next }
    fm==1 && defs && /^ *- / { s=$0; sub(/^ *- */,"",s); gsub(/^'\''|'\''$/,"",s); gsub(/^"|"$/,"",s); print "#let " s; next }
    fm==1 && defs && /^[^ ]/ { defs=0 }
  ' | sort -u
} > "$P"

dups=$(grep -oE '^#let +[A-Za-z_][A-Za-z0-9_-]*' "$P" | awk '{print $2}' | sort | uniq -d)
if [[ -n "$dups" ]]; then
  echo "stage: macro names defined twice in the combined preamble (tag files clash):" >&2
  echo "$dups" >&2; exit 1
fi
echo "stage: $(find "$C" -name '*.md' | wc -l | tr -d ' ') notes, preamble $(wc -l < "$P" | tr -d ' ') lines"
