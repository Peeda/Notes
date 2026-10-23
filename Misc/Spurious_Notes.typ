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

Typos List:
- On page $24$ above equation $6$, below "the above gives us" shouldn't the randomness be over $xi$ as well as $z$
- Page $42$ claims that the definition of $cal(E)_"test"$ is that $abs(bold(w)_perp^top bold(x)) < C norm(bold(w)_perp)log^(1 slash 2) (d)$ but really this is just part of the definition/implied, $cal(E)_"test"$ also includes a bound on flipping the sign for any $x_i$ where $ i > 3$
- Page $87$ lists F.15 as a Theorem but in the appendix it's a lemma
Questions List:
- How would you go about discovering the assumptions used in the inductive hypothesis for each recurrence? It's clear how recurrences imply asymptotics and how the scalings follow from constraints from doing the proofs, but it's not obvious to me how we find the inductive hypothesis in the first place such that we can show it's maintained

#outline()
#pagebreak()

= Setup Definitions
#let bw = $bold(w)$
#let bx = $bold(x)$
#let bz = $bold(z)$
#let bs = $bold(s)$
#let bxi = $bold(xi)$
#let smaj = $bold(s)_"maj"$
#let smin = $bold(s)_"min"$
#let wsps = $w_"sp"$

#let todo(body) = text(fill: red)[*TODO:* #body]






== Data
- Data $bold(x)$ is distributed like i.i.d Rademacher in all entries except the third entry, and the target function is $y(x) = - x_1x_2$, the XOR on the first two entries
- The third entry is like a planted answer, with probability $1-lambda$ it is the XOR of the first two entries, and with probability $lambda$ it's the negation

- We decompose $bold(w) = bold(w)_"sig" + bold(w)_"opp" + bold(w)_"sp" + bold(w)_perp$ where sig is the projection onto the signal direction, which depends on the sign of $a$, $bw_"opp"$ points in the "other" direction (discussed below), $bold(w)_"sp"$ is the projection onto the third coordinate, and $bold(w)_"perp"$ is everything else
  - The sign of $a$ determines the sign of a particular neuron's contribution, and therefore whether we want to align with $plus.minus mu_1$ (the choices of $bold(z)$ that are $1$ under XOR) vs $plus.minus mu_2$ (the $-1$ inputs) so $bw _"opp"$ is just the orthogonal direction to the signal
- We decompose $bx = bold(z) + bold(s) + bxi$, which are the projections onto the first two coordinates (so $y(bx) = y(bold(z))$), the projection onto the third coordinate, and the remaining $d-3$ coordinates respectively
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
  For any neuron $(a,bw)$ we have
  $ -wsig^top grad_bw L_0 = sqrt(2)/4 abs(a) norm(wsig) Pr_bxi [abs(bw^top bold(e)_3 + bw^top bxi) <= sqrt(2) norm(wsig)] $
  $ -wopp^top grad_bw L_0 = sqrt(2)/4 abs(a) norm(wopp) Pr_bxi [abs(bw^top bold(e)_3 + bw^top bxi) <= sqrt(2) norm(wopp)] $
] <lemma-l0-sig>

