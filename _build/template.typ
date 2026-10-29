#import "/_build/macros.typ": *
#import "/_build/envs.typ": make-envs, thmrules, problemrefs

// Document type, from frontmatter `type:`
//   course: lecture notes; each top-level heading is a numbered lecture
//   pset:   problem set; homework header, problems numbered by their title
//   book:   self-study exercises from a book; each top-level heading is a
//           chapter, exercises numbered by their title as in psets
//   research: weekly meeting notes for a research project; each top-level
//           heading is a meeting, titled by its date ("October 27th meeting")
//   paper:  reading notes on a paper: an overview whose results keep the
//           paper's numbers, then a "Proofs" appendix of the proof notes
//   other:  plain note
#let doc-type = "$if(type)$$type$$else$note$endif$"
#let meta-title = [$if(title)$$title$$endif$]
#let meta-course = [$if(course)$$course$$endif$]
#let meta-author = [$if(author)$$author$$endif$]
#let meta-date = [$if(date)$$date$$endif$]

// Per-note overrides from frontmatter (strings, "none" turns the feature off):
//   heading-numbering: "1.a"   (default: "1." notes, "1.1" course, none pset,
//                               research and paper, chapters only for book)
//   thm-base-level: 2          (default: 1, none for pset, research and paper)
#let heading-numbering = "$if(heading-numbering)$$heading-numbering$$else$default$endif$"
#let heading-numbering = if heading-numbering == "default" {
  // book: number chapters only; sections are left bare, since the book's own
  // section numbers rarely match a count of the ones with exercises
  // paper: the overview's headings carry the paper's own letters ("B. ...")
  // research: meetings are titled by date, so theorems run on through them
  (note: "1.", course: "1.1", pset: none, book: "1", research: none, paper: none).at(doc-type, default: "1.")
} else if heading-numbering == "none" { none } else { heading-numbering }
#let thm-base-level = "$if(thm-base-level)$$thm-base-level$$else$default$endif$"
#let thm-base-level = if thm-base-level == "default" {
  if doc-type in ("pset", "research", "paper") { none } else { 1 }
} else if thm-base-level == "none" { none } else { int(thm-base-level) }

// psets and research meetings are all black; everything else colors each
// kind of result's label in its own hue
#let color = doc-type not in ("pset", "research")

#let (theorem, lemma, definition, problem, remark, proof, solution) = make-envs(
  base-level: thm-base-level, pset: doc-type == "pset", book: doc-type == "book",
  paper: doc-type == "paper", color: color)

#show: thmrules.with(qed-symbol: math.equation(sym.square.stroked))
#show: doc => if doc-type in ("pset", "book", "paper") {
  problemrefs(book: doc-type == "book", paper: doc-type == "paper")(doc)
} else { doc }
#set page(paper: "us-letter", margin: (x: 1.25in, y: 1in), numbering: "1")
#set text(size: 11pt, font: "New Computer Modern")
#set par(justify: true, first-line-indent: 1.2em)
#set heading(numbering: heading-numbering)
#show ref: set text(fill: if color { rgb("#2f4f80") } else { black })
// LaTeX's itemize markers (New Computer Modern has no ‣)
#set list(marker: ([•], [–], [∗]))

// classical (amsart) headings: top level centered in small caps, the next
// bold, the third italic, all in the text size
#show heading: set text(size: 11pt)
#show heading.where(level: 1): set text(weight: "regular")
#show heading.where(level: 1): set block(above: 1.8em, below: 1.1em)
#show heading.where(level: 1): it => align(center, smallcaps(it))
#show heading.where(level: 2): set block(above: 1.5em, below: 0.8em)
#show heading.where(level: 3): set text(weight: "regular", style: "italic")

// Only display equations with a block ID (`^id` after the `$$`) get a number
#set math.equation(numbering: "(1)")
#show math.equation.where(block: true): it => {
  if it.has("label") { return it }
  counter(math.equation).update(n => n - 1)
  [#math.equation(it.body, block: true, numbering: none)<obsidian-unnumbered>]
}

