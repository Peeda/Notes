#import "@preview/touying:0.7.4": *
#import themes.metropolis: *
#import "figure_code.typ": *

// #set text(font: "Fira Sans")
// #show math.equation: set text(font: "Fira Math")
#set text(font: "New Computer Modern Sans")
#set list(spacing: 1em)
#set par(spacing: 1em)

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
  // config-common(handout: false)
)

#title-slide()

#let disc = math.op("disc")
#let ff = $cal(F)$
#let qed = [#h(1fr) $square$]


= Discrepancy Theory
== Discrepancy on Set Families
- Informally, split some structure in a balanced way
#pause
- Fix some $cal(F) subset.eq 2^[n]$ and let $chi:[n] -> {-1,1}$ be a two coloring
#pause
- Let $R,B$ denote the set of units for each color, so $R = chi^(-1)(-1), B = chi^(-1)(1)$

#pause
- We say the discrepancy of $cal(F)$ with respect to a coloring $chi$ is
$ disc(cal(F), chi) = max_(S in ff) abs(abs(S inter R) - abs(S inter B)) $
#pause
#alternatives(..disc-frames(
  ("R", "B", "R", "R", "B", "B", "R", "B", "R", "R", "B", "R"),
  ((1, 3, 4,8,10), (5, 6, 7, 8), range(1, 13)),
))
== Discrepancy on Set Families
- Because $chi$ maps to ${-1,1}$ we can write the imbalance as
$ disc(ff, chi) = max_(S in ff) abs(sum_(u in S) chi(u)) $
#pause
- The above measures how balanced $ff$ is under $chi$, we say the discrepancy of $ff$ itself is
$ disc(ff) = min_chi disc(ff, chi) $
== Extreme cases
- If $ff = 2^[n]$ then $R,B in ff$ where one must have $>= n slash 2$ elements so $disc(ff) >= n slash 2$
#pause
- If $ff$ is a collection of disjoint sets we can choose $chi$ to guarantee $disc(ff) <= 1$
#pause

- We can use the probabilitistic method to show $disc(ff) <= sqrt(n log (2 abs(ff)))$
== The proof
#pause
Observe that if $chi$ is chosen uar, for any $S in ff$ we can use Hoeffding's to show
$ Pr[abs(sum_(u in S) chi(u)) > t] <= 2 e ^(- t^2 slash 2 abs(S)) <= 2 e^(-t^2 slash 2 n) $
then we set $t = sqrt(2 n ln (2 abs(ff)))$ so that the above is $< 1 slash abs(ff)$. From there you can union bound over every set $S in ff$ to say that under $chi$ all sets have the desired discrepancy with positive probability, implying existence. \ #qed
== Matrix Discrepancy
- For some $ff$, collect incidence vectors along rows to form a matrix in $B in RR^(m times n)$
#pause

- Rows indexed by sets $S in ff$, and columns index elements in $[m]$
$ disc(ff) = disc(B) = min_(z in {-1,1}^n) norm(B z)_infinity $
#pause
- Matrix Discrepancy: split the columns of $B$ into two groups with similar sums

#pause
- Random colorings are the baseline, can we do better
== Key Results in Discrepancy
- Spencer, Six Standard Deviations Suffice (1985): For binary $B$ where $n=m$ we have
$ disc(B) <= 6 sqrt(n) $
#pause
- Proof was nonconstructive, not known if such a coloring could be found in poly time

#pause
- Bansal (2010) showed such an algorithm exists
#pause
- Algorithmic discrepancy theory
  - Applications: attention approximation, experimental design, monte carlo integration
== Recent Results
- Discrepancy theory has had a lot of recent breakthroughs disovered by AI

- Guo, Fang, Lu (Sep. 2026) showed for $B$ with column norm $<=1$ (Koml\u{f3}s problem)
- $ disc(B) = O(1) $
  - Li 2026 shows algorithm such a coloring in $O(m n + n^(omega+2) log^3 n)$ time
  - Bansal, Jiang 26: $tilde(O) ((log n)^(1 slash 4))$
  - Banaszcyck 98: $O(sqrt(log n))$
- Aden-Ali 2026: Optimal algorithm for online vector balancing