#proof[of @lemma-l0-sig][
  Note that we have by definition of $L_0$ as the first order approximation and a previous calc that
  $ -wsig^top grad_w L_0 &= -wsig^top EE[p partial/(partial bw) -y(bx) f_rho (bx)] \
    &= wsig^top EE[ y(x) p partial/(partial bw) 1/p sum_j a_j sigma(bw^top bx)  ] \
    &= wsig^top EE[y(x) a sigma' (bw^top bx) bx]
  $
  and by recognizing that $wsig^top$ is orthogonal to $bx - bz$ we can split the above by using $bx = bz + bold(s) + bxi$ so that the above equals $EE[y(bz) a sigma'(bw^top bx) wsig^top bz]$ also using that $y$ is determined by $bz$. So intuitively this part gradient only depends on $bx$ in units $3,...,d$ via this inner sigmoid, as everything else is projected into $mu_"sig"$'s span. From here we use iterated expectations to condition on whether $wsig || bz$, noting that the above is zero when the two are orthogonal to get
  $ &= 1/2 limits(EE)_(x,z \ wsig|| bz) [y(z) a sigma'(bw^top bx) wsig^top bz] \
    &= 1/2 limits(EE)_(x,z \ wsig|| bz) [y(z) a sigma'(wsig^top bz + bw^top bold(s) + bw^top bxi) wsig^top bz] $
  letting $bz_0$ denote one of the two values of $bz$ such that we have $wsig || z_0$ (so if $a > 0$ then $mu_1$ else $mu_2$) we know that $(bz,bs)$ are independent and $bz$ is $plus.minus bz_0$ with probability $1 slash 2$ each, and that $bs$ is $smaj$ with prob $1-lambda$ and $smin$ with prob $lambda$. Recall that $smaj$ is just aligned with the sign of $a$ and so we have $bs=smaj$ with prob $1-lambda$ because $s=smaj$ if and only if $s$ and $a$ share signs, which is the same as $s$ being one for $z= plus.minus mu_1$ and $-1$ otherwise.
  #todo[Okay I should review this at some point since walking back how things are defined relative to sign of $a$ seems difficult to me, there's probably an easier way to see it, any way this allows us to expand the above. This is probably the same as just thinking of $smaj$ as the xor of $bz_0$ but that's not the definition itself.]

  Noting that we're just varying the signs of $bz, bs$ let's introduce the shorthand $sigma'(plus.minus, plus.minus)$ to mean $sigma'(wsig^top (plus.minus bz) + bw^top (plus.minus bs) + bw^top bxi) $ so the above equals
  $ = 1/2 a(\
    (1/2 - lambda/2) dot &EE_bxi [y(bz_0) sigma'(+, +) wsig^top bz_0] \
  + lambda/2 dot &EE_bxi [y(bz_0) sigma'(+, -) wsig^top bz_0] \
  + (1/2 - lambda/2) dot &EE_bxi [y(-bz_0) sigma'(-, +) wsig^top (-bz_0)] \
  + lambda/2 dot &EE_bxi [y(-bz_0) sigma'(-,-) wsig^top (-bz_0)] \
  )
  $
and we  can factor our the $1 slash 2$, then observe that $y(bz_0) = y(-bz_0)$ with $a y(bz_0) = a y(-bz_0) = abs(a)$ by the fact $bz_0$'s xor aligns with the sign of $a$ to get
  $
    = 1/4 abs(a) (\
    (1 - lambda) dot &EE_bxi [sigma'(+, +) wsig^top bz_0] \
  + lambda dot &EE_bxi [sigma'(+, -) wsig^top bz_0] \
  + (1 - lambda) dot &EE_bxi [sigma'(-, +) wsig^top (-bz_0)] \
  + lambda dot &EE_bxi [sigma'(-,-) wsig^top (-bz_0)] ) \

  = 1/4 abs(a) wsig^top bz_0 (\
  (1 - lambda) dot &EE_bxi [sigma'(+, +)] \
  + lambda dot &EE_bxi [sigma'(+, -)] \
  - (1 - lambda) dot &EE_bxi [sigma'(-, +)] \
  - lambda dot &EE_bxi [sigma'(-,-)]) \
  $
from here we'll group terms according to the sign of $smaj$ (this will let us apply an identity about differences of certain indicators) to get
$
  = 1/4 abs(a) wsig^top bz_0 ( \
    &EE_bxi [sigma'(+,+) - sigma'(-, +)] \
    + lambda &EE_bxi [sigma'(-,+) - sigma'(+, +)] \
    + lambda &EE_bxi [sigma'(+,-) - sigma'(-, -)] )
$
unrolling definitions now since the manipulations are done and recognizing $sigma'(x) = bb(1) [x >= 0]$, the above is
$
  = 1/4 abs(a) wsig^top bz_0 ( \
    &EE_bxi [bb(1)[wsig^top bz + bw^top bs + bw^top bxi] - bb(1)[wsig^top (-bz) + bw^top bs + bw^top bxi]] \
    + lambda &EE_bxi [bb(1)[wsig^top (-bz) + bw^top bs + bw^top bxi] - bb(1)[wsig^top bz + bw^top bs + bw^top bxi]] \
    + lambda &EE_bxi [bb(1)[wsig^top bz + bw^top (-bs) + bw^top bxi] - bb(1)[wsig^top (-bz) + bw^top (-bs) + bw^top bxi]] )
$
From here consider that for $a,b,c in RR$ we have
$ bb(1)[a+b+c >= 0] - bb(1)[-1+b+c >= 0] = bb(1)[b+c >= -a] - bb(1)[b+c>=a] $
where the above is $1$ if and only if the first indicator is true and the second false, and $-1$ if the first false and the second true, and $0$ otherwise. Therefore the above is
$ = cases(1 &"when" a <= b + c <= -a, -1 &"when" -a <= b + c <= a, 0 &"else") $
or equivalently, this is nonzero when $abs(b+c) <= abs(a)$ with the sign being the opposite of $a$'s sign as the sign of $a$ determines whether which case is valid. This type of argument works for all three differences of indicators and actually lets us group the first two differences of indicators since they share $bw^top bs + bw^top bxi$ just up to a sign flip so the above equals
$ = 1/4 abs(a) wsig^top bz_0 ( \

  (1-lambda) &Pr_bxi [abs(bw^top smaj + bw^top bxi) <= abs(wsig^top bz_0)]sgn(wsig^top bz_0)  \

  + lambda &Pr_bxi [abs(-bw^top smaj + bw^top bxi) <= abs(wsig^top bz_0)]sgn(wsig^top bz_0)
  ). $
We now observe that $wsig^top bz_0 sgn(wsig^top bz_0) = abs(wsig^top bz_0) = norm(wsig^top) norm(z_0) = sqrt(2) norm(wsig^top)$ with the last two steps following from the fact $wsig || bz_0$ and so Cauchy-Schwarz is tight here, with $norm(bz_0) = sqrt(2)$ following from definition of $bz_0$. We use this to factor out $sgn(wsig^top bz_0)$ from both terms and also to rewrite the $abs(wsig^top bz_0)$ term inside each probability:
$ = sqrt(2)/4 abs(a) norm(wsig)( \
  (1-lambda) &Pr_bxi [abs(bw^top smaj + bw^top bxi) <= sqrt(2) norm(wsig)] \
  + lambda &Pr_bxi [abs(-bw^top smaj + bw^top bxi) <= sqrt(2) norm(wsig)]
  ). $
and we conclude the proof by noting that $bxi$ is symmetric, so in particular we can flip $bxi$ with $-bxi$ while preserving probabilities; because of the absolute value this is the same as flipping the sign of $smaj$ so
$
Pr_bxi [abs(-bw^top smaj + bw^top bxi) <= sqrt(2) norm(wsig)]=
Pr_bxi [abs(bw^top smaj + bw^top bxi) <= sqrt(2) norm(wsig)]= \
Pr_bxi [abs(bw^top bold(e)_3 + bw^top bxi) <= sqrt(2) norm(wsig)]
$
which allows us to conclude the above equals
$ = sqrt(2)/4 abs(a) norm(wsig) Pr_bxi [abs(bw^top bold(e)_3 + bw^top bxi) <= sqrt(2) norm(wsig)] $
as desired.
]
#let e3 = $bold(e)_3$
#lemma[$L_0$ gradient along spurious direction][
  For any neuron $(a,bw)$ we have
  $ -wsp^top grad_bw L_0 = a w_"sp" (1/2 + epsilon_bw/4 - lambda) $
  where
  $
    A = min({plus.minus bw^top bold(mu)_1, plus.minus bw^top bold(mu)_2}), " "
    B = min({plus.minus bw^top bold(mu)_1, plus.minus bw^top bold(mu)_2} without A) \
    epsilon_bw = cases(
    Pr_bxi [bw^top bxi - wsps in [A,B] ] - Pr_bxi [bw^top bxi + wsps in [A,B] ] "if" sgn(w_1) = sgn(w_2),
    Pr_bxi [bw^top bxi + wsps in [A,B]] - Pr_bxi [bw^top bxi - wsps in [A,B] ] "if" sgn(w_1) != sgn(w_2)) $
] <lemma-l0-sp>
#proof[of @lemma-l0-sp][
  Begin as before using that $grad_bw L_0 = EE_x [-y(z) a sigma'(bw^top bx) bx]$ to get
  $ -wsp^top grad_bw L_0 = EE_bx [y(bz) a sigma'(bw^top bx) wsp^top bs]  $
  and then expand over $bs$ using that $bs = y(bz)$ with probability $1-lambda$, with $bx, bxi$ independent of $bs$ to get
  $ = a((1 - lambda) &EE_(bz, bxi) [y(bz) sigma'(bw^top bz + bw^top y(bz) e3 + bw^top bxi) wsp^top y(bz) e3 ] \
    + lambda &EE_(bz, bxi) [y(bz) sigma'(bw^top bz - bw^top y(bz) e3 + bw^top bxi) wsp^top (-y(bz) e3)]) ) $
  and we factor out $y(bz)^2 = 1$, rewriting expectations of indicators as probabilities (using again that the derivative of the relu is an indicator) to get
  $
    = a w_"sp" (
      (1-lambda) &Pr_(bz, bxi) [bw^top bz + bw^top bxi >= -y(bz) w_"sp"] \
      + lambda &Pr_(bz, bxi) [bw^top bz + bw^top bxi >= y(bz) w_"sp"]  )
  $
  from here observe that by symmetry of $bz$ and the fact that $y(bz) = y(-bz)$ followed by using the symmetry of $bxi$ we have
  $
    &Pr_(bz, bxi) [bw^top bz + bw^top bxi >= -y(bz) w_"sp"] + Pr_(bz, bxi) [bw^top bz + bw^top bxi >= y(bz) w_"sp"] \
    = &Pr_(bz, bxi) [bw^top bz + bw^top bxi >= -y(bz) w_"sp"] + Pr_(bz, bxi) [-bw^top bz + bw^top bxi >= y(bz) w_"sp"] \
    = &Pr_(bz, bxi) [bw^top bz + bw^top bxi >= -y(bz) w_"sp"] + Pr_(bz, bxi) [-bw^top bz - bw^top bxi >= y(bz) w_"sp"] \
    = &Pr_(bz, bxi) [bw^top bz + bw^top bxi >= -y(bz) w_"sp"] + Pr_(bz, bxi) [bw^top bz + bw^top bxi < -y(bz) w_"sp"]  = 1
  $
  I'm not being careful here with strict inequalities vs including the equals case but I don't think it matters. This gives that our desired quantity equals
  $
    = a w_"sp" (Pr_(bz, bxi) [bw^top bz +bw^top bxi >= -y(bz) wsp] - lambda )
  $
  so it remains to show that the above probability equals $1/2 + epsilon_bw/4$. We first expand over the distribution of $z in {plus.minus mu_1, plus.minus mu_2}$ unifomrly to get
  $ Pr_(bz, bxi) [bw^top bz +bw^top bxi >= -y(bz) wsp] = Pr_(bz, bxi) [bw^top bxi + y(bz) w_"sp" > -bw^top bold(mu)_1]
    \ = 1/4 (
    Pr_bxi [bw^top bxi + w_"sp" > - bw^top bold(mu)_1] \
    +Pr_bxi [bw^top bxi + w_"sp" >  bw^top bold(mu)_1] \
    +Pr_bxi [bw^top bxi - w_"sp" > - bw^top bold(mu)_2] \
    +Pr_bxi [bw^top bxi - w_"sp" >  bw^top bold(mu)_2]
  ) $
  and then take complements for the first two probabilities, and use the symmetry of $bxi$ for the last two to rewrite the above as
  $
    = 1/2 + 1/4 (
    -&Pr_bxi [bw^top bxi + w_"sp" <= - bw^top bold(mu)_1] \
    -&Pr_bxi [bw^top bxi + w_"sp" <= bw^top bold(mu)_1] \
    +&Pr_bxi [bw^top bxi + w_"sp" <=  bw^top bold(mu)_2] \
    +&Pr_bxi [bw^top bxi + w_"sp" <= - bw^top bold(mu)_2])
  $
  let $A <= B <= C <= D$ be the ordering of ${plus.minus bw^top bold(mu)_1, plus.minus bw^top bold(mu)_2}$, observing that $A = -D$ and $B = -C$ with $A,B <= 0$ and $C,D >= 0$. Therefore the ordering is determined by whether $abs(A),abs(B)$ is bigger, which is equivalent to whether $sgn(w_1) = sgn(w_2)$ as $bold(mu)_1, bold(mu)_2$ subtract and add these two entries respectively when taking inner products.

  Considering first the case where $sgn(w_1)=sgn(w_2)$ and so $bw^top bold(mu)_2$ is larger in absolute value write $X = bw^top bxi + w_"sp"$; we have that the above probability is
  $
    -Pr[X <= B] - Pr[X <= C] + Pr[X <= A] + Pr[X <= D]  \
    = Pr[X <= A] + Pr[X <= D] - Pr[X <= B] - Pr[X <= C] \
    = Pr[X <= A] + (Pr[X <= A] + Pr[A <= X <= D]) \ - (Pr[X <= A] + Pr[A <= X <= B]) - (Pr[X <= A] + Pr[A <= X <= C)] \
    = Pr[A <= X <= D] - Pr[A <= X <= B] - Pr[A <= X <= C] \
    = Pr[C <= X <= D] - Pr[A <= X <= B]
  $
  and we notice that the above is $Pr[bw^top bxi + w_"sp" in [C,D]] - Pr[bw^top bxi + w_"sp" in [A,B]]$ where the symmetry of $bxi$ gives that the first term equals $Pr[-bw^top bxi + w_"sp" in [C,D]] = Pr[bw^top bxi - w_"sp" in [A,B]]$ where we used that $A=-C, B=-D$. Therefore as desired, the above equals
  $ Pr[bw^top bxi - w_"sp" in [A,B]] - Pr[bw^top bxi + w_"sp" in [A,B]] $

  In the case where $sgn(w_1) != sgn(w_2)$ you can check that we get the negation of the original expression with respect to the ordering of $A,B,C,D$ so the same argument applies with the result being the negation of the above probability, as claimed.
]
#lemma[$epsilon_bw$ is exponentially small][
  For $epsilon_bw$ defined as in @lemma-l0-sp we have
  $ abs(epsilon_bw) leqa norm(bw_(1:2))/norm(bw_perp) exp(frac(sqrt(2) norm(bw_(1:2)) norm(wsp) - wsps^2, norm(bw_perp)_2^2)) + frac(norm(bw_perp)_3^3, norm(bw_perp)_2^3) $
] <lemma-l0-epsilon_small>
#proof[of @lemma-l0-epsilon_small][
  Note that for bounding the absolute value, by the definition of $epsilon_bw$, we can take the first case without loss of generality such that $epsilon_bw = Pr_bxi [bw^top bxi - wsps in [A,B]] - Pr_bxi [bw^top bxi + wsps in [A,B]]$ as the other case has the same absolute value.

  From here the high level appraoch is use a form of Berry-Esseen given in #todo("appendix") to rewrite the above as a difference of Gaussian cdfs and apply a few identities to get our desired bound. Writing $phi(u)$ for the pdf of a Gaussian with mean zero and variance $norm(bw_perp)^2$, Berry-Esseen gives that
  $ epsilon_bw leqa integral_(A + wsps)^(B + wsps) phi(u) d u - integral_(A - wsps)^(B - wsps) phi(u) d u + frac(norm(bw_perp)_3^3, norm(bw_perp)^2^3)
    \ = integral_(A)^(B) (phi(u + wsps) - phi(u - wsps)) d u + frac(norm(bw_perp)_3^3, norm(bw_perp)_2^3)
  $
  where the definition of the Gaussian pdf gives that the integral term is
  $

    &integral_A^B 1/(norm(bw_perp) sqrt(2pi)) (e^(-(u + wsps)^2 slash 2 norm(bw_perp)^2) - e^(-(u - wsps)^2 slash 2 norm(bw_perp)^2)) d u  \
    &= integral_A^B 1/(norm(bw_perp) sqrt(2pi)) (e^((-u^2 - 2 u wsps - wsps^2) slash 2 norm(bw_perp)^2) - e^((-u^2 + 2 u wsps - wsps^2) slash 2 norm(bw_perp)^2)) d u  \
    &= integral_A^B 1/(norm(bw_perp) sqrt(2pi)) e^((-u^2 - wsps^2) slash 2 norm(bw_perp)^2) (e^(-2 u wsps slash 2 norm(bw_perp)^2) - e^(2 u wsps slash 2 norm(bw_perp)^2)) d u  \
    &= integral_A^B (1/(norm(bw_perp) sqrt(2pi)) e^(-wsps^2 slash 2 norm(bw_perp)^2)) e^(-u^2 slash 2 norm(bw_perp)^2) (e^(-2 u wsps slash 2 norm(bw_perp)^2) - e^(2 u wsps slash 2 norm(bw_perp)^2)) d u  \
    &= phi(wsps) integral_A^B e^(-u^2 slash 2 norm(bw_perp)^2) (e^(-u wsps slash norm(bw_perp)^2) - e^(u wsps slash norm(bw_perp)^2)) d u  \

    &= -2 phi(wsps) integral_A^B e^(-u^2 slash 2 norm(bw_perp)^2) sinh (u wsps slash norm(bw_perp)^2) d u  \

  $
  and so we have
  $ abs(epsilon_bw) leqa phi(wsps) integral_A^B exp(-u^2 slash 2 norm(bw_perp)^2) abs(sinh(u wsps slash norm(bw_perp)^2)) d u + norm(bw_perp)_3^3/norm(bw_perp)_2^3 $
  from here we use that $abs(sinh x) <= cosh x <= exp (abs(x))$ and take a uniform upper bound to get
  $ &<= phi (wsps) (B - A) max_(u in [A,B]) underbrace(exp(-u^2 slash 2 norm(bw_perp)^2), <= 1) underbrace(exp(abs(frac(u wsps, norm(bw_perp)^2))),  "maxmized at" u=D=abs(A)) + norm(bw_perp)_3^3/norm(bw_perp)_2^3  \
    &<= phi(wsps) (B - A) exp(abs(A) wsps slash norm(bw_perp)^2) + norm(bw_perp)_3^3/norm(bw_perp)_2^3 \
    &= 1/(sqrt(2 pi) norm(bw_perp)) exp(-wsps^2 slash 2 norm(bw_perp)^2) (B - A) exp(abs(A) wsps slash norm(bw_perp)^2) + norm(bw_perp)_3^3/norm(bw_perp)_2^3 \
  $
  from here we use that $B-A <= abs(A)$ as $A,B,C,D$ are the four ways we can assign signs to $w_1, w_2$ with $abs(A)=D$ being the maximizer, where $B-A in {A,B,C,D}$ by linearity. Furthermore $abs(A) <= sqrt(2) norm(bw_(1:2))$ by Cauchy-Schwarz so we have
  $
    leqa (B-A)/norm(bw_perp) exp(frac(2 abs(A) wsps - wsps^2, 2 norm(bw_perp)_2^2)) + norm(bw_perp)_3^3/norm(bw_perp)_2^3  \
    leqa norm(bw_(1:2))/norm(bw_perp) exp(frac(sqrt(2) norm(bw_(1:2)) norm(wsp) - wsps^2, norm(bw_perp)_2^2)) + norm(bw_perp)_3^3/norm(bw_perp)_2^3
  $
  as claimed.


]
#lemma[$L_0$ gradient along perp][
  For any neuron $(a,bw)$ we have
  $ -bw_perp^top grad_bw L_0 = 1/8 abs(a) EE[abs(bw^top bxi) ( \
    bb(1) [abs(bw^top bxi) >= abs(sqrt(2) norm(wsig) + wsps) ] +  bb(1) [abs(bw^top bxi) >= abs(sqrt(2) norm(wsig) - wsps) ] \
    bb(1) [abs(bw^top bxi) >= abs(sqrt(2) norm(wopp) + wsps) ] + bb(1) [abs(bw^top bxi) >= abs(sqrt(2) norm(wopp) - wsps) ]
  )] $
] <lemma-l0-perp>
#proof[of @lemma-l0-perp][

  As before we can use the definition of $L_0$ to see that
  $ -bw_perp^top grad_bw L_0 = -bw_perp^top EE[-y(bx) a sigma' (bw^top bx) bx] = EE[y(bz) a sigma' (bw^top bx) bw_perp^top bxi] $
  and here we'll appeal to the symmetry of $bxi$ right at the start to get this equals
  $ = 1/2 a EE[y(bz) bw_perp^top bxi (sigma'(bw^top bz + bw^top bs + bw^top bxi) - sigma'(bw^top bz + bw^top bs - bw^top bxi))] $
  $ = 1/2 a EE[y(bz) bw_perp^top bxi (bb(1)[bw^top bz + bw^top bs + bw^top bxi] - bb(1)[bw^top bz + bw^top bs - bw^top bxi])] $
  as before, notice that $bb(1)[a+b+c] - bb(1)[a+b-c]$ is one when $-c <= a+b<= c$ and negative one when $c <= a + b <= -c$ and so it equals $sgn(c) bb(1)[abs(a+b) <= abs(c)]$, and so the above equals, after using $sgn(x)x=abs(x)$,
  $ = 1/2 a EE[y(z) abs(bw_perp^top bxi) bb(1) [abs(bw_perp^top bxi) >= abs(bw^top bz + bw^top bs)] ] $
  unlike the proof of @lemma-l0-sig we're not doing any conditioning on whether $wsig||bz$ so we just expand here over $(bz,bs)$, grouping $1-lambda$ terms and $lambda$ terms that have the same value because of absolute values to get
  $ = 1/8 a EE[&abs(bw_perp^top bxi) (\
    & bb(1) [abs(bw^top bxi) >= abs(bw^top bold(mu_1) + wsps)] \
    + & bb(1) [abs(bw^top bxi) >= abs(bw^top bold(mu_1) - wsps)] \
    - & bb(1) [abs(bw^top bxi) >= abs(bw^top bold(mu_2) + wsps)] \
    - & bb(1) [abs(bw^top bxi) >= abs(bw^top bold(mu_2) - wsps)] \
    )] $
