# CLAUDE.md

This folder is an Obsidian vault of math notes. Math is written in **Typst syntax** (not LaTeX): Obsidian renders it with the Typst Mate plugin, which bundles Typst 0.14.2, and `_build/` turns notes into PDFs through Pandoc and the Typst CLI (0.15).

`Writing Workflow.md` is the user-facing guide. Keep it in sync when you change conventions or the build.

**`misc/` at the vault root is off limits.** It holds the user's personal notes. Never open, list, search, read, edit or build anything in it, with any tool (including shell commands like `cat`, `grep`, `find` or `ls`), and leave it out of vault-wide searches and builds. `.claude/settings.json` also denies Claude Code's file tools there. This is the root `misc/` only, not `notes/Misc/`.

## Layout

| Path | What |
|---|---|
| `notes/` | course notes and plain notes (`.md`) |
| `psets/` | problem sets. **A separate, private git repo**, ignored by the public one |
| `misc/` | the user's personal notes: never read or touch (see above) |
| `typst/` | standalone `.typ` documents (talk, bibliography, Spurious Notes, whose content now lives in `notes/Spurious-XOR/`), compiled with `typst compile` directly. Their PDFs are tracked |
| `_build/` | `build.sh`, `obsidian.lua` (Pandoc filter), `template.typ`, `envs.typ` (ctheorems environments), `macros.typ` (vault-wide macros), `tags/<tag>.typ` (per-course macros) |
| `_templates/` | Obsidian Templates plugin: Course index, Lecture, Research index, Meeting, Problem set, Problem, Proof, Book index, Chapter, Paper index, Paper proof, Article |
| `_site/` | the website (Quartz v5). Only `_site/scripts/` is tracked; Quartz itself, the staged content and `public/` are gitignored |
| `_pdf/` | all build output, mirroring the vault (psets too, under `_pdf/psets/`), gitignored |
| `examples/` | gitignored demo course, pset and book; `_build/tags/example-course.typ` is gitignored too |
| `.obsidian/` | vault config: `snippets/rice.css` (theme and editor spacing fixes) and `plugins/build-pdf/` (the Build PDF command) are tracked; other plugins, including Typst Mate and its settings, are gitignored |

## Building

```bash
_build/build.sh "notes/Misc/ODE Exam 1 Review.md" psets/MATH4320/HW1.md
```

- Output: `_pdf/<same path>.pdf` at the vault root, psets included. `KEEP_TYP=1` keeps the generated `.<name>.typ` next to the PDF.
- Build everything: `find notes psets examples -name '*.md' -not -path '*/_pdf/*' -print0 | xargs -0 _build/build.sh`.
- `_build/build-current.sh <note>` builds the note's course, book, research project or paper if its folder has a `type: course`, `book`, `research` or `paper` index, or, for a note in `Proofs/`, its parent folder has a `type: paper` one (otherwise the note itself), and opens the PDF. Obsidian runs it through the vault-local plugin `.obsidian/plugins/build-pdf/` (command "Build PDF", Cmd+Shift+B), which is tracked in git and adds Homebrew's bin folders to PATH; apps started from the Dock don't have them, so `pandoc`/`typst` would not be found. `NO_OPEN=1` skips opening.
- `obsidian.lua` runs as passes:
  1. Expand embeds. A `type: course`, `book` or `research` index with no embeds includes every sibling note whose name starts with a number, in numeric order (dated `YYYY-MM-DD` meeting names sort by the tie-break on the name); for courses and books the number sets the lecture or chapter number (`#counter(heading).update`). A `type: paper` index keeps its body and appends a `# Proofs` appendix: every `Proofs/<number> <name>.md` in the paper's order, under copies of the overview's `# B …` section headings. Each embedded note gets a `<note-…>` label, so a link to a whole note becomes `#link`. An embed of a block (`![](note.md#^id)`) restates that callout in the PDF (a copy without its `^id`s, so labels stay unique), the way course notes restate a theorem above its proof; other block embeds are dropped. Frontmatter `tags:` becomes `#import "/_build/tags/<tag>.typ"`, and `definitions:` becomes `#let` lines.
  2. Group open-form proofs, then turn `> [!todo]` and `> [!question]` callouts into `#mark-box("todo")[…] <todo-N>` (or `"question"`, `<question-N>`) and record them for the "Open Questions" and "Open TODOs" tables (the `mark-tables` template variable, questions first; on for papers or with `todo-table: true`).
  3. Turn `^id` block IDs into Typst labels.
  4. Convert math (verbatim), links (to `#ref`/`#link`) and callouts (to ctheorems environments).

  A preprocessing step before Pandoc strips `%% comments %%` and adds the blank lines Pandoc needs before headings and nested callouts. Pandoc reads with `-blank_before_blockquote`, so a callout can start right under a list item or line of text, as in Obsidian.

