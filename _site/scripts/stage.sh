#!/usr/bin/env bash
# Stage the vault for Quartz into _site/.quartz/content:
#   - notes/ (Markdown and images only) as the site root, attachments/ as attachments/;
#   - each folder of private/ (the private repo: psets/, Graph_SSD_Meetings/) at the root too,
#     every note in it password-locked (see "Lock private notes" below);
# and write _site/preamble.typ, the Typst preamble prepended to every formula.
# Nothing else in the vault is read (misc/, typst/, examples/ never are).
set -euo pipefail
SITE="$(cd "$(dirname "$0")/.." && pwd)"
VAULT="$(cd "$SITE/.." && pwd)"
C="$SITE/.quartz/content"   # inside Quartz's own git repo: Quartz skips gitignored files, and the vault ignores _site/
P_DIR="$VAULT/private"
SAMPLES="$SITE/.locked-samples"   # phrases from locked notes; build-site.sh checks none reach public/
TITLES="$SITE/.locked-titles.tsv" # slug <TAB> real title, for locked-titles.mjs

rm -rf "$C"; mkdir -p "$C"; : > "$SAMPLES"; : > "$TITLES"
md_filter=(--prune-empty-dirs --include='*/' --include='*.md' --include='*.png' --include='*.jpg'
           --include='*.jpeg' --include='*.gif' --include='*.svg' --include='*.webp' --exclude='*')
rsync -a "${md_filter[@]}" "$VAULT/notes/" "$C/"
[[ -d "$VAULT/attachments" ]] && rsync -a "$VAULT/attachments/" "$C/attachments/"

# Private folders, staged next to the public ones (locked further down)
locked=()
if [[ -d "$P_DIR" ]]; then
  for d in "$P_DIR"/*/; do
    [[ -d "$d" ]] || continue
    name="$(basename "$d")"
    if [[ -e "$C/$name" ]]; then
      echo "stage: private/$name clashes with notes/$name; rename one of them" >&2; exit 1
    fi
    rsync -a "${md_filter[@]}" "$d" "$C/$name/"
    [[ -d "$C/$name" ]] && locked+=("$C/$name")
  done
fi

# The site password: $SITE_PASSWORD (CI secret), else _site/password. Fail closed: without one,
# private notes would go out as plaintext.
PW="${SITE_PASSWORD:-}"
[[ -z "$PW" && -f "$SITE/password" ]] && PW="$(head -n1 "$SITE/password")"
if (( ${#locked[@]} )) && [[ -z "$PW" ]]; then
  echo "stage: private/ has notes but no password: set SITE_PASSWORD or write _site/password" >&2
  exit 1
fi

# Home page, unless notes/index.md exists
[[ -e "$C/index.md" ]] || printf -- '---\ntitle: Notes\n---\n' > "$C/index.md"

# Per-note rewrites on the copies
find "$C" -name '*.md' -print0 | while IFS= read -r -d '' f; do
  # psets outside private/ never go public, even if one lands in notes/ by mistake
  in_locked=0
  for l in ${locked[@]+"${locked[@]}"}; do [[ "$f" == "$l"/* ]] && in_locked=1; done
  if (( ! in_locked )) && head -20 "$f" | grep -qE '^type: *pset'; then rm "$f"; continue; fi
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

# Lock private notes: the encrypted-pages plugin encrypts any page with a `password:` field.
# Each note gets the password and the title "Locked"; its real title moves into the body as a
# "# " heading (encrypted with the rest), unless the body already opens with one. A note with an
# empty body (an index that only carries a title) stays unlocked, so its folder keeps its name.
n_locked=0
for l in ${locked[@]+"${locked[@]}"}; do
  while IFS= read -r -d '' f; do
    PW="$PW" SAMPLES="$SAMPLES" TITLES="$TITLES" CONTENT="$C" perl -e '
      my $file = shift;
      open my $in, "<", $file or die; my $src = do { local $/; <$in> }; close $in;
      my ($fm, $body) = $src =~ /\A---\n(.*?\n)---\n(.*)\z/s ? ($1, $2) : ("", $src);
      exit 0 unless $body =~ /\S/;   # empty body: leave the file as it is
      my ($title) = $fm =~ /^title:\s*(.*?)\s*$/m;
      $title = "" unless defined $title;
      $title =~ s/^(["\x27])(.*)\1$/$2/;
      (my $fname = $file) =~ s{.*/}{}; $fname =~ s/\.md$//;
      $title = $fname if $title eq "";
      # the page slug as Quartz writes links: path from the content root, no .md, spaces -> -
      (my $slug = $file) =~ s{^\Q$ENV{CONTENT}\E/}{}; $slug =~ s/\.md$//;
      $slug =~ s/ /-/g; $slug =~ s/&/-and-/g; $slug =~ s/%/-percent/g; $slug =~ s/[?#]//g;
      open my $t, ">>", $ENV{TITLES} or die; print $t "$slug\t$title\n"; close $t;
      $fm =~ s/^title:.*\n//mg; $fm =~ s/^password:.*\n//mg;
      (my $pw = $ENV{PW}) =~ s/(["\\])/\\$1/g;
      $fm = "title: Locked\npassword: \"$pw\"\n" . $fm;
      $body =~ s/\A\s*//;
      $body = "# $title\n\n$body" unless $body =~ /\A# /;
      # Leak-check phrases (build-site.sh): every run of 20+ plain characters outside math, and
      # the real title when it is more than the file name (names in URLs are public anyway).
      open my $s, ">>", $ENV{SAMPLES} or die;
      print $s "$title\n" if $title ne $fname && length($title) >= 6;
      my $in_math = 0;
      for my $line (split /\n/, $body) {
        (my $l = $line) =~ s/^(?:>\s?)+//;
        if ($l =~ /^\s*\$\$\s*$/) { $in_math = !$in_math; next }
        next if $in_math;
        $l =~ s/\$[^\$]*\$//g; $l =~ s/^#+\s*//;
        print $s "$1\n" while $l =~ /([A-Za-z][A-Za-z ,]{18,}[A-Za-z])/g;
      }
      close $s;
      open my $out, ">", $file or die; print $out "---\n$fm---\n$body"; close $out;
      exit 3;   # tells the shell this note was locked
    ' "$f" && continue || [[ $? == 3 ]] || { echo "stage: failed to lock $f" >&2; exit 1; }
    n_locked=$((n_locked + 1))
  done < <(find "$l" -name '*.md' -print0)
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
  find "$VAULT/notes" $( [[ -d "$P_DIR" ]] && echo "$P_DIR" ) -name '*.md' -print0 | xargs -0 awk '
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
echo "stage: $(find "$C" -name '*.md' | wc -l | tr -d ' ') notes ($n_locked locked), preamble $(wc -l < "$P" | tr -d ' ') lines"
