---
title: Writing Workflow
---

# Writing workflow

The vault holds three kinds of documents:

| Kind | Where | Becomes |
|---|---|---|
| **Course notes** | `notes/<Course>/`, one note per lecture plus an index | one PDF for the course, with lectures, theorems, proofs and references |
| **Problem sets** | `psets/<Course>/HW<n>.md`, one note per assignment | a homework PDF: header, numbered problems, solutions |
| **Plain notes** | anywhere under `notes/` | a simple PDF |

Anything that is really a typeset document (a talk, a paper draft, Spurious Notes) stays a `.typ` file in `typst/`, compiled with `typst compile` directly.

Working examples of both main kinds live in `examples/`. That folder is ignored by git; copy from it freely.

## 1. Making PDFs

```bash
_build/build.sh "notes/MATH 4107/MATH 4107 Notes.md"
```

That's the whole process, one note at a time. Other forms:

```bash
_build/build.sh psets/MATH4107/HW1.md psets/MATH4107/HW2.md
```

```bash
find notes -name '*.md' -exec _build/build.sh {} +
```

- The second form builds several notes; the third builds every note under `notes/`.
- **Where PDFs go:** PDFs never land next to your notes. They go to `_pdf/`, mirroring the vault: `notes/MATH 4107/MATH 4107 Notes.md` becomes `_pdf/notes/MATH 4107/MATH 4107 Notes.pdf`. Pset PDFs go to `psets/_pdf/` instead, so they stay inside the private repo. Both folders are ignored by git.
- **Debugging:** run with `KEEP_TYP=1` to keep the generated Typst source as `.<name>.typ` next to the PDF.

**From Obsidian:** press **Cmd+Shift+B**, or run **Build PDF** from the command palette (Cmd+P). It comes from the vault's own small plugin, `.obsidian/plugins/build-pdf/`. It saves the note and runs `_build/build-current.sh` on it, which builds the note's course (for a lecture or course index) or the note itself, and opens the PDF. A notice says when it's done, or shows the error if the build fails. To enable it the first time, go to Settings → Community plugins and turn on "Build PDF". The hotkey can be changed under Settings → Hotkeys.

**What happens inside `build.sh`:**
1. Pandoc reads the note, with `_build/obsidian.lua` translating Obsidian syntax:
   - embeds are expanded (a course index with none includes its numbered lecture notes);
   - `%% comments %%` are removed;
   - callouts become environments;
   - `^id`s become labels and links become references;
   - math is passed through untouched.
2. Pandoc fills `_build/template.typ`: the page layout, the document type and the macros.
3. `typst compile` turns the result into the PDF.

You need Pandoc 3+ and Typst 0.14+.

## 2. Writing basics (all kinds)

- **Math is Typst syntax:**
  - inline is `$x^2$` (no spaces just inside the dollars);
  - display is a `$$` block with the `$$` on their own lines and no blank lines inside;
  - products need spaces (`a b`), and text goes in quotes (`"if "`).
- **Statements go in callouts:**
  ```markdown
  > [!theorem] Optional title, may contain $math$
  > Statement, with $math$ and lists.
  ```
  | Callout | PDF |
  |---|---|
  | `theorem`, `lemma`, `definition` | colored box, one shared counter (Theorem 1.2, Lemma 1.3, …) |
  | `problem` | gray box, numbered (see psets) |
  | `remark` | unnumbered |
  | `proof`, `solution` | italic heading, ends with ∎ |
  | anything else (`note`, `todo`, …) | a quote with a bold title |
- **Proofs and solutions are plain text**, so you keep Obsidian's live preview while writing them:
  ```markdown
  *Proof.* First we show …

  $$
  a = b
  $$

  … which proves the claim. ∎
  ```
  - A proof starts at a paragraph beginning with an italic *Proof* (`*Proof.*`, `*Proof:*`, `*Proof of [Lemma](#^id).*`) or *Solution*.
  - It ends at the first of: a paragraph or list ending in ∎ (or □), the next heading, the next statement callout, or the next proof.

    So ∎ is only needed when ordinary text follows. The PDF adds its own.
  - Other callouts such as `> [!todo]` can sit inside a proof.
