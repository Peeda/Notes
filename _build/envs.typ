// Theorem-like environments for the PDF build, on top of ctheorems.
// obsidian.lua emits `#lemma(title: [T])[body]` for a `> [!lemma] T` callout.
// `base-level`: number theorems per heading level (1 -> 2.1, 2.2, ...), or
// none for one flat counter across the document.
// `pset`: problem sets, where a problem's title is its number
// (`> [!problem] 3` -> "Problem 3"); untitled problems count 1, 2, 3, ...
// `book`: self-study exercises, styled like pset problems but labelled
// "Exercise"; untitled ones count 2.1, 2.2, ... within chapter 2 (the
// template resets the count at each chapter).
// `paper`: reading notes on a paper, whose results keep the paper's numbers:
// `> [!lemma] B.3 Title` -> `#lemma(number: "B.3", title: [Title])`, shown
// as "Lemma B.3 (Title)"; without a number the box is unnumbered.
#import "@preview/ctheorems:1.1.3": *

#let make-envs(base-level: 1, pset: false, book: false, paper: false) = {
  let opts = (base: if base-level == none { none } else { "heading" }, base_level: base-level)
  // ctheorems takes the title positionally; its own `title:` is the env name
  let wrap(env) = if paper {
    // the number is also left as an `<env-number>` mark for references
    (number: none, title: none, body) => {
      let args = if number == none { (numbering: none) } else { (number: number) }
      let body = [#metadata(number)<env-number>#body]
      if title == none { env(body, ..args) } else { env(title, body, ..args) }
    }
  } else {
    (title: none, body) => if title == none { env(body) } else { env(title, body) }
  }
  // one style for every box: faint tint, thin bar on the left, title in the
  // accent color; each type gets its own muted hue
  let boxed(id, name, accent) = thmbox(id, name,
    fill: accent.lighten(93%), stroke: (left: 2.5pt + accent), radius: 0pt,
    inset: (x: 1em, y: 0.75em),
    titlefmt: x => text(fill: accent.darken(15%), weight: "bold", x),
    ..opts)
  let remark = thmplain("remark", "Remark")
  // psets: "Problem 3" in bold with a hairline running to the margin, then the
  // statement as plain text below it (no box, no color); books box their
  // exercises like the notes' theorems instead, in their own muted hue
  let problem = if book { boxed("problem", "Exercise", rgb("#9b7a4a")) } else {
    thmplain("problem", "Problem", base: none, inset: 0em,
      padding: (top: 0.9em, bottom: 0.2em),
      titlefmt: x => {
        text(size: 1.15em, weight: "bold", x)
        h(0.6em)
        box(width: 1fr, baseline: -0.4em, line(length: 100%, stroke: 0.6pt + luma(150)))
      },
      separator: linebreak())
  }
  (
    theorem:    wrap(boxed("theorem", "Theorem", rgb("#4a6a9b"))),
    lemma:      wrap(boxed("theorem", "Lemma", rgb("#76679e"))),
    definition: wrap(boxed("theorem", "Definition", rgb("#4a8a7c"))),
    problem:    if pset or book {
                  // own counter, so untitled problems after "3.14" still count 4, 5, ...
                  // stepped inside the body, so the call returns one element
                  // that a `<label>` can attach to; the number, shown before
                  // the step, adds the 1 itself
                  let count = counter("pset-problem")
                  let auto-number = context {
                    let n = count.get().first() + 1
                    if book [#counter(heading).get().first().#n] else [#n]
                  }
                  (title: none, body) => problem(
                    [#count.step()#metadata(title)<env-number>#body],
                    number: if title == none { auto-number } else { title })
                } else {
                  wrap(boxed("problem", "Problem", rgb("#6f747c")))
                },
    remark:     (title: none, body) => if title == none { remark(body, numbering: none) } else { remark(title, body, numbering: none) },
    proof:      wrap(thmproof("proof", "Proof")),
    // pset solutions: bold label and a gray bar down the left, set apart from
    // the statement; book solutions read like the notes' proofs
    solution:   if book { wrap(thmproof("solution", "Solution")) } else {
                  wrap(thmproof("solution", "Solution", titlefmt: strong,
                    stroke: (left: 1.5pt + luma(185)), inset: (left: 0.9em, right: 0em, y: 0.15em)))
                },
  )
}

// References to pset and book problems, and to every result in a paper (use
// it only for those documents). ctheorems would number them from its own
// counter, which they skip, so show the number their title gives, or the one
// counted for them; an unnumbered paper result reads just "Lemma".
#let problemrefs(book: false, paper: false) = doc => {
  show ref: it => {
    let el = it.element
    if el == none or el.func() != figure or el.kind != "thmenv" { return it }
    if not paper and el.supplement not in ([Problem], [Exercise]) { return it }
    let mark = query(selector(<env-number>).after(el.location())).first()
    let n = if mark.value != none { mark.value } else if paper { none } else {
      let k = counter("pset-problem").at(mark.location()).first()
      if book [#counter(heading).at(mark.location()).first().#k] else [#k]
    }
    let supplement = if it.citation.supplement != none { it.citation.supplement } else { el.supplement }
    link(it.target, if n == none [#supplement] else [#supplement~#n])
  }
  doc
}
