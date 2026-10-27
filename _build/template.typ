#import "/_build/macros.typ": *
#import "/_build/envs.typ": make-envs, thmrules, problemrefs

// Document type, from frontmatter `type:`
//   course: lecture notes; each top-level heading is a numbered lecture
//   pset:   problem set; homework header, problems numbered by their title
//   book:   self-study exercises from a book; each top-level heading is a
//           chapter, exercises numbered by their title as in psets
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
//                               chapters only for book)
//   thm-base-level: 2          (default: 1, none for pset)
#let heading-numbering = "$if(heading-numbering)$$heading-numbering$$else$default$endif$"
#let heading-numbering = if heading-numbering == "default" {
  // book: number chapters only; sections are left bare, since the book's own
  // section numbers rarely match a count of the ones with exercises
  // paper: the overview's headings carry the paper's own letters ("B. ...")
  (note: "1.", course: "1.1", pset: none, book: "1", paper: none).at(doc-type, default: "1.")
} else if heading-numbering == "none" { none } else { heading-numbering }
#let thm-base-level = "$if(thm-base-level)$$thm-base-level$$else$default$endif$"
#let thm-base-level = if thm-base-level == "default" {
  if doc-type in ("pset", "paper") { none } else { 1 }
} else if thm-base-level == "none" { none } else { int(thm-base-level) }

#let (theorem, lemma, definition, problem, remark, proof, solution) = make-envs(
  base-level: thm-base-level, pset: doc-type == "pset", book: doc-type == "book",
  paper: doc-type == "paper")