#let running-header(left, right) = context {
  if counter(page).get().first() > 1 {
    set text(size: 9pt, fill: luma(110))
    left; h(1fr); right
  }
}

// course: each top-level heading reads "Lecture 3: Title", a new page per lecture,
// and references to a lecture read "Lecture 3"
#let course-style(doc) = {
  set page(header: running-header(meta-title, meta-author))
  show heading.where(level: 1): set heading(supplement: [Lecture])
  show heading.where(level: 1): it => {
    if it.numbering == none { return it }
    // each lecture starts a new page (the first follows the title and contents)
    pagebreak(weak: true)
    block(width: 100%, above: 0.5em, below: 1.6em, align(center, text(size: 12.5pt,
      smallcaps[Lecture #context counter(heading).display("1"). #it.body])))
  }
  // contents: "Lecture N.  Title" entries, their sections beneath
  show outline.entry.where(level: 1): it => {
    set block(above: 1.1em)
    link(it.element.location(), it.indented([Lecture #it.prefix().], it.inner(), gap: 0.6em))
  }
  doc
}

// research: like a course, but each top-level heading is just the meeting's
// own title ("October 27th meeting"), with no lecture number
#let research-style(doc) = {
  set page(header: running-header(meta-title, meta-author))
  // meeting notes are mostly prose and bullets, not math: open them up
  set list(spacing: 1.5em)
  set enum(spacing: 1.5em)
  set par(leading: 1.05em, spacing: 1.7em)
  show heading.where(level: 1): it => {
    if it.outlined == false { return it }
    // each meeting starts a new page (the first follows the title and contents)
    pagebreak(weak: true)
    block(width: 100%, above: 0.5em, below: 1.6em, align(center, text(size: 12.5pt, smallcaps(it.body))))
  }
  show outline.entry.where(level: 1): set block(above: 1.1em)
  doc
}

// book: running header with the book on the left and the current chapter on
// the right; each chapter opens a new page under "Chapter 3" in small caps
// and its title in bold; untitled exercises restart their count
#let current-chapter() = {
  let here-page = here().page()
  let hs = query(heading.where(level: 1)).filter(h => h.numbering != none)
  let on-page = hs.filter(h => h.location().page() == here-page)
  let before = hs.filter(h => h.location().page() < here-page)
  if on-page.len() > 0 { on-page.first() } else if before.len() > 0 { before.last() }
}
#let book-style(doc) = {
  set page(header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(110))
      emph(meta-title)
      h(1fr)
      let ch = current-chapter()
      if ch != none [Chapter #counter(heading).at(ch.location()).first() · #ch.body]
    }
  })
  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 1): it => {
    if it.numbering == none { return it }
    pagebreak(weak: true)
    counter("pset-problem").update(0)
    block(width: 100%, above: 0.5em, below: 1.6em, align(center, {
      smallcaps[Chapter #context counter(heading).display("1")]
      linebreak()
      text(size: 14pt, weight: "bold", it.body)
    }))
  }
  show heading.where(level: 2): set heading(numbering: none)
  show outline.entry.where(level: 1): it => {
    set block(above: 1.1em)
    link(it.element.location(), it.indented([Chapter #it.prefix().], it.inner(), gap: 0.6em))
  }
  doc
}

// paper: running header with the paper's title in italics and the author;
// sections stay on one page, only the "Proofs" appendix starts a new one
#let paper-style(doc) = {
  set page(header: running-header(emph(meta-title), meta-author))
  show outline.entry.where(level: 1): set block(above: 1.1em)
  doc
}

// `> [!todo]` and `> [!question]` callouts (obsidian.lua): a thin frame
// with a bold run-in "To do." or "Question.", in its kind's hue when the
// document has color, else black
#let marks = (
  question: (accent: rgb("#5f7a3e"), label: "Question", title: "Open Questions", column: "Question"),
  todo: (accent: rgb("#a0584a"), label: "To do", title: "Open TODOs", column: "TODO"),
)
#let mark-color(kind) = if color { marks.at(kind).accent } else { black }
#let mark-box(kind, body) = {
  let c = mark-color(kind)
  block(width: 100%, above: 1.1em, below: 1.1em, stroke: 0.5pt + c, inset: 0.7em, {
    set text(size: 10pt)
    set par(first-line-indent: 0em)
    text(fill: c, strong[#marks.at(kind).label.])
    h(0.5em)
    body
  })
}

// "Open Questions" and "Open TODOs" on the title page: one row per callout,
// with its page (a link to it), where it is, and its text; booktabs rules
#let mark-table(kind, rows) = {
  let m = marks.at(kind)
  let c = mark-color(kind)
  v(0.8em)
  align(center, text(fill: c, smallcaps(m.title)))
  v(0.1em)
  set text(size: 9.5pt)
  set par(justify: false, first-line-indent: 0em)
  table(columns: (auto, 13em, 1fr), stroke: none, inset: (x: 0.45em, y: 0.45em),
    table.hline(stroke: 0.8pt),
    table.header(emph[Page], emph[Where], emph(m.column)),
    table.hline(stroke: 0.4pt),
    ..rows.map(((target, where, body)) => (
      link(target, text(fill: c, context counter(page).at(locate(target)).first())),
      where,
      body,
    )).flatten(),
    table.hline(stroke: 0.8pt),
  )
}

// pset: running header with name and assignment on every page after the first
#let pset-style(doc) = {
  set page(header: running-header(meta-author, [#meta-course · #meta-title]))
  doc
}

#show: doc => if doc-type == "course" { course-style(doc) } else if doc-type == "research" { research-style(doc) } else if doc-type == "book" { book-style(doc) } else if doc-type == "pset" { pset-style(doc) } else if doc-type == "paper" { paper-style(doc) } else { doc }

// title: centered, amsart-like: the title in bold capitals, then a line of
// small caps (the author, or "by <author>" for a book or paper), then italics
#let title-block(above: 0pt, below: 2em, kicker: none, title, by: none, lines: ()) = align(center, {
  set par(first-line-indent: 0em)
  v(above)
  if kicker != none { emph(kicker); linebreak(); v(0.2em) }
  block(text(size: 13pt, weight: "bold", hyphenate: false, upper(title)))
  if by != none { v(0.3em); smallcaps(by) }
  v(0.4em)
  lines.join(linebreak())
  v(below)
})

$if(title)$
#if doc-type == "pset" {
  title-block([$title$],
    by: [$if(author)$$author$$endif$],
    lines: (emph[$if(course)$$course$$if(date)$ · $endif$$endif$$if(date)$$date$$endif$],))
} else if doc-type == "course" {
  title-block(above: 1.2in, below: 0.8in, [$title$],
    by: [$if(author)$$author$$endif$],
    lines: (emph[$if(course)$$course$$if(date)$ · $endif$$endif$$if(date)$$date$$endif$],))
} else if doc-type == "research" {
  title-block(above: 1.2in, below: 0.8in, kicker: [Research meetings], [$title$],
    by: [$if(author)$$author$$endif$],
    lines: (emph[$if(date)$$date$$endif$],))
} else if doc-type == "book" {
  title-block(above: 1.2in, below: 0.8in, kicker: [Exercises from], [$title$],
    by: [$if(book-author)$by $book-author$$endif$],
    lines: (emph[Solutions by $if(author)$$author$$if(date)$ · $endif$$endif$$if(date)$$date$$endif$],))
} else if doc-type == "paper" {
  title-block(above: 0.9in, below: 0.4in, kicker: [Notes on], [$title$],
    by: [$if(paper-author)$by $paper-author$$endif$],
    lines: (emph[$if(author)$$author$$if(date)$ · $endif$$endif$$if(date)$$date$$endif$],))
} else {
  title-block([$title$],
    by: [$if(author)$$author$$endif$],
    lines: (emph[$if(course)$$course$$if(date)$ · $endif$$endif$$if(date)$$date$$endif$],))
}
$endif$

$if(mark-tables)$
$mark-tables$
$endif$

#if doc-type in ("course", "book", "research", "paper") {
  if doc-type == "paper" { pagebreak(weak: true) }
  outline(title: [Contents], depth: 2, indent: 1.5em)
  if doc-type == "paper" { pagebreak(weak: true) }
}

$body$
