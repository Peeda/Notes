= The complex numbers, and mappings

#import "@preview/cetz:0.4.2": canvas, draw

#figure(
  canvas({
    import draw: *

    set-style(
      mark: (fill: black),
      stroke: (thickness: 0.8pt),
    )

    line((-0.5, 0), (4, 0), mark: (end: ">"))
    line((0, -0.5), (0, 3.5), mark: (end: ">"))

    let z1 = (2, 1)
    let z2 = (1, 1)
    let z3 = (1, 3)

    // angle marks, centred on the origin, drawn under the vectors
    arc((0, 0), start: 0deg, stop: 26.57deg, radius: 0.8,
        anchor: "origin", stroke: blue)
    arc((0, 0), start: 0deg, stop: 45deg, radius: 0.6,
        anchor: "origin", stroke: red)
    arc((0, 0), start: 0deg, stop: 71.57deg, radius: 1.2,
        anchor: "origin", stroke: green)

    line((0, 0), z1, stroke: (paint: blue, thickness: 1.5pt), mark: (end: ">"))
    content(z1, $z_1 = 2 + i$, anchor: "south-west", padding: 0.1)

    line((0, 0), z2, stroke: (paint: red, thickness: 1.5pt), mark: (end: ">"))
    content(z2, $z_2 = 1 + i$, anchor: "south", padding: 0.1)

    line((0, 0), z3, stroke: (paint: green, thickness: 1.5pt), mark: (end: ">"))
    content(z3, $z_1 z_2 = 1 + 3i$, anchor: "south-west", padding: 0.1)

    content((4, 0), $"Re"$, anchor: "west", padding: 0.1)
    content((0, 3.5), $"Im"$, anchor: "south", padding: 0.1)
  }),
  caption: [Complex multiplication: the product of two complex numbers scales and rotates in the complex plane],
)