#show: thmrules
#show: doc => if doc-type in ("pset", "book", "paper") {
  problemrefs(book: doc-type == "book", paper: doc-type == "paper")(doc)
} else { doc }
#set page(paper: "us-letter", margin: 1in, numbering: "1")
#set text(size: 11pt, font: "New Computer Modern Sans")
#set par(justify: true)
#set heading(numbering: heading-numbering)

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
    block(above: 0.5em, below: 1.2em,
      text(size: 1.3em)[Lecture #context counter(heading).display("1"): #it.body])
  }
  // contents: "Lecture N  Title" entries in bold, their sections beneath
  show outline.entry.where(level: 1): it => {
    set block(above: 1.1em)
    strong(link(it.element.location(), it.indented([Lecture #it.prefix()], it.inner(), gap: 0.8em)))
  }
  doc
}

// book: running header with the book on the left and the current chapter on
// the right; each chapter opens a new page under a small "CHAPTER 3" label, a
// large title and a hairline; untitled exercises restart their count
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
      if ch != none [Chapter #counter(heading).at(ch.location()).first() #sym.dot.c #ch.body]
    }
  })
  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 1): it => {
    if it.numbering == none { return it }
    pagebreak(weak: true)
    counter("pset-problem").update(0)
    block(above: 0.5em, below: 1.4em, {
      text(size: 9pt, weight: "bold", tracking: 0.18em, fill: luma(110))[
        CHAPTER #context counter(heading).display("1")]
      v(0.1em)
      text(size: 1.6em, weight: "bold", it.body)
      v(-0.4em)
      line(length: 100%, stroke: 0.4pt + luma(150))
    })
  }
  show heading.where(level: 2): set heading(numbering: none)
  show heading.where(level: 2): set text(size: 1.05em)
  show outline.entry.where(level: 1): it => {
    set block(above: 1.1em)
    strong(link(it.element.location(), it.indented([Chapter #it.prefix()], it.inner(), gap: 0.8em)))
  }
  doc
}

// paper: running header with the paper's title in italics and the author;
// sections stay on one page, only the "Proofs" appendix starts a new one
#let paper-style(doc) = {
  set page(header: running-header(emph(meta-title), meta-author))
  show heading.where(level: 1): set block(above: 1.6em, below: 0.9em)
  show outline.entry.where(level: 1): it => {
    set block(above: 1.1em)
    strong(it)
  }
  doc
}

// `> [!todo]` callouts (obsidian.lua): boxed like the theorems (faint tint,
// bar on the left) in their own muted rust, "TODO" in small spaced capitals
#let todo-accent = rgb("#a0584a")
#let todo-box(body) = block(width: 100%, above: 0.9em, below: 0.9em,
  fill: todo-accent.lighten(93%), stroke: (left: 2.5pt + todo-accent),
  inset: (x: 0.9em, y: 0.5em), {
    text(size: 0.75em, weight: "bold", tracking: 0.14em, fill: todo-accent.darken(15%))[TODO]
    h(0.7em)
    body
  })

// "Open TODOs" on the title page: one row per `> [!todo]`, with its page
// (a link to it), where it is, and its text
#let todo-table(rows) = {
  v(0.6em)
  text(size: 9pt, weight: "bold", tracking: 0.18em, fill: todo-accent.darken(15%))[OPEN TODOS]
  v(0.2em)
  set text(size: 9.5pt)
  set par(justify: false)
  table(columns: (auto, 13em, 1fr), stroke: none, inset: (x: 0.45em, y: 0.5em),
    fill: (_, y) => if y > 0 and calc.even(y) { todo-accent.lighten(95%) },
    table.hline(stroke: 0.8pt + todo-accent),
    table.header(
      text(fill: luma(90))[Page], text(fill: luma(90))[Where], text(fill: luma(90))[TODO]),
    table.hline(stroke: 0.4pt + luma(150)),
    ..rows.map(((target, where, body)) => (
      link(target, text(fill: todo-accent.darken(15%), weight: "bold",
        context counter(page).at(locate(target)).first())),
      text(fill: luma(70), where),
      body,
    )).flatten(),
    table.hline(stroke: 0.8pt + todo-accent),
  )
}

// pset: running header with name and assignment on every page after the first
#let pset-style(doc) = {
  set page(header: running-header(meta-author, [#meta-course #sym.dot.c #meta-title]))
  doc
}

#show: doc => if doc-type == "course" { course-style(doc) } else if doc-type == "book" { book-style(doc) } else if doc-type == "pset" { pset-style(doc) } else if doc-type == "paper" { paper-style(doc) } else { doc }

$if(title)$
#if doc-type == "pset" [
  #text(size: 18pt, weight: "bold")[$title$]
  #v(0.2em)
  #grid(columns: (1fr, auto),
    [$if(course)$$course$$endif$],
    [$if(author)$$author$$endif$$if(date)$ #sym.dot.c $date$$endif$])
  #line(length: 100%, stroke: 0.5pt)
  #v(0.8em)
] else if doc-type == "course" [
  // title: course code, large title, heavy rule over a hairline, author and date
  #v(1.2in)
  $if(course)$
  #text(size: 10pt, weight: "bold", tracking: 0.18em, fill: luma(100))[#upper[$course$]]
  #v(0.3em)
  $endif$
  #block(text(size: 30pt, weight: "bold", hyphenate: false)[$title$])
  #v(0.5em)
  #line(length: 100%, stroke: 2pt)
  #v(-0.55em)
  #line(length: 100%, stroke: 0.4pt)
  #v(0.2em)
  #text(size: 11pt, fill: luma(80))[$if(author)$$author$$endif$$if(date)$ #h(1fr) $date$$endif$]
  #v(0.9in)
] else if doc-type == "book" [
  // title: like a course, but "Exercises from" over the book's title and its
  // author beneath, then my name and the date under the rules
  #v(1.2in)
  #text(size: 10pt, weight: "bold", tracking: 0.18em, fill: luma(100))[EXERCISES FROM]
  #v(0.3em)
  #block(text(size: 30pt, weight: "bold", hyphenate: false)[$title$])
  $if(book-author)$
  #v(-0.2em)
  #text(size: 14pt, fill: luma(90))[by $book-author$]
  $endif$
  #v(0.5em)
  #line(length: 100%, stroke: 2pt)
  #v(-0.55em)
  #line(length: 100%, stroke: 0.4pt)
  #v(0.2em)
  #text(size: 11pt, fill: luma(80))[Solutions by $if(author)$$author$$endif$$if(date)$ #h(1fr) $date$$endif$]
  #v(0.9in)
] else if doc-type == "paper" [
  // title: like a course, with "Notes on" over the paper's title and its
  // authors beneath
  #v(0.9in)
  #text(size: 10pt, weight: "bold", tracking: 0.18em, fill: luma(100))[NOTES ON]
  #v(0.3em)
  #block(text(size: 26pt, weight: "bold", hyphenate: false)[$title$])
  $if(paper-author)$
  #v(-0.2em)
  #text(size: 14pt, fill: luma(90))[by $paper-author$]
  $endif$
  #v(0.5em)
  #line(length: 100%, stroke: 2pt)
  #v(-0.55em)
  #line(length: 100%, stroke: 0.4pt)
  #v(0.2em)
  #text(size: 11pt, fill: luma(80))[$if(author)$$author$$endif$$if(date)$ #h(1fr) $date$$endif$]
  #v(0.5in)
] else [
  #align(center)[
    #text(size: 16pt, weight: "bold")[$title$]
    $if(course)$
    #v(0.2em) $course$
    $endif$
    $if(author)$
    #v(0.3em) $author$
    $endif$
    $if(date)$
    #v(0.2em) $date$
    $endif$
  ]
  #v(1em)
]
$endif$

$if(todo-table)$
$todo-table$
$endif$

#if doc-type in ("course", "book", "paper") {
  if doc-type == "paper" { pagebreak(weak: true) }
  outline(title: [Contents], depth: 2, indent: 1.5em)
  if doc-type == "paper" { pagebreak(weak: true) }
}

$body$