- **Comments:** `%% … %%`, inline or across lines, are left out of the PDF and hidden in Obsidian's reading view. The editor still shows them, dimmed.
- **No blank lines around `$$` blocks.** Write a display equation directly between the lines of text it belongs to, or indent it under its list item. Every blank line shows as an empty line in Obsidian's editor, and none are needed for the PDF.
- **Headings and callouts** can follow a list or paragraph directly. A plain line right after a list item continues that item, so leave a blank line to start a new paragraph.
- **Images:** keep them in `attachments/` and link relatively, as in `![caption](../../attachments/fig.png)`.

## 3. Course notes

**Layout:** one folder per course: an index note, and one note per lecture whose name starts with its number.

```
notes/MATH 4107/
├── MATH 4107 Notes.md            ← index: build this
├── 01 Groups.md
├── 02 Subgroups and Lagrange.md
└── 03 Homomorphisms.md
```

**Index note** (template: *Course index*):

```markdown
---
type: course
title: Algebra I Lecture Notes
course: MATH 4107
author: Peter Chen
date: Fall 2026
tags: [math4107]
---
```

- **That's the whole index:** create it once and never edit it.
- **What the build includes:** every note in the folder whose name starts with a number (`01 Groups.md`, `2 Rings.md`, `10 Fields.md`), in numeric order. So a new lecture is part of the course PDF as soon as you create it.
- **To choose the lectures or their order yourself:** list them as embeds in the index, one per paragraph, with spaces written as `%20`, e.g. `![](01%20Groups.md)`. If the index has any embeds, only those are used. Obsidian then also shows the lectures inline in the index.

**Lecture note** (template: *Lecture*): the course tag, then one top-level heading naming the topic.

```markdown
---
tags: [math4107]
---

# Groups

## Definition and examples
…
```

**In the PDF:**
- **Contents:** the first page has the title and a table of contents. Each lecture is a bold entry ("Lecture 2  Subgroups and Lagrange's theorem"), with its `##` sections listed beneath it, all with clickable page numbers.
- **Lectures:** each top-level heading becomes "Lecture N: Title" on a new page, and its `##` sections are numbered N.1, N.2, ….
- **Numbering:** theorems, lemmas and definitions are numbered per lecture (Theorem 2.3). Lectures and theorems are numbered in lecture order.
- **Running header:** the course title and author, on every page after the first.
- **Building a single lecture** works too; it just numbers as Lecture 1.

**Course macros** live in `_build/tags/<tag>.typ`, one file per course, and every note of the course carries `tags: [<tag>]`. Both the PDF build and Typst Mate import that file for tagged notes.

```typst
// _build/tags/math4107.typ
#let ord = math.op("ord")
#let gen(x) = $lr(chevron.l #x chevron.r)$
```

- **After creating or editing a tag file**, run Cmd+P → "Typst Mate: Reload tag files" with a note open, or restart Obsidian. Typst Mate reads tag files only at startup; until then it reports the new macros as unknown variables. The PDF build always reads the current file.
- **Vault-wide macros:** these go in `_build/macros.typ`, which Typst Mate also reads through its preamble.
- **One-off macros for a single note:** use a frontmatter `definitions:` list, e.g. `- 'wsig = $bw _"sig"$'`.

**References** between results, within a lecture or across lectures:

1. Give the result an ID: `^id` on its own line after the callout, with a blank line between. For an equation, put `^id` on the line right after its closing `$$`; only equations with IDs get numbers.
   ```markdown
   > [!theorem] Lagrange
   > If $G$ is finite and $H <= G$ then $abs(H) | abs(G)$.

   ^thm-lagrange
   ```
