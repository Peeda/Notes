// Theorem-like environments for the PDF build, on top of ctheorems.
// obsidian.lua emits `#lemma(title: [T])[body]` for a `> [!lemma] T` callout.
// `base-level`: number theorems per heading level (1 -> 2.1, 2.2, ...), or
// none for one flat counter across the document.
// `pset`: problem sets, where a problem's title is its number
// (`> [!problem] 3` -> "Problem 3"); untitled problems count 1, 2, 3, ...
// `book`: self-study exercises, numbered like pset problems but labelled
// "Exercise"; untitled ones count 2.1, 2.2, ... within chapter 2 (the
// template resets the count at each chapter).
// `color`: labels in each kind's hue (notes, courses, books, papers); psets
// and research meetings are all black.
// `paper`: reading notes on a paper, whose results keep the paper's numbers:
// `> [!lemma] B.3 Title` -> `#lemma(number: "B.3", title: [Title])`, shown
// as "Lemma B.3 (Title)"; without a number the box is unnumbered.
#import "@preview/ctheorems:1.1.3": *

#let make-envs(base-level: 1, pset: false, book: false, paper: false, color: true) = {
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
  // classical (amsthm) style: a bold run-in label, "Theorem 3.2 (Name).",
  // then the statement, italic for theorems and lemmas; no box. With `color`,
  // each kind's label (and its period) takes its own muted hue
  // with color, the label sits in a small box in its hue: "tint" (pale
  // fill, colored text), "outline" (hairline frame) or "solid" (filled,
  // white text); without color it is plain bold
  let label-style = "tint"
  let tag(accent, x) = if not color { strong(x) } else if label-style == "tint" {
    box(fill: accent.lighten(87%), radius: 1.5pt, inset: (x: 0.3em), outset: (y: 0.22em),
      text(fill: accent.darken(10%), strong(x)))
  } else if label-style == "outline" {
    box(stroke: 0.6pt + accent, inset: (x: 0.3em), outset: (y: 0.25em),
      text(fill: accent, strong(x)))
  } else {
    box(fill: accent, inset: (x: 0.35em), outset: (y: 0.22em),
      text(fill: white, strong(x)))
  }
  let plain(id, name, accent, italic: false, base: opts.base) = thmplain(id, name,
    inset: 0em, padding: (top: 0.8em, bottom: 0.8em),
    titlefmt: x => tag(accent, x),
    // with color the boxed label needs no period; the name keeps one
    namefmt: x => if color [(#x).] else [(#x)],
    separator: if color { h(0.55em) } else [*.*#h(0.5em)],
    bodyfmt: if italic { emph } else { x => x },
    base: base, base_level: opts.base_level)
  let remark = thmplain("remark", "Remark", inset: 0em, separator: [.#h(0.5em)])
  // psets: "Problem 3." in bold, run into the statement, no color
  let problem = if book { plain("problem", "Exercise", rgb("#7d5f2e")) } else {
    plain("problem", "Problem", black, base: none)
  }
  let proof-like(id, name) = thmproof(id, name, inset: 0em,
    padding: (top: 0.3em, bottom: 0.8em), separator: [.#h(0.5em)])
  (
    theorem:    wrap(plain("theorem", "Theorem", rgb("#2f4f80"), italic: true)),
    lemma:      wrap(plain("theorem", "Lemma", rgb("#5a4a85"), italic: true)),
    definition: wrap(plain("theorem", "Definition", rgb("#2e6b5e"))),
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
                  wrap(plain("problem", "Problem", rgb("#4f5560")))
                },
    remark:     (title: none, body) => if title == none { remark(body, numbering: none) } else { remark(title, body, numbering: none) },
    proof:      wrap(proof-like("proof", "Proof")),
    solution:   wrap(proof-like("solution", "Solution")),
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
