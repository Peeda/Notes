#let disc-frames(
  coloring,                 // array of "R"/"B", one per element of [m]
  family,                   // array of sets, each an array of elements in 1..m
  red: rgb("#d62728"),
  blue: rgb("#1f77b4"),
  cell: 2.4em,              // cell size; use ~1.6em for m = 16
) = {
  let m = coloring.len()
  let counts(S) = {
    let r = S.filter(i => coloring.at(i - 1) == "R").len()
    (r, S.len() - r)
  }
  let set-str(S) = if S.len() == m { $[#m]$ } else { ${#S.map(str).join(", ")}$ }
  let row(colored: true, hl: none) = {
    let cells = range(1, m + 1).map(i => {
      let col = if not colored { luma(235) } else if coloring.at(i - 1) == "R" { red } else { blue }
      let inside = hl == none or i in hl
      box(
        width: cell, height: cell, radius: 3pt,
        fill: if not colored or inside { col } else { col.lighten(80%) },
        stroke: if hl != none and inside { 2.5pt + black } else { 0.5pt + luma(160) },
        align(center + horizon, text(
          weight: "bold",
          fill: if not colored { black } else if inside { white } else { luma(160) },
          str(i),
        )),
      )
    })
    align(center, stack(dir: ltr, spacing: 5pt, ..cells))
  }
  let caption(body) = align(center, block(height: 3em, body))
  let vals = family.map(S => { let (r, b) = counts(S); calc.abs(r - b) })

  (
    row(colored: false) + caption[The universe $[#m]$],
    row() + caption[
      A coloring $chi: [#m] -> {#text(fill: red)[R], #text(fill: blue)[B]}$ \
      $cal(F) = {#family.map(set-str).join(", ")}$
    ],
    ..family.enumerate().map(((k, S)) => {
      let (r, b) = counts(S)
      let k = k + 1
      row(hl: S) + caption($S_#k = #set-str(S): quad
        abs(S_#k inter R) = #r, quad
        abs(S_#k inter B) = #b, quad
        abs(#r - #b) = #calc.abs(r - b)$)
    }),
    row() + caption($"disc"(cal(F), chi) = max(#vals.map(str).join(", ")) = #calc.max(..vals)$),
  )
}
#let gsw-frames(
  vecs,                      // n = 3 input vectors v_1, v_2, v_3 (columns of B, any dimension d)
  choices: (),               // per step: 1 = take delta+, -1 = take delta-; missing = 1
  scale: 2.1cm,              // half side length of the drawn cube
  panel-size: 0.6em,         // text size of the pseudocode and cube labels
  calc-size: 0.7em,          // text size of the matrix and the state info
  accent: rgb("#e6550d"),
  face-col: rgb("#1f77b4"),
  labels: ((-1, 1, -1), (1, -1, 1)),     // cube corners to label (opposite corners)
  axis-names: ($x$, $y$, $z$),           // labels of the axis indicator
  azimuth: 25deg,            // rotation of the cube around the vertical axis (0deg to 90deg)
  elevation: 25deg,          // how far above the cube we look from (0deg to 90deg)
) = {
  let n = 3
  let d = vecs.at(0).len()
  let eps = 1e-7
  let dot(a, b) = a.zip(b).map(((p, q)) => p * q).sum(default: 0.0)
  let fmt(v) = calc.round(v, digits: 2)
  let vec-str(v) = $[#v.map(c => $#fmt(c)$).join($, $)]$
  let set-of(al) = {
    let idx = range(al.len()).filter(i => al.at(i)).map(i => str(i + 1))
    if idx.len() == 0 { $emptyset$ } else { ${#idx.join(", ")}$ }
  }

  // small linear solver (Gaussian elimination with partial pivoting)
  let solve(A, b) = {
    let k = b.len()
    let M = range(k).map(i => A.at(i) + (b.at(i),))
    for c in range(k) {
      let piv = range(c, k).sorted(key: r => -calc.abs(M.at(r).at(c))).first()
      let tmp = M.at(c)
      M.at(c) = M.at(piv)
      M.at(piv) = tmp
      for r in range(k) {
        if r != c {
          let f = M.at(r).at(c) / M.at(c).at(c)
          M.at(r) = range(k + 1).map(j => M.at(r).at(j) - f * M.at(c).at(j))
        }
      }
    }
    range(k).map(i => M.at(i).at(k) / M.at(i).at(i))
  }

  // ---- run the Gram-Schmidt walk ----
  let z = (0.0, 0.0, 0.0)
  let alive = (true, true, true)
  let steps = ()
  while alive.any(a => a) {
    let t = steps.len()
    let p = range(n).filter(i => alive.at(i)).last()            // pivot
    let A = range(n).filter(i => alive.at(i) and i != p)
    let u = (0.0,) * n
    u.at(p) = 1.0
    if A.len() > 0 {
      // u_A minimizes || v_p + sum_{i in A} u_i v_i ||
      let G = A.map(i => A.map(j => dot(vecs.at(i), vecs.at(j)) + if i == j { 1e-12 } else { 0 }))
      let rhs = A.map(i => -dot(vecs.at(i), vecs.at(p)))
      let sol = solve(G, rhs)
      for (k, i) in A.enumerate() { u.at(i) = sol.at(k) }
    }
    let lim(s) = range(n).filter(i => calc.abs(u.at(i)) > eps).map(i => {
      let dd = s * u.at(i)
      if dd > 0 { (1 - z.at(i)) / dd } else { (-1 - z.at(i)) / dd }
    }).fold(1e9, calc.min)
    let dp = lim(1)
    let dm = lim(-1)
    let s = choices.at(t, default: 1)
    let z-old = z
    let al-old = alive
    z = range(n).map(i => z.at(i) + s * (if s > 0 { dp } else { dm }) * u.at(i))
    for i in range(n) {
      if alive.at(i) and calc.abs(calc.abs(z.at(i)) - 1) < 1e-6 {
        z.at(i) = if z.at(i) > 0 { 1.0 } else { -1.0 }
        alive.at(i) = false
      }
    }
    steps.push((z-old: z-old, al-old: al-old, p: p, u: u, dp: dp, dm: dm, s: s, z: z, alive: alive))
  }

  // ---- cube drawing ----
  // orthographic projection: screen images of the three coordinate axes
  let (th, ph) = (azimuth, elevation)
  let ex = (calc.cos(th), calc.sin(ph) * calc.sin(th))
  let ey = (-calc.sin(th), calc.sin(ph) * calc.cos(th))
  let ez = (0.0, -calc.cos(ph))
  let W = 2 * scale * (calc.cos(th) + calc.sin(th)) + 2.6cm
  let H = 2 * scale * (calc.cos(ph) + calc.sin(ph) * (calc.sin(th) + calc.cos(th))) + 1.2cm
  let P(v) = (
    W / 2 + scale * (v.at(0) * ex.at(0) + v.at(1) * ey.at(0) + v.at(2) * ez.at(0)),
    H / 2 + scale * (v.at(0) * ex.at(1) + v.at(1) * ey.at(1) + v.at(2) * ez.at(1)),
  )
  let back = (-1, -1, -1)   // the corner hidden behind the cube (dashed edges)
  let corners = ((-1, -1, -1), (-1, -1, 1), (-1, 1, -1), (-1, 1, 1),
                 (1, -1, -1), (1, -1, 1), (1, 1, -1), (1, 1, 1))
  let edges = ()
  for a in corners {
    for b in corners {
      if a.zip(b).filter(((p, q)) => p != q).len() == 1 and a < b { edges.push((a, b)) }
    }
  }
  let seg(a, b, stroke) = place(top + left, line(start: P(a), end: P(b), stroke: stroke))
  let dot-at(v, r: 3.5pt, fill: black, stroke: none) = {
    let (px, py) = P(v)
    place(top + left, dx: px - r, dy: py - r, circle(radius: r, fill: fill, stroke: stroke))
  }
  // the face / edge / vertex where the frozen coordinates are fixed
  let region(zv, al) = {
    let free = range(n).filter(i => al.at(i))
    let pt(sa, sb) = range(n).map(i => if i == free.at(0, default: -1) { sa } else if i == free.at(1, default: -1) { sb } else { zv.at(i) })
    if free.len() == 2 {
      place(top + left, polygon(fill: face-col.transparentize(80%), stroke: none,
        ..((-1, -1), (1, -1), (1, 1), (-1, 1)).map(((a, b)) => P(pt(a, b)))))
    } else if free.len() == 1 {
      seg(pt(-1, 0), pt(1, 0), 5pt + face-col.transparentize(50%))
    } else if free.len() == 0 {
      dot-at(zv, r: 8pt, fill: face-col.transparentize(60%))
    }
  }
  // small accent-colored label with a light backing so it stays readable over edges
  let tag(body) = box(fill: white.transparentize(15%), inset: 1.5pt, radius: 2pt,
    text(size: calc-size, fill: accent, body))
  // arrow: short segment from cur in direction u; ray: (lo, hi) endpoints
  let scene(path, cur, al: (true, true, true), arrow: none, ray: none, cur-label: none, arrow-label: none) = box(width: W, height: H, {
    if al.any(a => not a) { region(cur, al) }
    for (a, b) in edges {
      let hidden = a == back or b == back
      seg(a, b, if hidden { (paint: luma(150), thickness: 0.8pt, dash: "dashed") } else { 1.2pt + luma(60) })
    }
    if arrow != none {
      let nrm = calc.sqrt(dot(arrow, arrow))
      let tip = range(n).map(i => cur.at(i) + 0.6 * arrow.at(i) / nrm)
      seg(cur, tip, 2pt + accent)
      dot-at(tip, r: 2.5pt, fill: accent)
      if arrow-label != none {
        // label beside the middle of the arrow, on its right-hand side
        let (ax, ay) = P(cur)
        let (bx, by) = P(tip)
        let l = calc.sqrt((bx - ax) / 1pt * (bx - ax) / 1pt + (by - ay) / 1pt * (by - ay) / 1pt)
        let (ux, uy) = ((bx - ax) / 1pt / l, (by - ay) / 1pt / l)
        let (nx, ny) = if -uy >= 0 { (-uy, ux) } else { (uy, -ux) }
        place(top + left, dx: (ax + bx) / 2 + nx * 12pt, dy: (ay + by) / 2 + ny * 12pt,
          place(center + horizon, tag(arrow-label)))
      }
    }
    if ray != none {
      seg(ray.at(0), ray.at(1), (paint: accent, thickness: 1.5pt, dash: "dashed"))
      dot-at(ray.at(0), r: 3pt, fill: white, stroke: 1.2pt + accent)
      dot-at(ray.at(1), r: 3pt, fill: white, stroke: 1.2pt + accent)
    }
    for i in range(path.len() - 1) { seg(path.at(i), path.at(i + 1), 1.8pt + black) }
    for q in path { dot-at(q, r: 2.2pt) }
    dot-at(cur, fill: accent)
    if cur-label != none {
      let (cx, cy) = P(cur)
      place(top + left, dx: cx - 4pt, dy: cy - 5pt,
        place(bottom + right, tag(cur-label)))
    }
    // axis indicator in the bottom-right corner
    let (o-x, o-y) = (W - 1cm, H - 1.1cm)
    for (k, e) in (ex, ey, ez).enumerate() {
      let L = 0.9cm
      let (tx, ty) = (o-x + L * e.at(0), o-y + L * e.at(1))
      place(top + left, line(start: (o-x, o-y), end: (tx, ty), stroke: 1pt + luma(90)))
      // arrowhead
      let nrm = calc.sqrt(e.at(0) * e.at(0) + e.at(1) * e.at(1))
      let (ux, uy) = (e.at(0) / nrm, e.at(1) / nrm)
      let hs = 4pt
      place(top + left, polygon(fill: luma(90), stroke: none,
        (tx + hs * ux, ty + hs * uy),
        (tx - hs * uy * 0.6, ty + hs * ux * 0.6),
        (tx + hs * uy * 0.6, ty - hs * ux * 0.6)))
      place(top + left, dx: tx + 10pt * ux, dy: ty + 10pt * uy,
        place(center + horizon, text(size: panel-size, fill: luma(90), axis-names.at(k))))
    }
    for c in labels {
      let (px, py) = P(c)
      let (ox, oy) = P((0, 0, 0))
      let (dx, dy) = (px - ox, py - oy)
      let len = calc.sqrt(dx / 1pt * dx / 1pt + dy / 1pt * dy / 1pt)
      let off = 24pt
      place(top + left, dx: px + dx / 1pt / len * off, dy: py + dy / 1pt / len * off,
        place(center + horizon, text(size: panel-size, fill: luma(80), vec-str(c))))
    }
  })

  // ---- pseudocode ----
  let code = (
    [$p_t <- max A_t$ #h(0.5em) _(pivot)_],
    [choose $u_t$ to minimize $norm(B u_t)$ such that $u_t (p_t) = 1$ and $u_t (i) = 0$ for $i in.not A_t$],
    [let $delta_t^+, delta_t^- > 0$ be the step sizes at which $z_(t-1) + delta_t^+ u_t$ and $z_(t-1) - delta_t^- u_t$ hit a face],
    [take a step $z_t = z_(t-1) + delta_t u_t$, where $delta_t in {delta_t^+, -delta_t^-}$ is chosen with mean zero],
    [update the alive set: $A_(t+1) = {i : abs(z_t (i)) < 1}$],
  )
  let pseudo(hl) = block(width: 100%, stroke: 0.6pt + luma(180), radius: 4pt, inset: 6pt, {
    set par(leading: 0.5em)
    grid(
      columns: (auto, 1fr), column-gutter: 0.6em, row-gutter: 2pt, inset: (y: 3pt, x: 3pt),
      fill: (x, y) => if y in hl { accent.lighten(80%) },
      grid.cell(colspan: 2)[Start at $z_0 = 0$ with $A_1 = [n]$. While $A_t != emptyset$:],
      ..code.enumerate().map(((i, c)) => (text(fill: luma(140), str(i + 1)), c)).flatten(),
    )
  })

  // ---- matrix B with pivot column, and u_t underneath ----
  let mat-panel(k: none, al: (true, true, true), piv: none, u: none) = {
    let gray = luma(170)
    let col-fill(j) = if piv == j { accent.lighten(80%) } else if not al.at(j) { luma(245) }
    let entry(j, c) = text(fill: if al.at(j) { black } else { gray }, $#fmt(c)$)
    let u-entry(j) = if u == none { hide[$0$] } else if j == piv {
      text(fill: accent, weight: "bold", $1$)
    } else { entry(j, u.at(j)) }
    let tbl = table(
      columns: (auto,) + (2.6em,) * n,
      align: center + horizon,
      inset: (x: 4pt, y: 4pt),
      stroke: (x, y) => if y == d + 1 { (top: 0.6pt + luma(120)) },
      fill: (x, y) => if x > 0 and y <= d { col-fill(x - 1) },
      [], ..range(n).map(j => text(fill: if al.at(j) { black } else { gray },
        if j == piv { text(fill: accent)[$v_#(j + 1)$] } else { $v_#(j + 1)$ })),
      table.cell(rowspan: d, $B =$),
      ..range(d).map(r => range(n).map(j => entry(j, vecs.at(j).at(r)))).flatten(),
      if u == none { hide[$u$] } else { $u_#k =$ }, ..range(n).map(u-entry),
    )
    // B u_t written as pivot column + weighted other alive columns
    let bu = if u == none { hide($B u = v + v = 0$) } else {
      let terms = range(n).filter(j => al.at(j) and j != piv).map(j => {
        let c = fmt(u.at(j))
        if c < 0 { $- #calc.abs(c) v_#(j + 1)$ } else { $+ #c v_#(j + 1)$ }
      })
      let res = range(d).map(r => range(n).map(j => u.at(j) * vecs.at(j).at(r)).sum())
      box($B u_#k = text(fill: accent, v_#(piv + 1)) #terms.join() = #vec-str(res)$)
    }
    (tbl, bu)
  }

  let info(body) = block(height: 2.8em, width: 100%, breakable: false, body)
  // cube on the left; on the right the pseudocode on top, and below it
  // the matrix next to the B u_t calculation and the state info
  let layout(hl, sc, mp, inf) = block(breakable: false, grid(
    columns: (auto, 1fr), column-gutter: 1em,
    align: (center + horizon, left + horizon),
    sc,
    {
      text(size: panel-size, pseudo(hl))
      v(0.5em)
      set text(size: calc-size)
      let (tbl, bu) = mp
      grid(columns: (auto, 1fr), column-gutter: 1.4em, align: (left + horizon, left + horizon),
        tbl, stack(dir: ttb, spacing: 0.9em, bu, inf))
    },
  ))

  // ---- frames ----
  let zero = (0.0, 0.0, 0.0)
  let all = (true, true, true)
  let frames = (layout((0,), scene((zero,), zero, cur-label: $z_0$), mat-panel(),
    info[$z_0 = #vec-str(zero)$ \ $A_1 = #set-of(all)$]),)
  let path = (zero,)
  for (t, st) in steps.enumerate() {
    let k = t + 1
    let base = info[$z_(#(k - 1)) = #vec-str(st.z-old)$ \ $A_#k = #set-of(st.al-old)$, #h(0.3em) $p_#k = #(st.p + 1)$]
    let zl = $z_(#(k - 1))$
    // line 1: pivot
    frames.push(layout((1,), scene(path, st.z-old, al: st.al-old, cur-label: zl),
      mat-panel(k: k, al: st.al-old, piv: st.p), base))
    // line 2: direction
    frames.push(layout((2,), scene(path, st.z-old, al: st.al-old, arrow: st.u, cur-label: zl, arrow-label: $u_#k$),
      mat-panel(k: k, al: st.al-old, piv: st.p, u: st.u), base))
    // line 3: step sizes
    let lo = range(n).map(i => st.z-old.at(i) - st.dm * st.u.at(i))
    let hi = range(n).map(i => st.z-old.at(i) + st.dp * st.u.at(i))
    let pr = st.dm / (st.dp + st.dm)
    frames.push(layout((3,), scene(path, st.z-old, al: st.al-old, ray: (lo, hi), cur-label: zl),
      mat-panel(k: k, al: st.al-old, piv: st.p, u: st.u),
      info[$delta_#k^+ = #fmt(st.dp)$, #h(0.3em) $delta_#k^- = #fmt(st.dm)$ \
           $Pr[+] = #fmt(pr)$, #h(0.3em) $Pr[-] = #fmt(1 - pr)$]))
    // lines 4-5: step and update
    path.push(st.z)
    let took = if st.s > 0 { $delta_#k = delta_#k^+$ } else { $delta_#k = -delta_#k^-$ }
    frames.push(layout((4, 5), scene(path, st.z, al: st.alive, cur-label: $z_#k$),
      mat-panel(k: k, al: st.alive),
      info[#took: #h(0.2em) $z_#k = #vec-str(st.z)$ \ $A_(#(k + 1)) = #set-of(st.alive)$]))
  }
  let last = steps.last()
  frames.push(layout((), scene(path, last.z, al: last.alive, cur-label: $z_#steps.len()$),
    mat-panel(al: last.alive),
    info[Done: coloring \ $chi = #vec-str(last.z)$]))
  frames
}
