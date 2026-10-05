#set text(font: "New Computer Modern Math")
#import "@preview/ctheorems:1.1.3": *
#show: thmrules

#let theorem = thmbox("theorem", "Theorem", fill: rgb("#ffdddd"))
#let lemma = thmbox("lemma", "Lemma", fill: rgb("#ddddff"))
#let proof = thmproof("proof", "Proof")


#let sgn = $op("sgn")$


#let inner(a, b) = $chevron.l #a, #b chevron.r$
#let grad = $gradient$
#let leqa = $lt.tilde$

#outline()
#pagebreak()

= Setup Definitions
#let bw = $bold(w)$
#let bx = $bold(x)$
#let bz = $bold(z)$
#let bs = $bold(s)$
#let bzeta = $bold(zeta)$
#let smaj = $bold(s)_"maj"$
#let smin = $bold(s)_"min"$

#let todo(body) = text(fill: red)[*TODO:* #body]






== Data
- Data $bold(x)$ is distributed like i.i.d Rademacher in all entries except the third entry, and the target function is $y(x) = - x_1x_2$, the XOR on the first two entries
- The third entry is like a planted answer, with probability $1-lambda$ it is the XOR of the first two entries, and with probability $lambda$ it's the negation

- We decompose $bold(w) = bold(w)_"sig" + bold(w)_"opp" + bold(w)_"sp" + bold(w)_perp$ where sig is the projection onto the signal direction, which depends on the sign of $a$, $bw_"opp"$ points in the "other" direction (discussed below), $bold(w)_"sp"$ is the projection onto the third coordinate, and $bold(w)_"perp"$ is everything else
  - The sign of $a$ determines the sign of a particular neuron's contribution, and therefore whether we want to align with $plus.minus mu_1$ (the choices of $bold(z)$ that are $1$ under XOR) vs $plus.minus mu_2$ (the $-1$ inputs) so $bw _"opp"$ is just the orthogonal direction to the signal
- We decompose $bx = bold(z) + bold(s) + bzeta$, which are the projections onto the first two coordinates (so $y(bx) = y(bold(z))$), the projection onto the third coordinate, and the remaining $d-3$ coordinates respectively
== Loss
- The neural network output $f_rho (x)$ is the average of the neuron outputs, so $ f_rho (bx) = 1/p sum_(a_j, w_j) a_j sigma(bw^top bx) = E_((a_j, bw_j) ~ rho) [a_j sigma( bw^top bx)] $
- The loss, as a function of $bx$ denoted $ell_rho (bx)$, is twice the negative log of the sigmoid of the margin, where we let $gamma(bx) := f_rho (x) y(x)$ denote the margin, $psi(gamma) = 1/(1 + exp(- gamma))$ denote the sigmoid, and so $ell_rho (x) = - 2 log (psi(gamma(x))) = h(gamma(x))$ where we use $h$ to denote the outer functions, so $h(gamma) := -2 log (psi(gamma))$ is the sigmoid composed with twice the negative log.
- We let $ell_0 (x)$ denote the first order approximation of $ell_rho$ around $0$ with respect to $f_rho (x)$, observe that because $h$ is scaled by $2$ we have $h'(gamma) = (-2 e^(- gamma))/(1 + e^(- gamma))$ so $h'(0) = -1$, giving
$ ell_0(f_rho (bx)) = ell_rho (0) + h'(0) gamma(bx) = -2 log 1/2 - y(bx) f_rho (bx) $
- $L_rho$ and $L_0$ are the corresponding population losses, so the expectation over $bx$ drawn from the described distribution
- We write $ell_rho ^((1)) (bx) = h'(gamma(bx))$ for the first derivative of the loss with respect to the margin, and $ell_0 ^((1)) (bx)$ as the corresponding value for $ell_0$ which is $-1$. So I believe we're writing it as a function of $bx$ but really are considering the change in the loss wrt the margin, later this will be useful in bounding $gradient (L_rho - L_0)$.
- $gradient_bw L$ and $partial_a L$ are scaled by $p$ so that we get invariance over the width of the neural network (the $p$ cancels with the $1/p$ in the averaging over neurons)
= Section B: $L_0$ Analylsis
#let wsig = $bw _"sig"$
#let wopp = $bw _ "opp"$
#let wsp = $bw _ "sp"$
We want to characterize the gradients under the $L_0$ approximation of the loss to derive recurrences on each part of $bw$. We will ultimately show that the $L_0$ approximation is fine for small networks (small absolute value/norm of $(a, bw)$), and that both $wsig, wsp$ grow according to a geometric recurrence, but that $wsp$ has a headstart like $sqrt(d)$.