and if $(bw,a)$ is a positive neuron then $bw^top bold(mu_1) = sqrt(2) norm(wsig)$, and for negative neurons $wsig, wopp$ swap roles (so they get opposite signs). Given that negative neurons have $a < 0$ we can compactly write this as
$ = 1/8 abs(a) EE[&abs(bw_perp^top bxi) (\
  & bb(1) [abs(bw^top bxi) >= sqrt(2)norm(wsig) + wsps)] \
  + & bb(1) [abs(bw^top bxi) >= sqrt(2)norm(wsig) - wsps)] \
  - & bb(1) [abs(bw^top bxi) >= sqrt(2)norm(wopp) + wsps)] \
  - & bb(1) [abs(bw^top bxi) >= sqrt(2)norm(wopp) - wsps)] \
  )] $
as desired.
#todo("why is this expression uglier than the signal direction's expression? Does it say something interesting about how xi and the first two coordinates behave differently?")
]
#let xnoi = $bx_(without i)$
#let xinoi = $bold(xi)_(without i)$
#lemma[$L_0$ gradient for a coordiante of perp][
  For any neuron $(a,bw)$ we have
  $ -w_i partial_(w_i) L_0 &= 1/8 abs(a) abs(w_i) \ [
    &Pr_bxi [abs(w_i) >= abs(sqrt(2) norm(wsig) + w_"sp" + bw^top xinoi)] + Pr_bxi [abs(w_i) >= abs(sqrt(2) norm(wsig) - w_"sp" + bw^top xinoi)] \
    -&Pr_bxi [abs(w_i) >= abs(sqrt(2) norm(wopp) + w_"opp" + bw^top xinoi)] - Pr_bxi [abs(w_i) >= abs(sqrt(2) norm(wopp) - w_"opp" + bw^top xinoi)]
  ] $
] <lemma-l0-perp-coord>

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
    = 1/2 a abs(w_i) EE_x [y(z) bb(1)[abs(w_i) >= abs(bw^top bz + bw^top bs + bw^top xinoi)]]
  $
  as in @lemma-l0-perp we expand over the distribution $(bz,bxi)$, using the structure of the absolute value being taken on the right hand side to group pairs of terms with probability $1/4 (1-lambda)$ and $1/4 lambda$ that take matching values under absolute value to get
  $ = 1/2 a abs(w_i) EE_bxi \ [
    & bb(1)[abs(w_i) >= abs(bw^top bold(mu)_1 + wsp e3 + bw^top xinoi)] &&+ bb(1)[abs(w_i) >= abs(bw^top bold(mu)_1 - wsp e3 + bw^top xinoi)] \
    - &bb(1)[abs(w_i) >= abs(bw^top bold(mu)_2 + wsp e3 + bw^top xinoi)] &&- bb(1)[abs(w_i) >= abs(bw^top bold(mu)_2 - wsp e3 + bw^top xinoi)] ]
  $
  and as in @lemma-l0-perp we note that when $a > 0$ we take $wsig$ to align with $bold(mu)_1$, and for $a < 0$ it's with $bold(mu)_2$ and so we can use that the above terms swap $bold(mu)_1, bold(mu)_2$'s roles up to signs to write this as
  $ = 1/2 abs(a) abs(w_i) EE_bxi \ [
    & bb(1)[abs(w_i) >= abs(sqrt(2) norm(wsig) + wsp e3 + bw^top xinoi)] &&+ bb(1)[abs(w_i) >= abs(sqrt(2) norm(wsig) - wsp e3 + bw^top xinoi)] \
    - &bb(1)[abs(w_i) >= abs(sqrt(2) norm(wopp) + wsp e3 + bw^top xinoi)] &&- bb(1)[abs(w_i) >= abs(sqrt(2) norm(wopp) - wsp e3 + bw^top xinoi)] ]
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
=== Phase I Asymptotics
==== The $w$ part
#set math.equation(numbering: "1.")
$ norm(wsp^((t))) leqa theta log^C (d) $ <phase1-asymp-norm-wsig>

