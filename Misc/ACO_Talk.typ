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

= An Intro to Discrepancy Theory
== Discrepancy for Set Systems
== Extending to Matrices
- For matrices the relevant equation is
$ "disc"(A) = min_(x in {-1,1}^n) norm(A x )_infinity $