#lemma[$L_0$ gradient along signal and opposite directions][
  For any neuron $a,bw$ we have
  $ -wsig^top grad_bw L_0 = sqrt(2)/4 abs(a) norm(wsig) Pr_bzeta [abs(bw^top bold(e)_3 + bw^top bzeta) <= sqrt(2) norm(wsig)] $
  $ -wopp^top grad_bw L_0 = sqrt(2)/4 abs(a) norm(wopp) Pr_bzeta [abs(bw^top bold(e)_3 + bw^top bzeta) <= sqrt(2) norm(wopp)] $
] <lemma-l0-sig>

#proof[of @lemma-l0-sig][
  Note that we have by definition of $L_0$ as the first order approximation and a previous calc that
  $ -wsig^top grad_w L_0 &= -wsig^top EE[p partial/(partial bw) -y(bx) f_rho (bx)] \
    &= wsig^top EE[p partial/(partial bw) sum_j a_j sigma(bw^top bx)  ] \
    &= wsig^top EE[y(x) a sigma' (bw^top bx) bx]
  $
  and by recognizing that $wsig^top$ is orthogonal to $bx - bz$ we can split the above by using $bx = bz + bold(s) + bzeta$ so that the above equals $EE[y(bz) a sigma'(bw^top bx) wsig^top bz]$ also using that $y$ is determined by $bz$. So intuitively this part gradient only depends on $bx$ in units $3,...,d$ via this inner sigmoid, as everything else is projected into $mu_"sig"$'s span. From here we use iterated expectations to condition on whether $wsig || bz$, noting that the above is zero when the two are orthogonal to get
  $ &= 1/2 limits(EE)_(x,z \ wsig|| bz) [y(z) a sigma'(bw^top bx) wsig^top bz] \
    &= 1/2 limits(EE)_(x,z \ wsig|| bz) [y(z) a sigma'(wsig^top bz + bw^top bold(s) + bw^top bzeta) wsig^top bz] $
  letting $bz_0$ denote one of the two values of $bz$ such that we have $wsig || z_0$ (so if $a > 0$ then $mu_1$ else $mu_2$) we know that $(bz,bs)$ are independent and $bz$ is $plus.minus bz_0$ with probability $1 slash 2$ each, and that $bs$ is $smaj$ with prob $1-lambda$ and $smin$ with prob $lambda$. Recall that $smaj$ is just aligned with the sign of $a$ and so we have $bs=smaj$ with prob $1-lambda$ because $s=smaj$ if and only if $s$ and $a$ share signs, which is the same as $s$ being one for $z= plus.minus mu_1$ and $-1$ otherwise.
  #todo[Okay I should review this at some point since walking back how things are defined relative to sign of $a$ seems difficult to me, there's probably an easier way to see it, any way this allows us to expand the above. This is probably the same as just thinking of $smaj$ as the xor of $bz_0$ but that's not the definition itself.]

  Noting that we're just varying the signs of $bz, bs$ let's introduce the shorthand $sigma'(plus.minus, plus.minus)$ to mean $sigma'(wsig^top (plus.minus bz) + bw^top (plus.minus bs) + bw^top bzeta) $ so the above equals
  $ = 1/2 a(\
    (1/2 - lambda/2) dot &EE_bzeta [y(bz_0) sigma'(+, +) wsig^top bz_0] \
  + lambda/2 dot &EE_bzeta [y(bz_0) sigma'(+, -) wsig^top bz_0] \
  + (1/2 - lambda/2) dot &EE_bzeta [y(-bz_0) sigma'(-, +) wsig^top (-bz_0)] \
  + lambda/2 dot &EE_bzeta [y(-bz_0) sigma'(-,-) wsig^top (-bz_0)] \
  )
  $
and we  can factor our the $1 slash 2$, then observe that $y(bz_0) = y(-bz_0)$ with $a y(bz_0) = a y(-bz_0) = abs(a)$ by the fact $bz_0$'s xor aligns with the sign of $a$ to get
  $
    = 1/4 abs(a) (\
    (1 - lambda) dot &EE_bzeta [sigma'(+, +) wsig^top bz_0] \
  + lambda dot &EE_bzeta [sigma'(+, -) wsig^top bz_0] \
  + (1 - lambda) dot &EE_bzeta [sigma'(-, +) wsig^top (-bz_0)] \
  + lambda dot &EE_bzeta [sigma'(-,-) wsig^top (-bz_0)] ) \

  = 1/4 abs(a) wsig^top bz_0 (\
  (1 - lambda) dot &EE_bzeta [sigma'(+, +)] \
  + lambda dot &EE_bzeta [sigma'(+, -)] \
  - (1 - lambda) dot &EE_bzeta [sigma'(-, +)] \
  - lambda dot &EE_bzeta [sigma'(-,-)]) \
  $
from here we'll group terms according to the sign of $smaj$ (this will let us apply an identity about differences of certain indicators) to get
$
  = 1/4 abs(a) wsig^top bz_0 ( \
    &EE_bzeta [sigma'(+,+) - sigma'(-, +)] \
    + lambda &EE_bzeta [sigma'(-,+) - sigma'(+, +)] \
    + lambda &EE_bzeta [sigma'(+,-) - sigma'(-, -)] )
$
unrolling definitions now since the manipulations are done and recognizing $sigma'(x) = bb(1) [x >= 0]$, the above is
$
  = 1/4 abs(a) wsig^top bz_0 ( \
    &EE_bzeta [bb(1)[wsig^top bz + bw^top bs + bw^top bzeta] - bb(1)[wsig^top (-bz) + bw^top bs + bw^top bzeta]] \
    + lambda &EE_bzeta [bb(1)[wsig^top (-bz) + bw^top bs + bw^top bzeta] - bb(1)[wsig^top bz + bw^top bs + bw^top bzeta]] \
    + lambda &EE_bzeta [bb(1)[wsig^top bz + bw^top (-bs) + bw^top bzeta] - bb(1)[wsig^top (-bz) + bw^top (-bs) + bw^top bzeta]] )
$
From here consider that for $a,b,c in RR$ we have
$ bb(1)[a+b+c >= 0] - bb(1)[-1+b+c >= 0] = bb(1)[b+c >= -a] - bb(1)[b+c>=a] $
where the above is $1$ if and only if the first indicator is true and the second false, and $-1$ if the first false and the second true, and $0$ otherwise. Therefore the above is
$ = cases(1 &"when" a <= b + c <= -a, -1 &"when" -a <= b + c <= a, 0 &"else") $
or equivalently, this is nonzero when $abs(b+c) <= abs(a)$ with the sign being the opposite of $a$'s sign as the sign of $a$ determines whether which case is valid. This type of argument works for all three differences of indicators and actually lets us group the first two differences of indicators since they share $bw^top bs + bw^top bzeta$ just up to a sign flip so the above equals
$ = 1/4 abs(a) wsig^top bz_0 ( \

  (1-lambda) &Pr_bzeta [abs(bw^top smaj + bw^top bzeta) <= abs(wsig^top bz_0)]sgn(wsig^top bz_0)  \

  + lambda &Pr_bzeta [abs(-bw^top smaj + bw^top bzeta) <= abs(wsig^top bz_0)]sgn(wsig^top bz_0)
  ). $
We now observe that $wsig^top bz_0 sgn(wsig^top bz_0) = abs(wsig^top bz_0) = norm(wsig^top) norm(z_0) = sqrt(2) norm(wsig^top)$ with the last two steps following from the fact $wsig || bz_0$ and so Cauchy-Schwarz is tight here, with $norm(bz_0) = sqrt(2)$ following from definition of $bz_0$. We use this to factor out $sgn(wsig^top bz_0)$ from both terms and also to rewrite the $abs(wsig^top bz_0)$ term inside each probability:
$ = sqrt(2)/4 abs(a) norm(wsig)( \
  (1-lambda) &Pr_bzeta [abs(bw^top smaj + bw^top bzeta) <= sqrt(2) norm(wsig)] \
  + lambda &Pr_bzeta [abs(-bw^top smaj + bw^top bzeta) <= sqrt(2) norm(wsig)]
  ). $
and we conclude the proof by noting that $bzeta$ is symmetric, so in particular we can flip $bzeta$ with $-bzeta$ while preserving probabilities; because of the absolute value this is the same as flipping the sign of $smaj$ so
$
Pr_bzeta [abs(-bw^top smaj + bw^top bzeta) <= sqrt(2) norm(wsig)]=
Pr_bzeta [abs(bw^top smaj + bw^top bzeta) <= sqrt(2) norm(wsig)]= \
Pr_bzeta [abs(bw^top bold(e)_3 + bw^top bzeta) <= sqrt(2) norm(wsig)]
$
which allows us to conclude the above equals
$ = sqrt(2)/4 abs(a) norm(wsig) Pr_bzeta [abs(bw^top bold(e)_3 + bw^top bzeta) <= sqrt(2) norm(wsig)] $
as desired.
]
#lemma[$L_0$ gradient along perp][
  For any neuron $a,bw$ we have
  $ -bw_perp^top grad_bw L_0 = 1/8 abs(a) EE[abs(bw^top bzeta) ( \
    bb(1) [abs(bw^top bzeta) >= abs(sqrt(2) norm(wsig) + wsp) ] +  bb(1) [abs(bw^top bzeta) >= abs(sqrt(2) norm(wsig) - wsp) ] \
    bb(1) [abs(bw^top bzeta) >= abs(sqrt(2) norm(wopp) + wsp) ] + bb(1) [abs(bw^top bzeta) >= abs(sqrt(2) norm(wopp) - wsp) ]
  )] $
] <lemma-l0-perp>
#proof[of @lemma-l0-perp][

  As before we can use the definition of $L_0$ to see that
  $ -bw_perp^top grad_bw L_0 = -bw_perp^top EE[-y(bx) a sigma' (bw^top bx) bx] = EE[y(bz) a sigma' (bw^top bx) bw_perp^top bzeta] $
  and here we'll appeal to the symmetry of $bzeta$ right at the start to get this equals
  $ = 1/2 a EE[y(bz) bw_perp^top bzeta (sigma'(bw^top bz + bw^top bs + bw^top bzeta) - sigma'(bw^top bz + bw^top bs - bw^top bzeta))] $
  $ = 1/2 a EE[y(bz) bw_perp^top bzeta (bb(1)[bw^top bz + bw^top bs + bw^top bzeta] - bb(1)[bw^top bz + bw^top bs - bw^top bzeta])] $
  as before, notice that $bb(1)[a+b+c] - bb(1)[a+b-c]$ is one when $-c <= a+b<= c$ and negative one when $c <= a + b <= -c$ and so it equals $sgn(c) bb(1)[abs(a+b) <= abs(c)]$, and so the above equals, after using $sgn(x)x=abs(x)$,
  $ = 1/2 a EE[y(z) abs(bw_perp^top bzeta) bb(1) [abs(bw_perp^top bzeta) >= abs(bw^top bz + bw^top bs)] ] $
  unlike the proof of @lemma-l0-sig we're not doing any conditioning on whether $wsig||bz$ so we just expand here over $(bz,bs)$, grouping $1-lambda$ terms and $lambda$ terms that have the same value because of absolute values to get
  $ = 1/8 a EE[&abs(bw_perp^top bzeta) (\
    & bb(1) [abs(bw^top bzeta) >= abs(bw^top bold(mu_1) + wsp)] \
    + & bb(1) [abs(bw^top bzeta) >= abs(bw^top bold(mu_1) - wsp)] \
    - & bb(1) [abs(bw^top bzeta) >= abs(bw^top bold(mu_2) + wsp)] \
    - & bb(1) [abs(bw^top bzeta) >= abs(bw^top bold(mu_2) - wsp)] \
    )] $