$ norm(wsig), norm(wopp) leqa theta log^(2 C) (d) d^(-1 slash 2) $ <phase1-asymp-norm-wsigopp>

$ norm(bw_perp^((t))) asymp theta, #text("and") norm(bw_perp^((t)) - bw_perp^((0))) leqa theta log^(-C) (d) $ <phase1-asymp-2norm-wperp>
$ norm(bw_perp^((t)))_infinity leqa theta log^(4 C) (d) d^(-1 slash 2) $ <phase1-asymp-infnorm-wperp>
$ norm(w^((t))) asymp norm(wsp^((t))) + norm(bw_perp^((t))) leqa theta log^(C) (d) $ <phase1-asymp-norm-w>
==== The $a$ part
#counter(math.equation).update(0)


$ norm(a^((t))) leqa (1 plus.minus o(log^(-2)(d))) dot norm(bw^((t))) leqa (1 plus.minus o(log^(-2)(d))) dot (norm(wsp^((t))) + norm(bw_perp^((t)))) leqa theta log^(C) (d) $ <phase1-asymp-norm-a>
$ sgn(a^((t))) = sgn(a^((0))) $ <phase1-asymp-sign-a-alignment>
$ EE _((a, bw) tilde rho) norm(a^((t)) bw^((t))) leqa theta^2 log ^(2 C) (d) $
#set math.equation(numbering: none)