2. Link to it. Obsidian can autocomplete this: type `[[^^` to search blocks.

   | You write | PDF shows |
   |---|---|
   | `[Theorem](#^thm-lagrange)` | "Theorem 2.3", clickable |
   | `[Lemma](01%20Groups.md#^lem-unique)` | "Lemma 1.2", across lectures |
   | `[Equation](#^eq-lagrange)` | "Equation 2" |
   | `[Lecture](#Groups)` | "Lecture 1" (links to a heading by its text) |
   | `[the coset lemma](#^lem-cosets)` | that text, clickable |

   - **Link text:** if it is exactly Theorem, Lemma, Definition, Problem, Equation, Section or Lecture, you get the automatic numbered reference. Other text gives a plain link.
   - **Obsidian** shows the text you wrote; only the PDF has numbers.
   - **Proofs, solutions and remarks** have no number, so link to them with your own text.

See `examples/course-notes/` for all of this in five short lectures.

## 4. Problem sets

One note per assignment (template: *Problem set*), in the private `psets/` repo:

```markdown
---
type: pset
title: Homework 1
course: MATH 4107
author: Peter Chen
date: 2026-09-05
tags: [math4107]
---

> [!problem] 1
> Show that a group in which every element satisfies $a^2 = e$ is abelian.

*Solution.* Let $a, b in G$. Then …
```

- **Problem numbers:** the problem callout's title is its number, so `> [!problem] 3.14` prints "Problem 3.14", to match the textbook. A problem with no title is numbered by its position.
- **Solutions:** write them in the open *Solution.* form, so long solutions keep live preview. Parts can be a list (`1.`, `2.`) inside the problem and inside the solution.
- **PDF layout:** a header with the title, course, author and date, plus a running header with your name and the assignment on later pages. Headings are unnumbered.
- **Macros:** tag the pset with the course tag to share the course's macros.
- **Building:** `_build/build.sh psets/MATH4107/HW1.md` writes `psets/_pdf/MATH4107/HW1.pdf`. That folder sits inside the private repo and is ignored there too.

See `examples/problem-set/HW1.md`.

## 5. Templates

Obsidian's Templates plugin reads `_templates/`. Insert one with Cmd+P → "Templates: Insert template", or bind that command under Settings → Hotkeys.

| Template | For |
|---|---|
| *Course index* | a new course's index note: just the `type: course` frontmatter |
| *Lecture* | a new lecture: tag frontmatter plus `# {{title}}` |
| *Problem set* | a new assignment: `type: pset` frontmatter and a first problem |
| *Problem* | another problem with its solution |
| *Proof* | `*Proof.*` … `∎` |

After inserting one, fill in `course:` and `tags:`, and drop the number prefix from a lecture's heading. A note without the course tag loses the course macros, and Typst Mate shows an unknown-variable error.

## 6. Options and settings

**Frontmatter options:**

| Key | Values | Default |
|---|---|---|
| `type` | `course`, `pset` (anything else is a plain note) | plain note |
| `title`, `course`, `author`, `date` | text, shown in the PDF header | none |
| `tags` | the course tag(s) whose macros to import | none |
| `heading-numbering` | a Typst pattern such as `"1.a"`, or `none` | `1.` notes, `1.1` course, `none` pset |
| `thm-base-level` | `1` (per lecture or section), `2`, …, or `none` (one counter) | `1`; `none` for psets |
| `definitions` | list of one-off macros, `'name = $…$'` | none |

**Typst Mate settings:**
- **Import path:** `_build`. This is what makes course tag files work in Obsidian.
- **Preamble:** keep the defaults, then add `#import "/Users/peter/Documents/Sync/typesetting/_build/macros.typ": *` as the last line. The path must be the vault's full path on disk: Typst Mate reads imports from the filesystem, so `/_build/…` gives "failed to load file". The path is machine-specific, so set it again on another computer. Pasting the file's `#let` lines also works.

## 7. Starting a new course: checklist

1. Create `notes/<Course>/`, add the index note (*Course index*) and `01 <Topic>.md` (*Lecture*).
2. Create `_build/tags/<course>.typ` and set `tags: [<course>]` in the index and every lecture.
3. Each lecture: add `NN Topic.md` (*Lecture*). The build picks it up automatically.
4. Give `^id`s to results you'll cite, and reference them with `[Theorem](…#^id)`.
5. Problem sets: `psets/<Course>/HW<n>.md` from *Problem set*, with the same tag.
6. Build the index (and each pset) and look over the PDFs in `_pdf/`.