and if $(bw,a)$ is a positive neuron then $bw^top bold(mu_1) = sqrt(2) norm(wsig)$, and for negative neurons $wsig, wopp$ swap roles (so they get opposite signs). Given that negative neurons have $a < 0$ we can compactly write this as
$ = 1/8 abs(a) EE[&abs(bw_perp^top bzeta) (\
  & bb(1) [abs(bw^top bzeta) >= sqrt(2)norm(wsig) + wsp)] \
  + & bb(1) [abs(bw^top bzeta) >= sqrt(2)norm(wsig) - wsp)] \
  - & bb(1) [abs(bw^top bzeta) >= sqrt(2)norm(wopp) + wsp)] \
  - & bb(1) [abs(bw^top bzeta) >= sqrt(2)norm(wopp) - wsp)] \
  )] $
as desired.
#todo("why is this expression uglier than the signal direction's expression? Does it say something interesting about how zeta and the first two coordinates behave differently?")
]
#let xnoi = $bx_(without i)$
#let zetanoi = $bold(zeta)_(without i)$
#let e3 = $bold(e)_3$
#lemma[$L_0$ gradient for a coordiante of perp][
  For any neuron $(a,bw)$ we have
  $ -w_i partial_(w_i) L_0 &= 1/8 abs(a) abs(w_i) \ [
    &Pr_bzeta [abs(w_i) >= abs(sqrt(2) norm(wsig) + w_"sp" + bw^top zetanoi)] + Pr_bzeta [abs(w_i) >= abs(sqrt(2) norm(wsig) - w_"sp" + bw^top zetanoi)] \
    -&Pr_bzeta [abs(w_i) >= abs(sqrt(2) norm(wopp) + w_"opp" + bw^top zetanoi)] - Pr_bzeta [abs(w_i) >= abs(sqrt(2) norm(wopp) - w_"opp" + bw^top zetanoi)]
  ] $
] <lemma-l0-perp-coord>

