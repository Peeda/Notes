# CLAUDE.md

This folder is an Obsidian vault of math notes. Math is written in **Typst syntax** (not LaTeX): Obsidian renders it with the Typst Mate plugin, which bundles Typst 0.14.2, and `_build/` turns notes into PDFs through Pandoc and the Typst CLI (0.15).

`Writing Workflow.md` is the user-facing guide. Keep it in sync when you change conventions or the build.

## Layout

| Path | What |
|---|---|
| `notes/` | course notes and plain notes (`.md`) |
| `psets/` | problem sets. **A separate, private git repo**, ignored by the public one |
| `typst/` | standalone `.typ` documents (talk, bibliography, Spurious Notes), compiled with `typst compile` directly. Their PDFs are tracked |
| `_build/` | `build.sh`, `obsidian.lua` (Pandoc filter), `template.typ`, `envs.typ` (ctheorems environments), `macros.typ` (vault-wide macros), `tags/<tag>.typ` (per-course macros) |
| `_templates/` | Obsidian Templates plugin: Course index, Lecture, Problem set, Problem, Proof |
| `_pdf/`, `psets/_pdf/` | build output, gitignored |
| `examples/` | gitignored demo course and pset; `_build/tags/example-course.typ` is gitignored too |
| `.obsidian/` | vault config: `snippets/rice.css` (theme and editor spacing fixes) and `plugins/build-pdf/` (the Build PDF command) are tracked; other plugins, including Typst Mate and its settings, are gitignored |

## Building

```bash
_build/build.sh "notes/Misc/ODE Exam 1 Review.md" psets/MATH4320/HW1.md
```

- Output: `_pdf/<same path>.pdf`, or `psets/_pdf/…` for psets. `KEEP_TYP=1` keeps the generated `.<name>.typ` next to the PDF.
- Build everything: `find notes psets examples -name '*.md' -not -path '*/_pdf/*' -print0 | xargs -0 _build/build.sh`.
- `_build/build-current.sh <note>` builds the note's course if its folder has a `type: course` index (otherwise the note itself) and opens the PDF. Obsidian runs it through the vault-local plugin `.obsidian/plugins/build-pdf/` (command "Build PDF", Cmd+Shift+B), which is tracked in git and adds Homebrew's bin folders to PATH; apps started from the Dock don't have them, so `pandoc`/`typst` would not be found. `NO_OPEN=1` skips opening.
- `obsidian.lua` runs as passes:
  1. Expand embeds. A `type: course` index with no embeds includes every sibling note whose name starts with a number, in numeric order. Frontmatter `tags:` becomes `#import "/_build/tags/<tag>.typ"`, and `definitions:` becomes `#let` lines.
  2. Group open-form proofs.
  3. Turn `^id` block IDs into Typst labels.
  4. Convert math (verbatim), links (to `#ref`/`#link`) and callouts (to ctheorems environments).

  A preprocessing step before Pandoc strips `%% comments %%` and adds the blank lines Pandoc needs before headings and nested callouts.

## Note conventions

- **Math:**
  - inline is `$x$` with no padding spaces;
  - display is `$$` on its own lines, with no blank lines inside;
  - don't put blank lines between a display block and its surrounding text, or around it in a list item: indent the block under the item instead. Every blank line shows in Obsidian's editor.
- **Typst math semantics:** products need spaces (`a b`), and text goes in quotes. Never convert math to LaTeX.
- **Statements:** use callouts, `> [!theorem] Title`, with `lemma`, `definition`, `problem`, `remark`. Every line of a callout, including `$$` lines, starts with `> `.
- **Proofs and solutions** are plain text, so they keep live preview:
  - start: a paragraph beginning with `*Proof.*`, `*Proof of [Lemma](#^id).*` or `*Solution.*`;
  - end: a paragraph ending in ∎, the next heading, the next statement callout, or the next proof.
- **References:**
  - Tag a callout with `^id` on its own line after it, with a blank line between; tag an equation with `^id` on the line right after its closing `$$`.
  - Link with `[Lemma](#^id)` or `[Theorem](other%20note.md#^id)`. Link text equal to an environment name (or Section/Lecture/Equation) gives a numbered `#ref`; any other text gives `#link`.
  - Only equations that have an ID are numbered.
- **Links and images:** Markdown links with relative paths (`app.json` sets `useMarkdownLinks`), spaces written as `%20`. Images go in `attachments/`.
- **Document types** (frontmatter `type:`):
  - `course`: the index note of a course folder. One `NN Topic.md` per lecture, each with the course tag. The PDF has a contents page, a "Lecture N: Title" heading per lecture, and theorems numbered per lecture.
  - `pset`: problems are `> [!problem] <number>` callouts (the title is the number), followed by `*Solution.*`.
  - anything else: a plain note.