== Phase Inductive Steps
=== $wsps$ inductive step
We want want to show that if the IH holds for $k <= t$ and we have $cal(E)_"train"$ which is needed for the lemmas that establish asymptotics, then we have
$ wsps^((t+1)) - wsps^((t)) = eta (1 plus.minus o(log^(-2)(d))) (1/2 - lambda) sgn(a^((0))) (abs(wsps) + theta) $
and I will not use the superscript notation to denote the iteration as most of the time it's $t$ or otherwise clear. It's important to note we have $sgn(a^((0)))$ in the statement though.

We first consider the definition of our SGD update; we have that
$ wsps^((t+1)) - wsps^((t)) = - eta partial_wsps hat(L)_rho = - eta (partial_wsps L_0 + partial_wsps (hat(L)_rho - L_0)) = - eta/wsps (wsp^top grad_bw L_0 + wsp^top grad_bw (hat(L)_rho - L_0))  $

and in #ref(<lemma-l0-sp>) we established that
$ -wsp^top grad_bw L_0 = a wsps (1/2 + epsilon_bw/4 - lambda) $
where we will show that from #ref(<lemma-l0-epsilon_small>) it follows that $abs(epsilon_bw) leqa log^(-2)(d)$. From there we use #ref(<phase1-asymp-norm-a>) and #ref(<phase1-asymp-2norm-wperp>) in the Phase I asymptotics to establish that $abs(a^((t))) = (1 + o(log^(-2)(d))) (abs(wsps) + theta)$ implying
$ -wsp^top grad_bw L_0 = (1 plus.minus o(log^(-2)(d)))(1/2 - lambda) sgn(a^((t))) sgn(wsps) abs(wsps) (abs(wsps) + theta) $
we will then show that the $wsp^top grad_bw (hat(L)_rho - L_0)$ term is asymptotically dominated such that
$ wsps^((t+1)) - wsps^((t)) = - eta / wsps (-(1 plus.minus o(log^(-2)(d)))(1/2 - lambda) sgn(a^((t))) sgn(wsps) abs(wsps) (abs(wsps) + theta)) $
$ = eta (1 plus.minus o(log^(-2)(d))) (1/2 - lambda) sgn(a^((t))) (abs(wsps) + theta) $
$ = eta (1 plus.minus o(log^(-2)(d))) (1/2 - lambda) sgn(a^((0))) (abs(wsps) + theta) $
Where we used #ref(<phase1-asymp-sign-a-alignment>) in the last step. Okay so then it just remains to show the claimed asymptotic bound on $abs(epsilon_bw)$ and to establish that the $wsp^top grad_bw (hat(L)_rho - L_0)$ is asymptotically small. First considering $abs(epsilon_bw)$ recall that by #ref(<lemma-l0-epsilon_small>) we have
$ abs(epsilon_bw) leqa norm(bw_(1:2))/norm(bw_perp) exp((- norm(wsp)^2 + 2 sqrt(2) norm(bw_(1:2)) norm(wsp))/(2 norm(bw_perp)_2^2)) + norm(bw_perp)_3^3 / norm(bw_perp)^3  \
  <=
  norm(bw_(1:2))/norm(bw_perp) exp((2 sqrt(2) norm(bw_(1:2)) norm(wsp))/(2 norm(bw_perp)_2^2)) + norm(bw_perp)_infinity / norm(bw_perp)
