#set text(font: "New Computer Modern Math")
#import "@preview/ctheorems:1.1.3": *
#show: thmrules

#let theorem = thmbox("theorem", "Theorem", fill: rgb("#ffdddd"))
#let lemma = thmbox("lemma", "Lemma", fill: rgb("#ddddff"))
#let proof = thmproof("proof", "Proof")

#let inner(a, b) = $chevron.l #a, #b chevron.r$
#let grad = $gradient$
#let leqa = $lt.tilde$

= Setup Definitions
#let bw = $bold(w)$
#let bx = $bold(x)$

== Data
- Data $bold(x)$ is distributed like i.i.d Rademacher in all entries except the third entry, and the target function is $y(x) = - x_1x_2$, the XOR on the first two entries
- The third entry is like a planted answer, with probability $1-lambda$ it is the XOR of the first two entries, and with probability $lambda$ it's the negation

- We decompose $bold(w) = bold(w)_"sig" + bold(w)_"opp" + bold(w)_"sp" + bold(w)_perp$ where sig is the projection onto the signal direction, which depends on the sign of $a$, $bw_"opp"$ points in the "other" direction (discussed below), $bold(w)_"sp"$ is the projection onto the third coordinate, and $bold(w)_"perp"$ is everything else
  - The sign of $a$ determines the sign of a particular neuron's contribution, and therefore whether we want to align with $plus.minus mu_1$ (the choices of $bold(z)$ that are $1$ under XOR) vs $plus.minus mu_2$ (the $-1$ inputs) so $bw _"opp"$ is just the orthogonal direction to the signal
- We decompose $bx = bold(z) + bold(s) + bold(zeta)$, which are the projections onto the first two coordinates (so $y(bx) = y(bold(z))$), the projection onto the third coordinate, and the remaining $d-3$ coordinates respectively
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
  $ inner(-wsig, grad_bw L_0) = sqrt(2)/4 abs(a) norm(wsig) Pr_zeta [abs(inner(w, zeta)) + abs(inner(w, e_3)) <= sqrt(norm(wsig))] $
  $ inner(-wopp, grad_bw L_0) = (-sqrt(2))/4 abs(a) norm(wsig) Pr_zeta [abs(inner(w, zeta)) + abs(inner(w, e_3)) <= sqrt(norm(wsig))] $
] <label>
Okay so roughly speaking we characterize the gradient of the $L_0$ approximation of the population loss, we can think of the right hand side as being our gradient step up to scaling so the $wsig$, $wopp$ directions of $bw$ grow in opposite directions with the same magnitude.
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