## Website

`_site/scripts/setup.sh` (once), then `_site/scripts/build-site.sh [--serve]` → `_site/public`. On push to `main`, `.github/workflows/site.yml` runs both on Ubuntu and deploys to GitHub Pages (peeda.github.io/Notes), so the scripts must stay portable: no BSD-only `sed -i ''`, use `perl -i`.

- **What it publishes:** `stage.sh` copies only `notes/` (`.md` and images), as the site root, and `attachments/` into `_site/.quartz/content`. Links climbing to `attachments/` lose one `../`. `ignorePatterns` must not list `misc`: the public `notes/Misc` sits at the root.
  - It must sit inside Quartz's own git repo: Quartz skips gitignored files, and the vault ignores `_site/`.
  - The copies are rewritten: `![](x.md#^id)` → `![[x#^id]]`; result titles get their kind, "Lemma B.1 (Title)"; folders without an `index.md` get one with a title; `type: pset` notes are dropped.
- **Math:** Quartz's `latex` plugin with `renderEngine: typst`, through rehype-typst 0.7.0, which runs Typst 0.14.2, the same as Typst Mate.
  - rehype-typst has no preamble option, so `typst-preamble.mjs` monkeypatches its `NodeCompiler.compile` through `node --import`. It prepends `_site/preamble.typ` to every formula.
  - The preamble is `macros.typ`, every tag file and every `definitions:` entry, combined. `stage.sh` fails if two of them define the same name.
  - The same patch turns a compile error into a red `typst-error` span. Without it, one error aborts the whole build.
- **Config:** `markdownLinkResolution: relative`, since the vault's links are relative paths. OFM `highlight` is off, since Typst's `==` would otherwise read as a highlight.
  - Off at the user's request: stacked pages, graph, og-image, and the Properties box (`hidePropertiesView: true`).
  - Keep the `note-properties` plugin itself enabled: in Quartz v5 it parses frontmatter, and without it every title becomes "Untitled".
  - Fonts: Space Grotesk headings at weight 500, Inter text, JetBrains Mono code. The user found serif too formal for the site and bold mono headings too heavy; samples of other pairings are in `_site/font-samples/`.
  - Dark mode by default: `build-site.sh` patches the darkmode plugin's first-visit theme to "dark" (the plugin otherwise follows the OS). The toggle still works and is remembered. Link color: the theorem blue `#2f4f80` (`#8fa9d6` in dark mode).
  - The explorer, search and graph plugins fetch `/static/contentIndex.json` from the domain root, which 404s under `peeda.github.io/Notes/` (empty explorer, broken search). `build-site.sh` rewrites it to `/Notes/static/...` from `baseUrl`, or `/static/...` with `--serve`.
