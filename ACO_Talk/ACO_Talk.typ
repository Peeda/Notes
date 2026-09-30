#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#set text(font: "Fira Sans")
#show math.equation: set text(font: "New Computer Modern Math")

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Finite Precision Gram-Schmidt Walks],
    subtitle: [ACO Student Seminar Talk],
    author: [Peter Chen, Joint work with Emile Anand and Jan van den Brand],
    date: datetime.today(),
    institution: [],
  ),
)

#title-slide()

= Planning
== The vibe
- Okay so what's the vibe of this talk
- I think it should be like, you know hey I'm an undergrad giving this talk, the technical contributions here are pretty thin so this talk is like sort of an introduction to some cool problems and partially a discussion of this incremental paper
- Our contributions are partially experimental and partially technical
== The Discrepancy Section
- Gotta discuss the algorithm
  - Put that code up, get a visualization going
  - Discuss the two extreme inputs, we need to take advantage of linear dependence and also be sufficiently random to get Subgaussianity in the $B=I_n$ case
- Spielman
  - Talk about the setup, give an example in experimental design, I think this is somewhat intuitive and neat so it's a good thing to mention
  - Why do we care about distributional guarantees over single good colorings
  - Here the coloring is consumed downstream into confidence intervals, so we care about not just balancing covariates (you could consider choosing an optimal coloring and you wouldn't quite get what you want)
== Our Contributions
- Okay so you can basically do the proof but you change it a little
- More or less you can't say anything about the noise, what's left to show is that the corrupted ideal part of the updates doesn't somehow break
  - I don't know if this is obvious but yeah, you're noting that noise can change the trajectory by a lot so we just need to make sure guarantees still hold
  - This is also why a relative TV type result can't be shown, also that wouldn't preserve SG I think
  - The main idea is that within a phase, we preserve this MGF condition approximately, the main proof relies on some orthogonality properties which we preserve in the ideal portion and some distributional properties of $sum_t hat(delta_t)$ which are only approximately preserved
= Discrepancy Theory and the Gram-Schmidt Walk
== The Gram-Schmidt Walk
#align(center)[
  #alternatives(
    ..range(1, 4).map(i => image("Images/gsw_visualized.pdf", page: i, height: 80%))
  )
]