#todo("whoops in the above proofs i think i used wsp in bold to mean a scalar")

#proof[of @lemma-l0-perp-coord][
  This proof can be done in the same way as @lemma-l0-perp just applied coordinate wise, although here I will do a slightly different approach that expands over $x_i$, using that $x_i$ is Rademacher for $i > 3$, rather than appealing to symmetry which changes the first few steps. Pretty sure that this works but it's late right now so #todo("check this")

  From definition we have that
  $ -w_i partial_(w_i) L_0 = EE_x [a y(bx) sigma'(bw^top bx) w_i x_i] \
    = 1/2 a EE_x [y(z)(sigma'(bw^top xnoi + w_i)w_i - sigma'(bw^top xnoi - w_i)w_i)] \
    = 1/2 a w_i EE_x [y(z) (sigma'(bw^top xnoi + w_i) - sigma'(bw^top xnoi - w_i))]
  $
  and we can reuse the same difference of indicators analysis to get that this equals
  $
    = 1/2 a w_i EE_x [y(z) bb(1)[abs(bw^top xnoi) <= abs(w_i)] sgn(w_i)] \
    = 1/2 a abs(w_i) EE_x [y(z) bb(1)[abs(w_i) >= abs(bw^top xnoi)]] \
    = 1/2 a abs(w_i) EE_x [y(z) bb(1)[abs(w_i) >= abs(bw^top bz + bw^top bs + bw^top zetanoi)]]
  $
  as in @lemma-l0-perp we expand over the distribution $(bz,bzeta)$, using the structure of the absolute value being taken on the right hand side to group pairs of terms with probability $1/4 (1-lambda)$ and $1/4 lambda$ that take matching values under absolute value to get
  $ = 1/2 a abs(w_i) EE_bzeta \ [
    & bb(1)[abs(w_i) >= abs(bw^top bold(mu)_1 + wsp e3 + bw^top zetanoi)] &&+ bb(1)[abs(w_i) >= abs(bw^top bold(mu)_1 - wsp e3 + bw^top zetanoi)] \
    - &bb(1)[abs(w_i) >= abs(bw^top bold(mu)_2 + wsp e3 + bw^top zetanoi)] &&- bb(1)[abs(w_i) >= abs(bw^top bold(mu)_2 - wsp e3 + bw^top zetanoi)] ]
  $
  and as in @lemma-l0-perp we note that when $a > 0$ we take $wsig$ to align with $bold(mu)_1$, and for $a < 0$ it's with $bold(mu)_2$ and so we can use that the above terms swap $bold(mu)_1, bold(mu)_2$'s roles up to signs to write this as
  $ = 1/2 abs(a) abs(w_i) EE_bzeta \ [
    & bb(1)[abs(w_i) >= abs(sqrt(2) norm(wsig) + wsp e3 + bw^top zetanoi)] &&+ bb(1)[abs(w_i) >= abs(sqrt(2) norm(wsig) - wsp e3 + bw^top zetanoi)] \
    - &bb(1)[abs(w_i) >= abs(sqrt(2) norm(wopp) + wsp e3 + bw^top zetanoi)] &&- bb(1)[abs(w_i) >= abs(sqrt(2) norm(wopp) - wsp e3 + bw^top zetanoi)] ]
  $
  with the $a$ being in absolute values handling the fact that for $a < 0$ we pick up a negative sign by swapping the roles of $bold(mu)_1, bold(mu)_2$. The result then follows by writing the expectation of an indicator as a probability.
]