= The Gram-Schmidt Walk
== The Gram-Schmidt Walk
- Due to Bansal, Dadush, Lovett, Garg in 2018
#pause
- Shows that we can sample $z in {-1,1}^n$ such that $B z$ is $O(1)$-Subgaussian #pause
  - Implies $disc(B) = O(sqrt(log n))$
  #pause
  - A random variable $X$ $sigma^2$-subgaussian if $forall t in RR$
  $ EE[e^(t X)] <= e^(1/2 t^2 sigma^2) $
  - and for random vectors $y in RR^m$ we require $forall v in RR^m$
  $ EE[e^(chevron.l y, v chevron.r)] <= e^(1/2 norm(v)^2 sigma^2) $
#pause
- Walk around in $[-1,1]^n$ randomly taking steps with low discrepancy wrt $B$
== Visualization
#alternatives(..gsw-frames(
  ((-0.4, 0.2, 0.1, -0.5, 0.3, 0.07), (0.1, -0.6, 0.3, 0.2, -0.08, -0.4), (1,0,0,0,0,0)),
  choices: (1, -1, 1),
))
// #alternatives(..gsw-frames(
//   ((1, 0), (0.5, 0.9), (-0.8, 0.6)),
//   choices: (1, -1, 1),
// ))
== The Gram-Schmidt Walk
- Take advantage of linear dependencies between columns, but stay sufficiently random
#pause
- When $B = I_n$ we get $z$ is i.i.d uniform in each entry
#pause
- When $B$ is a single column repeated we get perfect cancellations, $B z = 0$
- Linear dependencies correspond to negative correlations in $z$
#pause
#alternatives(..gsw-frames(
  ((1, 0, 0), (0, 1, 0), (0, 0, 1)),
  choices: (1, -1, 1),
))
== The Gram-Schmidt Walk
- Harshaw, Savje, Spielman, Zhang 19: $B z$ is $1$-Subgaussian

  - Motivated by experimental design applications
= Our Contributions
- Determining $u_t$ at each iteration requires solving a least squares system

- In practice: speed this up by maintaining some factorization to be reused at every $t$

  - Errors accumulate over iterations
  - Approximate $u_t$ can change which units get decided, so trajectory differs

- How does approximate $u_t$ hurt our performance

== Experiments
#figure(
  image("Images/n_subgauss_higgs.png"),
)
== Theoretical Result
$
  bb(E)[exp(⟨B z, v⟩)] <= exp(
    1/2 norm(v)^2 + (
      underbrace(n^(3\/2) (2 epsilon_"pr" + epsilon_"iter"), italic("drift/sampling"))
      + (
        underbrace(2 n epsilon_"LS", italic("least squares"))
        + underbrace(n(n+1) epsilon_"iter", italic("arithmetic/clamping"))
      )
    ) norm(v)
  )
$
- Roughly speaking the $1$-subgaussianity is more like $1 + O(n^2 epsilon)$
#pause

- As $epsilon -> 0$ this recovers the original result
#pause

- $epsilon_"pr", epsilon_"iter"$ scale like $epsilon_"mach"$, $epsilon_"LS"$ scales like $kappa epsilon_"mach"$ if solver is backwards stable
== Proof Sketch
// - okay so write the decomposition
// - throw away the error terms and focus on these corrupted updates
//   - you can't just apply the proof to these terms, some key things break
// - The original proof is quite technical
// - You take these updates and use the least squares defn of $u_t$ to say we can write it in a certain onb
// - Then you try to show a certain MGF martingale argument over pivot phases
// - Okay so there's an inner induction thing that breaks
// - The key thing is that in the ideal alg $sum_t delta_t$ over a phase is two point distribution, because $u_t (p) = 1$
// - Errors along the pivot unit break this invariant though
// == yeah
// - you consider a certain orthonormal basis ${w_s}$ and can write
// $ EE[exp(sum_(t in S_p) delta_t chevron.l B u_t, v chevron.r - norm(P_p b_(p_t))^2 norm(P_p v)^2) | Delta_S_p] $
// $ EE [exp (sum_(t in S_p) delta_t sum_(s in S_p \ s < t) chevron.l w_s, v chevron.r chevron.l w_s, b chevron.r  - 1/2(sum_(s in S_p) chevron.l w_s, v chevron.r^2)  (sum_(s in S_p) chevron.l w_s, b chevron.r^2)) | Delta_S_p] $
//
= Conclusion
- Our proofs rely heavily on boundedness

  - Distributional assumptions on rounding?

#pause
- Precise result for particular solvers?

  - Would require characterizing stability of least squares solvers under rank one updates
#pause

- Can we explain this sharp transition behavior where $30$ or so bits seems to be indistinguishable from $64$
