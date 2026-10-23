#import "/_build/macros.typ": *
#import "/_build/envs.typ": make-envs, thmrules

// Document type, from frontmatter `type:`
//   course: lecture notes; each top-level heading is a numbered lecture
//   pset:   problem set; homework header, problems numbered by their title
//   other:  plain note
#let doc-type = "$if(type)$$type$$else$note$endif$"
#let meta-title = [$if(title)$$title$$endif$]
#let meta-course = [$if(course)$$course$$endif$]
#let meta-author = [$if(author)$$author$$endif$]
#let meta-date = [$if(date)$$date$$endif$]

// Per-note overrides from frontmatter (strings, "none" turns the feature off):
//   heading-numbering: "1.a"   (default: "1." notes, "1.1" course, none pset)
//   thm-base-level: 2          (default: 1, none for pset)
#let heading-numbering = "$if(heading-numbering)$$heading-numbering$$else$default$endif$"
#let heading-numbering = if heading-numbering == "default" {
  (note: "1.", course: "1.1", pset: none).at(doc-type, default: "1.")
} else if heading-numbering == "none" { none } else { heading-numbering }
#let thm-base-level = "$if(thm-base-level)$$thm-base-level$$else$default$endif$"
#let thm-base-level = if thm-base-level == "default" {
  if doc-type == "pset" { none } else { 1 }
} else if thm-base-level == "none" { none } else { int(thm-base-level) }

#let (theorem, lemma, definition, problem, remark, proof, solution) = make-envs(
  base-level: thm-base-level, pset: doc-type == "pset")

#show: thmrules
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

// pset: running header with name and assignment on every page after the first
#let pset-style(doc) = {
  set page(header: running-header(meta-author, [#meta-course #sym.dot.c #meta-title]))
  doc
}

#show: doc => if doc-type == "course" { course-style(doc) } else if doc-type == "pset" { pset-style(doc) } else { doc }

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

#if doc-type == "course" { outline(title: [Contents], depth: 2, indent: 1.5em) }

$body$