= Section C: $L_rho$ Analysis
- First shows a bound on the difference in the gradients between $L_0$ and $L_rho$, coordinate by coordinate
- Then we reuse results from section $B$ to characterize the gradients in {$wsig$, $wopp$, $wsp$, $bw_perp$} under $L_rho$, but with extra steps to handle the margin term that results from us considering $ell_rho^((1))$ rather than $ell_0^((1)) = -1$. All lemmas rely on a certain assumption on the magnitude of the margin, and condition on a high probability event $cal(E)_"test"$, generally bounding via a Lipschitzness argument.
= Section D: Phase I Induction
== Preliminaries
- The first lemma shows that if if we get alignment between the signs of $a, wsp$ then and $wsp$ is sufficiently large compared to the other components then the network predicts based on $wsp$
  - $a$ determines sign, so if it matches $wsp$ then $wsp$ determines sign, so we get no contribution when its sign differs from $x_3$ and otherwise we get a contribution matching $x_3$
=== Scalings
1. $log log (d) d^(-C) << eta << log^(-3) (d)$
  - upper bound helps control $a$ as being close to $norm(bw)$, and lower keeps $t leqa d^C$
2. $t leqa log log (d) eta^(-1)$
  - length of phase I
3. $log (d) << p $ helps to ensure $cal(E)_"init"$
  - so norm of $bw_perp$ controlled, and balance of $S^+, S^-$
