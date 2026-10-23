// Theorem-like environments for the PDF build, on top of ctheorems.
// obsidian.lua emits `#lemma(title: [T])[body]` for a `> [!lemma] T` callout.
// `base-level`: number theorems per heading level (1 -> 2.1, 2.2, ...), or
// none for one flat counter across the document.
// `pset`: problem sets, where a problem's title is its number
// (`> [!problem] 3` -> "Problem 3"); untitled problems count 1, 2, 3, ...
#import "@preview/ctheorems:1.1.3": *

#let make-envs(base-level: 1, pset: false) = {
  let opts = (base: if base-level == none { none } else { "heading" }, base_level: base-level)
  // ctheorems takes the title positionally; its own `title:` is the env name
  let wrap(env) = (title: none, body) => if title == none { env(body) } else { env(title, body) }
  // one style for every box: faint tint, thin bar on the left, title in the
  // accent color; each type gets its own muted hue
  let boxed(id, name, accent) = thmbox(id, name,
    fill: accent.lighten(93%), stroke: (left: 2.5pt + accent), radius: 0pt,
    inset: (x: 1em, y: 0.75em),
    titlefmt: x => text(fill: accent.darken(15%), weight: "bold", x),
    ..opts)
  let remark = thmplain("remark", "Remark")
  // psets: "Problem 3" in bold with a hairline running to the margin, then the
  // statement as plain text below it (no box, no color)
  let problem = thmplain("problem", "Problem", base: none, inset: 0em,
    padding: (top: 0.9em, bottom: 0.2em),
    titlefmt: x => {
      text(size: 1.15em, weight: "bold", x)
      h(0.6em)
      box(width: 1fr, baseline: -0.4em, line(length: 100%, stroke: 0.6pt + luma(150)))
    },
    separator: linebreak())
  (
    theorem:    wrap(boxed("theorem", "Theorem", rgb("#4a6a9b"))),
    lemma:      wrap(boxed("theorem", "Lemma", rgb("#76679e"))),
    definition: wrap(boxed("theorem", "Definition", rgb("#4a8a7c"))),
    problem:    if pset {
                  // own counter, so untitled problems after "3.14" still count 4, 5, ...
                  let count = counter("pset-problem")
                  (title: none, body) => {
                    count.step()
                    problem(body, number: if title == none { context count.display() } else { title })
                  }
                } else {
                  wrap(boxed("problem", "Problem", rgb("#6f747c")))
                },
    remark:     (title: none, body) => if title == none { remark(body, numbering: none) } else { remark(title, body, numbering: none) },
    proof:      wrap(thmproof("proof", "Proof")),
    // solutions: bold label and a gray bar down the left, set apart from the statement
    solution:   wrap(thmproof("solution", "Solution", titlefmt: strong,
                  stroke: (left: 1.5pt + luma(185)), inset: (left: 0.9em, right: 0em, y: 0.15em))),
  )
}