- **Style** (`custom.scss`): unlike the PDFs, results (and TODOs, questions) are boxes: a 1px border and faint tint in the kind's hue, with a tinted title bar. The user asked for this look on the site only; the PDFs keep the plain amsthm style. Each kind has a lighter hue for dark mode (`--h`). Quartz colors the title's `<p>` with `--color`, so it is set from `--h`. Samples: `_site/box-samples/`. Wide display equations shrink to the column.
- Origin and test results: `~/Programming/typst_obsidian_testing/obsidian-typst-e2e/RESULTS.md`.

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
  - `course`: the index note of a course folder. One `NN Topic.md` per lecture, each with the course tag. The PDF has a contents page, a "Lecture N: Title" heading per lecture (N from the file name), and theorems numbered per lecture.
  - `pset`: problems are `> [!problem] <number>` callouts (the title is the number), followed by `*Solution.*`.
  - `book`: self-study exercises from a book (`title`, `book-author`). Index note plus `NN Chapter.md`, where NN is the book's chapter number. Exercises are `problem` callouts printed as "Exercise <title>" (untitled: chapter.position) with an ochre label, and proof-style solutions; `##` sections are unnumbered and carry the book's numbers in their text.
  - `research`: weekly meeting notes for a research project. Index note plus one `YYYY-MM-DD.md` per meeting, whose `#` heading is its date (`# October 27th meeting`, filled in by the *Meeting* template's `{{date:MMMM Do}}`). Styled like a course, but headings are unnumbered and theorems are numbered through the whole project.
  - `paper`: reading notes on a paper (`title`, `paper-author`). An overview note with `#` sections titled as in the paper (`# B $L_0$ Analysis`, `## B.1 …`), results as callouts titled with the paper's number (`> [!lemma] B.1 Title` → "Lemma B.1 (Title)", passed as `number:`), each followed by `→ [Proof](Proofs/….md)`; and `Proofs/<number> <name>.md` notes that start with an Obsidian-only `![](../<overview>.md#^id)` preview, then the proof.
  - `article`: a single note that is mostly text (`title`, `author`). Unnumbered headings, no contents page.
  - anything else: a plain note.
- **TODOs and questions** are `> [!todo]` and `> [!question]` callouts only (plain `TODO:` text isn't collected).
- **Migrating the user's writing** (e.g. from a `.typ` file into notes): keep their prose verbatim, typos and all. Change only syntax; never add your own prose, summaries or corrections. Headings are not prose: in paper notes they follow the paper's own section titles.
- **Macros:**
  - vault-wide in `_build/macros.typ`;
  - per course in `_build/tags/<tag>.typ`, with `tags: [<tag>]` in every note of the course;
  - one-off in a frontmatter `definitions:` list (`- 'Var = math.op("Var")'`).

  Operators are `math.op("name")`. How the three reach each renderer:
  - **Typst Mate** (Obsidian) builds a per-note preamble from frontmatter: `tags:` entries with a file in `<import path>/tags/` become `#import "<vault abs path>/_build/tags/<tag>.typ": *`, and `definitions:` entries become `#let <entry>;`. This is a Typst Mate feature, not Obsidian's.
  - **The PDF build** mirrors this in `obsidian.lua`: it reads raw frontmatter, since Pandoc would mangle `$…$` in metadata. It reads it for every embedded note too.
  - **`macros.typ`** reaches PDFs through `template.typ`, and Obsidian only through Typst Mate's preamble setting, which isn't in git.

## PDF style

The user cares about how the PDFs look. Keep changes within this style and check the result by rendering a page (`pdftoppm -png -r 70 -f 1 -l 1 x.pdf out`) rather than trusting the source. The style is classical, like an AMS article (`amsart`/`amsthm`). The user rejected the previous look, with its tinted boxes, colored left bars and spaced gray capitals, as "AI generated": don't bring those back.

- **Fonts:** text in New Computer Modern (serif), math in the default New Computer Modern Math. Lists use LaTeX's markers (•, –, ∗), since the font has no ‣.
- **Colors:** the Catppuccin palette (and the JetBrains Mono / Inter fonts) belong to Obsidian (`rice.css`) only, never the PDFs. Course, paper, book and plain-note PDFs color only the labels of results (in a tinted label box), each kind in one muted hue, plus cross-references in the theorem blue: theorem `#2f4f80`, lemma `#5a4a85`, definition `#2e6b5e`, problem outside psets `#4f5560`, book exercise `#7d5f2e`, TODO `#a0584a`, question `#5f7a3e` (`marks` in `template.typ`). **Psets and research meetings have no color** (`color` in `template.typ`, passed to `make-envs`).
- **Results** (`_build/envs.typ`, `plain()` and `tag()`): no box around the statement. With color, only the label "Theorem 3.2" sits in a small box: a pale tint of the kind's hue, bold text in the hue, 1.5pt corners, outset so it doesn't change line spacing; then "(Title)." and the statement (`label-style` also has "outline" and "solid", which the user saw and passed over). Without color, a plain bold run-in "**Theorem 3.2** (Title).". Theorem and lemma statements in italic, the others upright. Remarks: italic "*Remark.*".
- **Proofs and solutions:** italic "*Proof.*" / "*Solution.*", no bar, □ at the end (`thmrules.with(qed-symbol: …)`).
- **Page and spacing:** 1in margins, 11pt text, leading 0.75em, paragraphs 1.35em apart with a 1.2em first-line indent, list items 0.85em apart, 0.8em around each result. The user found the first classical version (1.25in side margins, default spacing) cramped and picked this "Comfortable" variant from samples.
- **Headings:** each level smaller than the one above, so nesting reads at a glance: level 1 bold 14pt, level 2 bold 12.5pt, level 3 bold 11pt, level 4 italic. Lecture, chapter and meeting openers are larger (17pt bold, centered).
- **Title blocks** (`title-block` in `template.typ`): centered; an optional italic line above ("Research meetings", "Exercises from", "Notes on"), the title in bold capitals, a line in small caps (the author, or "by <author>" for a book or paper), then an italic line (course · date, or author · date).
- **Course PDFs** (`course-style`): title block, then a contents page with "Lecture N. Title" entries and their `##` sections beneath; each lecture starts a new page under a centered small-caps "Lecture N" and its title in 17pt bold.
- **Book PDFs** (`book-style`): title block with "Exercises from" and "by <book-author>", "Solutions by <author>"; contents with "Chapter N. Title" entries; each chapter starts a new page under a centered small-caps "Chapter N" and its title in 17pt bold; running header with the italic book title left and "Chapter N · Title" right; `##` sections are unnumbered.
- **Research PDFs** (`research-style`): title block with "Research meetings"; contents with the meetings; each meeting starts a new page under its title, centered in 17pt bold, with no lecture number; much looser lines (leading 1.05em, paragraphs 1.7em apart) and list items 1.5em apart, since meeting notes are mostly prose and bullets, not math.
- **Paper PDFs** (`paper-style`): title block with "Notes on" and "by <paper-author>"; under it the "Open Questions" then "Open TODOs" tables; contents on its own page; sections don't start new pages; running header with the italic paper title; results numbered with the paper's numbers; the "Proofs" appendix starts a new page, and each proof opens with its statement restated, as in course notes.
- **Article PDFs** (`article-style`): the plain title block; no contents; unnumbered headings, with a fourth level in small caps; running header with the italic title; looser lines than the base (leading 0.85em, paragraphs 1.45em apart) and list items 1em apart.
- **TODO and question boxes** (`mark-box`): a thin frame (the one box left) with a bold run-in "To do." or "Question.", in rust or olive when the document has color, black otherwise. The tables (`mark-table`) have a centered small-caps title in that hue, booktabs rules in black, an italic header row, and page links in the hue.
- **Pset PDFs** (`pset-style`): the title block (title, author, course · date); each problem is a bold run-in "**Problem 3.**" with an upright statement; solutions read like proofs, italic "*Solution.*" and □.

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
- **Pset/book problem numbers and paper numbers:** these are passed to ctheorems by hand, so ctheorems' own `ref` would print a wrong one. `problemrefs` in `envs.typ` reads the number from an `<env-number>` metadata mark inside each environment instead.
- **The question and TODO tables come before the body**, so the build repeats the body's tag imports and `definitions:` above it; otherwise its math can't see the macros.
- **Leftover markup:** after a change to the build, check the PDFs for markup that slipped through: `pdftotext x.pdf - | grep -E '\$|\[!|#ref|\*Proof|%%|\^[a-z]'`.

## Git and privacy

- **Two repos:**
  - the public repo is github.com/Peeda/Notes;
  - `psets/` is a nested private repo, with no remote yet.

  Never commit pset content or pset PDFs to the public repo. Check `git ls-files` before committing.
- **PDFs:** they are untracked everywhere except under `typst/`.
- **Pushing:** don't push either repo unless the user asks.
- **Commits:** the user prefers few commits. While the latest commit is unpushed, fold follow-up tweaks into it with `git commit --amend` unless asked for a separate commit.