4. $theta << log^(-5C) (d)$
  - limited by the analysis of the per-step change in $bw_perp$
5. $m >> d log ^(7C) (d)$
  - Limited by Hoeffding's
=== Inductive Hypothesis
1. $wsp^((t)) - wsp^((t-1)) = eta (1 plus.minus o(log^(-2)(d))) dot (1/2 - lambda) dot "sgn"(a^((0)))(abs(wsp^((t-1))) + theta)$

2. $norm(wsig^((t)) - wsig^((t-1))) leqa eta (norm(wsig)^((t-1)) + theta log^(C) (d) d^(-1 slash 2)) $

3. $norm(wopp^((t)) - wopp^((t-1))) leqa eta (norm(wopp)^((t-1)) + theta log^(C) (d) d^(-1 slash 2)) $
4. $norm(bw_perp^((t)) - bw_perp^((t-1))) leqa eta theta log^(-2 C) (d)$
5. $norm(bw_perp^((t)) - bw_perp^((t-1)))_infinity leqa eta theta log^(3 C) (d) d^(-1 slash 2)$
6. $abs(a^((t))) <= norm(w^((t)))$
=== Phase I Result
1. $norm(wsp^((t))) leqa theta log^C (d)$

2. $norm(wsig), norm(wopp) leqa theta log^(2 C) (d) d^(-1 slash 2)$

3. $norm(bw_perp^((t))) asymp theta, norm(bw_perp^((t)) - bw_perp^((0))) leqa theta log^(-C) (d)$
4. $norm(bw_perp^((t)))_infinity leqa theta log^(4 C) (d) d^(-1 slash 2)$
5. $norm(w^((t))) asymp norm(wsp^((t))) + norm(bw_perp^((t))) leqa theta log^(C) (d)$