$
and we plug in our scalings $
  norm(bw_(1:2)) leqa (theta log^(2 C)(d)) slash sqrt(d) \
  norm(bw_perp)_2 asymp theta \
  norm(wsp) leqa theta log^(C) (d) \
  norm(bw_perp)_infinity leqa theta log ^(4 C) (d) slash sqrt(d) \
$
to get that the above is
$ leqa (theta log^(2 C) (d) slash sqrt(d))/theta exp((C theta log^(2C) (d) dot theta log^(C) (d))/(theta^2 sqrt(d))) + (theta log^(4 C) (d) )/(theta sqrt(d))  \
  = log^(2C) slash sqrt(d) dot  exp(C log^(3 C) (d) slash sqrt(d)) + log^(4 C) (d) slash sqrt(d)
$
and use that $1 + u leqa exp(u)$ (yes this isn't meant to be $1+x <= exp(x)$) to get
$ leqa 1/sqrt(d) (log^(2C) (1 + log^(3C)(d)) + log^(4 C)(d))  leqa log^(5 C) (d) slash sqrt(d) leqa log^(2 C) (d) $
as desired. Now considering $-wsp^top grad_bw (hat(L)_rho - L_0)$ observe that #todo("type up this lemma at some point and ref") in the $i=3$ case states
$ abs(partial_wsp (hat(L)_rho - L_0)) leqa theta^3 log^(4 C) (d) + theta log^(-2)(d) slash sqrt(d) $
and so
$ abs(wsp^top grad_bw (hat(L)_rho - L_0)) &<= norm(wsp) dot norm(bold(e)_3^top grad_bw (hat(L)_rho - L_0)) \
  &= abs(wsps) dot norm(partial_wsp (hat(L)_rho - L_0))\
  &leqa abs(wsps) (theta^3 log^(4C) (d)  +theta log^(-2)(d) slash sqrt(d))
$
our scalings assume that $theta << log^(-5C) (d)$ so this is
$
  leqa abs(wsps) (theta log^(-6C)(d) + theta log^(-2)(d) slash sqrt(d)) leqa abs(wsps) theta leqa wsp^top grad_bw L_0
$
as claimed.