- **Macros:**
  - vault-wide in `_build/macros.typ`;
  - per course in `_build/tags/<tag>.typ`, with `tags: [<tag>]` in every note of the course;
  - one-off in a frontmatter `definitions:` list (`- 'Var = math.op("Var")'`).

  Operators are `math.op("name")`. How the three reach each renderer:
  - **Typst Mate** (Obsidian) builds a per-note preamble from frontmatter: `tags:` entries with a file in `<import path>/tags/` become `#import "<vault abs path>/_build/tags/<tag>.typ": *`, and `definitions:` entries become `#let <entry>;`. This is a Typst Mate feature, not Obsidian's.
  - **The PDF build** mirrors this in `obsidian.lua`: it reads raw frontmatter, since Pandoc would mangle `$…$` in metadata. It reads it for every embedded note too.
  - **`macros.typ`** reaches PDFs through `template.typ`, and Obsidian only through Typst Mate's preamble setting, which isn't in git.

## PDF style

The user cares about how the PDFs look. Keep changes within this style and check the result by rendering a page (`pdftoppm -png -r 70 -f 1 -l 1 x.pdf out`) rather than trusting the source.

- **Fonts:** text in New Computer Modern Sans; math stays in the default New Computer Modern Math (the user rejected Sans Math).
- **Colors:** the Catppuccin palette (and the JetBrains Mono / Inter fonts) belong to Obsidian (`rice.css`) only, never the PDFs. PDFs are black and grays, except the muted environment colors below.
- **Theorem-like boxes** (`_build/envs.typ`, `boxed()`): a faint tint, a 2.5pt bar on the left, square corners, and the label in the accent color. Each type gets one muted hue: theorem `#4a6a9b`, lemma `#76679e`, definition `#4a8a7c`, problem outside psets `#6f747c`. Don't go back to solid pastel fills.
- **Proofs:** italic *Proof*, no bar, ∎ at the end.
- **Course PDFs** (`template.typ`, `course-style`):
  - title block inside the margins, no full-width band: spaced gray capitals for the course code, a 30pt bold title, a heavy rule over a hairline, author left and date right;
  - then a contents page: bold "Lecture N  Title" entries with their `##` sections beneath;
  - each lecture starts a new page with one heading, "Lecture N: Title".
- **Pset PDFs** (`pset-style` and `make-envs(pset: true)`):
  - a header with title, course, author and date;
  - each problem is a bold "Problem 3" followed by a gray hairline to the margin, with no box and no color;
  - each solution has a bold **Solution:** label and a gray bar down its left side.

## Obsidian look

`rice.css` is a Linux-desktop-style theme in the Catppuccin palette (Mocha dark, Latte light):
- **Line width:** readable line length stays on, with `--file-line-width: 100ch`, about the ~100 characters per line of the PDFs.
- **Fonts:** JetBrains Mono Light for note text (`--font-weight: 300`; headings and callout titles at 600), Inter for the interface. Both are set in `appearance.json` too.
- **Callouts:** bordered boxes with a `[ lemma ]` style tag; proofs get a dashed rail and a `$ proof` heading.
- **Spacing fixes:** these were tuned with the user from DOM measurements in Obsidian's console. Change them only after measuring again.
  - display math padding (Typst Mate's `mjx-container`);
  - collapsing the leftover indent line above list-item equations;
  - shrinking `^id` lines.

## Gotchas

- **Two Typst versions:** Typst Mate runs 0.14.2, the CLI 0.15.1, so math must work in both. Use `chevron.l`/`chevron.r` (not `angle.l`, which 0.15 removed). Avoid names deprecated in 0.15 whose replacements don't exist in 0.14, such as `lt.tri`; write the Unicode symbol instead (⊲).
- **Typst Mate imports need absolute paths:** it reads imported files from disk, so its preamble must use the vault's full path, `#import "/Users/peter/Documents/Sync/typesetting/_build/macros.typ": *`. A `/_build/…` path fails with "failed to load file". The PDF build is different: it uses `--root` at the vault, so `/_build/…` is right there.
- **Tag files are read at startup:** Typst Mate reads `_build/tags/*.typ` only when Obsidian starts. After adding or editing one, the user must run "Typst Mate: Reload tag files". Its Import path setting must be `_build`.
- **Typst Mate's container:** it renders into an `mjx-container`, so Obsidian's MathJax CSS applies to it. `rice.css` overrides the padding.
- **Held keys show an accent popup in Obsidian:** that's macOS press-and-hold. The user can turn it off for Obsidian only with `defaults write md.obsidian ApplePressAndHoldEnabled -bool false` and an Obsidian restart.
- **Case-insensitive filesystem:** macOS treats `Notes` and `notes` as the same name, so a rename that only changes case needs two steps through a temporary name.
- **Leftover markup:** after a change to the build, check the PDFs for markup that slipped through: `pdftotext x.pdf - | grep -E '\$|\[!|#ref|\*Proof|%%|\^[a-z]'`.

## Git and privacy

- **Two repos:**
  - the public repo is github.com/Peeda/Notes;
  - `psets/` is a nested private repo, with no remote yet.

  Never commit pset content or pset PDFs to the public repo. Check `git ls-files` before committing.
- **PDFs:** they are untracked everywhere except under `typst/`.
- **Pushing:** don't push either repo unless the user asks.
- **Commits:** the user prefers few commits. While the latest commit is unpushed, fold follow-up tweaks into it with `git commit --amend` unless asked for a separate commit.
