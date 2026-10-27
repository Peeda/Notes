---
type: paper
title: SGD Provably Prioritizes a Shortcut Spurious Feature in the XOR Model
paper-author:
author: Peter Chen
date: 2026-10-26
tags:
  - spurious-xor
---
# A Notation
## Problem Setting
- Data $bold(x)$ is distributed like i.i.d Rademacher in all entries except the third entry, and the target function is $y(x) = - x_1x_2$, the XOR on the first two entries
- The third entry is like a planted answer, with probability $1-lambda$ it is the XOR of the first two entries, and with probability $lambda$ it's the negation
## Weight Decomposition
- We decompose $bold(w) = bold(w)_"sig" + bold(w)_"opp" + bold(w)_"sp" + bold(w)_perp$ where sig is the projection onto the signal direction, which depends on the sign of $a$, $bw_"opp"$ points in the "other" direction (discussed below), $bold(w)_"sp"$ is the projection onto the third coordinate, and $bold(w)_"perp"$ is everything else
	- The sign of $a$ determines the sign of a particular neuron's contribution, and therefore whether we want to align with $plus.minus mu_1$ (the choices of $bold(z)$ that are $1$ under XOR) vs $plus.minus mu_2$ (the $-1$ inputs) so $bw _"opp"$ is just the orthogonal direction to the signal
- We decompose $bx = bold(z) + bold(s) + bxi$, which are the projections onto the first two coordinates (so $y(bx) = y(bold(z))$), the projection onto the third coordinate, and the remaining $d-3$ coordinates respectively
## Neural Network and Training
- The neural network output $f_rho (x)$ is the average of the neuron outputs, so
	$$
	f_rho (bx) = 1/p sum_(a_j, w_j) a_j sigma(bw^top bx) = E_((a_j, bw_j) ~ rho) [a_j sigma( bw^top bx)]
	$$
- The loss, as a function of $bx$ denoted $ell_rho (bx)$, is twice the negative log of the sigmoid of the margin, where we let $gamma(bx) := f_rho (x) y(x)$ denote the margin, $psi(gamma) = 1/(1 + exp(- gamma))$ denote the sigmoid, and so $ell_rho (x) = - 2 log (psi(gamma(x))) = h(gamma(x))$ where we use $h$ to denote the outer functions, so $h(gamma) := -2 log (psi(gamma))$ is the sigmoid composed with twice the negative log.
- We let $ell_0 (x)$ denote the first order approximation of $ell_rho$ around $0$ with respect to $f_rho (x)$, observe that because $h$ is scaled by $2$ we have $h'(gamma) = (-2 e^(- gamma))/(1 + e^(- gamma))$ so $h'(0) = -1$, giving
	$$
	ell_0(f_rho (bx)) = ell_rho (0) + h'(0) gamma(bx) = -2 log 1/2 - y(bx) f_rho (bx)
	$$
- $L_rho$ and $L_0$ are the corresponding population losses, so the expectation over $bx$ drawn from the described distribution
- We write $ell_rho ^((1)) (bx) = h'(gamma(bx))$ for the first derivative of the loss with respect to the margin, and $ell_0 ^((1)) (bx)$ as the corresponding value for $ell_0$ which is $-1$. So I believe we're writing it as a function of $bx$ but really are considering the change in the loss wrt the margin, later this will be useful in bounding $gradient (L_rho - L_0)$.
- $gradient_bw L$ and $partial_a L$ are scaled by $p$ so that we get invariance over the width of the neural network (the $p$ cancels with the $1/p$ in the averaging over neurons)

# B $L_0$ Analysis
We want to characterize the gradients under the $L_0$ approximation of the loss to derive recurrences on each part of $bw$. We will ultimately show that the $L_0$ approximation is fine for small networks (small absolute value/norm of $(a, bw)$), and that both $wsig, wsp$ grow according to a geometric recurrence, but that $wsp$ has a headstart like $sqrt(d)$.

## B.1 $gradient L_0$ Computation
> [!lemma] B.1 $L_0$ gradient along signal and opposite directions
> For any neuron $(a,bw)$ we have
> $$
> -wsig^top grad_bw L_0 = sqrt(2)/4 abs(a) norm(wsig) Pr_bxi [abs(bw^top bold(e)_3 + bw^top bxi) <= sqrt(2) norm(wsig)]
> $$
> $$
> -wopp^top grad_bw L_0 = sqrt(2)/4 abs(a) norm(wopp) Pr_bxi [abs(bw^top bold(e)_3 + bw^top bxi) <= sqrt(2) norm(wopp)]
> $$

^b1

→ [Proof](Proofs/B.1%20L0%20gradient%20along%20signal.md)

> [!lemma] B.2 $L_0$ gradient along spurious direction
> For any neuron $(a,bw)$ we have
> $$
> -wsp^top grad_bw L_0 = a w_"sp" (1/2 + epsilon_bw/4 - lambda)
> $$
> where
> $$
> A = min({plus.minus bw^top bold(mu)_1, plus.minus bw^top bold(mu)_2}), " "
>   B = min({plus.minus bw^top bold(mu)_1, plus.minus bw^top bold(mu)_2} without A) \
>   epsilon_bw = cases(
>   Pr_bxi [bw^top bxi - wsps in [A,B] ] - Pr_bxi [bw^top bxi + wsps in [A,B] ] "if" sgn(w_1) = sgn(w_2),
>   Pr_bxi [bw^top bxi + wsps in [A,B]] - Pr_bxi [bw^top bxi - wsps in [A,B] ] "if" sgn(w_1) != sgn(w_2))
> $$

^b2

→ [Proof](Proofs/B.2%20L0%20gradient%20along%20spurious.md)

> [!lemma] B.4 $L_0$ gradient along perp
> For any neuron $(a,bw)$ we have
> $$
> -bw_perp^top grad_bw L_0 = 1/8 abs(a) EE[abs(bw^top bxi) ( \
>   bb(1) [abs(bw^top bxi) >= abs(sqrt(2) norm(wsig) + wsps) ] +  bb(1) [abs(bw^top bxi) >= abs(sqrt(2) norm(wsig) - wsps) ] \
>   bb(1) [abs(bw^top bxi) >= abs(sqrt(2) norm(wopp) + wsps) ] + bb(1) [abs(bw^top bxi) >= abs(sqrt(2) norm(wopp) - wsps) ]
>   )]
> $$

^b4

→ [Proof](Proofs/B.4%20L0%20gradient%20along%20perp.md)

> [!lemma] B.5 $L_0$ gradient for a coordiante of perp
> For any neuron $(a,bw)$ we have
> $$
> -w_i partial_(w_i) L_0 &= 1/8 abs(a) abs(w_i) \ [
>   &Pr_bxi [abs(w_i) >= abs(sqrt(2) norm(wsig) + w_"sp" + bw^top xinoi)] + Pr_bxi [abs(w_i) >= abs(sqrt(2) norm(wsig) - w_"sp" + bw^top xinoi)] \
>   -&Pr_bxi [abs(w_i) >= abs(sqrt(2) norm(wopp) + w_"opp" + bw^top xinoi)] - Pr_bxi [abs(w_i) >= abs(sqrt(2) norm(wopp) - w_"opp" + bw^top xinoi)]
>   ]
> $$

^b5

→ [Proof](Proofs/B.5%20L0%20gradient%20along%20a%20perp%20coordinate.md)

## B.2 $epsilon_bw$ Asymmetry Term Bound
> [!lemma] B.7 $epsilon_bw$ is exponentially small
> For $epsilon_bw$ defined as in [Lemma](#^b2) we have
> $$
> abs(epsilon_bw) leqa norm(bw_(1:2))/norm(bw_perp) exp(frac(sqrt(2) norm(bw_(1:2)) norm(wsp) - wsps^2, norm(bw_perp)_2^2)) + frac(norm(bw_perp)_3^3, norm(bw_perp)_2^3)
> $$

^b7

→ [Proof](Proofs/B.7%20Epsilon%20is%20small.md)

# C $L_rho$ Analysis
## C.1 $gradient L_rho - gradient L_0$ Error Analysis
- First shows a bound on the difference in the gradients between $L_0$ and $L_rho$, coordinate by coordinate

## C.2 $gradient L_rho$ Computation
- Then we reuse results from section $B$ to characterize the gradients in {$wsig$, $wopp$, $wsp$, $bw_perp$} under $L_rho$, but with extra steps to handle the margin term that results from us considering $ell_rho^((1))$ rather than $ell_0^((1)) = -1$. All lemmas rely on a certain assumption on the magnitude of the margin, and condition on a high probability event $cal(E)_"test"$, generally bounding via a Lipschitzness argument.

> [!todo] Need to look into these and see why the dependence on $max(abs(w_"sp"))$ is natural

> [!todo] Also now that I've read the proof for the equal and opposite margins condition see why the average margin dependence shows up here

# D Phase I Induction
## D.1 Technical Preliminaries
- The first lemma shows that if if we get alignment between the signs of $a, wsp$ then and $wsp$ is sufficiently large compared to the other components then the network predicts based on $wsp$
	- $a$ determines sign, so if it matches $wsp$ then $wsp$ determines sign, so we get no contribution when its sign differs from $x_3$ and otherwise we get a contribution matching $x_3$

* Some things to keep in mind:
	* $wsp$ has an exact characterization of the increment whereas the others are just asymptotic upper bounds
	* Because $bw_perp$ is large in norm compared to its increments over all of phase I the reverse triangle inequality shows an asymptotic lower bound not just an upper bound
> [!todo] Need to go review the Phase I Inductive steps and recall why this $epsilon_bw$ thing only shows up for the spurious component and why this allows us to get an exact characterization, I think it's just that this asymmetry is small

> [!definition] D.2 Scalings
> 1. $log log (d) d^(-C) << eta << log^(-3) (d)$
> 	- upper bound helps control $a$ as being close to $norm(bw)$, and lower keeps $t leqa d^C$
> 2. $t leqa log log (d) eta^(-1)$
> 	- length of phase I
> 3. $log (d) << p$ helps to ensure $cal(E)_"init"$
> 	- so norm of $bw_perp$ controlled, and balance of $S^+, S^-$
> 4. $theta << log^(-5C) (d)$
> 	- limited by the analysis of the per-step change in $bw_perp$
> 5. $m >> d log ^(7C) (d)$
> 	- Limited by Hoeffding's

^d2

> [!definition] D.4 Inductive Hypothesis
> 1. $wsp^((t)) - wsp^((t-1)) = eta (1 plus.minus o(log^(-2)(d))) dot (1/2 - lambda) dot "sgn"(a^((0)))(abs(wsp^((t-1))) + theta)$
> 2. $norm(wsig^((t)) - wsig^((t-1))) leqa eta (norm(wsig)^((t-1)) + theta log^(C) (d) d^(-1 slash 2))$
> 3. $norm(wopp^((t)) - wopp^((t-1))) leqa eta (norm(wopp)^((t-1)) + theta log^(C) (d) d^(-1 slash 2))$
> 4. $norm(bw_perp^((t)) - bw_perp^((t-1))) leqa eta theta log^(-2 C) (d)$
> 5. $norm(bw_perp^((t)) - bw_perp^((t-1)))_infinity leqa eta theta log^(3 C) (d) d^(-1 slash 2)$
> 6. $abs(a^((t))) <= norm(w^((t)))$

^d4

> [!lemma] D.6 The $w$ part
> $$
> norm(wsp^((t))) leqa theta log^C (d)
> $$
> ^phase1-asymp-norm-wsig
> $$
> norm(wsig), norm(wopp) leqa theta log^(2 C) (d) d^(-1 slash 2)
> $$
> ^phase1-asymp-norm-wsigopp
> $$
> norm(bw_perp^((t))) asymp theta, "and" norm(bw_perp^((t)) - bw_perp^((0))) leqa theta log^(-C) (d)
> $$
> ^phase1-asymp-2norm-wperp
> $$
> norm(bw_perp^((t)))_infinity leqa theta log^(4 C) (d) d^(-1 slash 2)
> $$
> ^phase1-asymp-infnorm-wperp
> $$
> norm(w^((t))) asymp norm(wsp^((t))) + norm(bw_perp^((t))) leqa theta log^(C) (d)
> $$
> ^phase1-asymp-norm-w

^d6

> [!lemma] D.7 The $a$ part
> $$
> norm(a^((t))) leqa (1 plus.minus o(log^(-2)(d))) dot norm(bw^((t))) leqa (1 plus.minus o(log^(-2)(d))) dot (norm(wsp^((t))) + norm(bw_perp^((t)))) leqa theta log^(C) (d)
> $$
> ^phase1-asymp-norm-a
> $$
> sgn(a^((t))) = sgn(a^((0)))
> $$
> ^phase1-asymp-sign-a-alignment
> $$
> EE _((a, bw) tilde rho) norm(a^((t)) bw^((t))) leqa theta^2 log ^(2 C) (d)
> $$

^d7

## D.3 Phase I Inductive Step
> [!lemma] D.10 $wsps$ inductive step
> $$
> wsps^((t+1)) - wsps^((t)) = eta (1 plus.minus o(log^(-2)(d))) (1/2 - lambda) sgn(a^((0))) (abs(wsps) + theta)
> $$

^d10

→ [Proof](Proofs/D.10%20Spurious%20inductive%20step.md)

# E Phase II Induction
## E.1 Technical Preliminaries
E.8 - "Equal and opposite" margin condition
* You show that the neural network output has absolute value close to $overline(gamma) = 1/p sum w_"sp"^2$
	* Sign is determined by whether the neuron is in majority/minority class
* Roughly speaking $w_"sp"$ is large enough in Phase II scalings so the other terms are negligible
* You consider $gamma_+, gamma_-$ which are the unnormalized contributions from $S^+, S^-$ and Hoeffding's with $p >> log^5 (d)$ gives multiplicative error $sqrt((log d) slash p)$
	* In particular $sgn(a)$ is Rademacher so conditioning on the $w_"sp"$ for all $p$ neurons lets you apply Hoeffding's
> [!todo] Isn't this just with high probability though? The paper seems to read like this is with probability one so I'd guess there's some implicit union bound type thing going on
* Then after appealing to Phase II scalings to bound a certain residual term you consider cases on $x_1,x_2,x_3$ and get the desired result, with minority $bold(x)$ picking up a sign flip
* The reason the scaling is like $w_"sp"^2$ is because $abs(a)$ is like $w_"sp"$
# F Technical Lemmas
## F.1 High-probability Events
* Definitions of the train and test events
	* The *initialization event* for a neuron controls its norms relative to its initialization $theta$
		* $norm(w_perp) asymp theta$, $norm(w_perp)_3^3 leqa theta^3 d^(-1 slash 2)$, $norm(w_perp)_infinity leqa theta log^(1 slash 2) (d) d^(-1 slash 2)$ 
			* So $w_perp$ is a constant fraction of the norm, the three norm is less than $theta^3$ asymptotically, and no component can be more than its norm in an even distribution by more than $log^(1 slash 2) (d)$ 
	* The *concentration event* for a minibatch says that our empirical loss isn't too far off from the $L_rho$ loss both wrt $w$ and $a$
		* The bound for $w$ is like the squared diff is $<= log^2 (d) slash m$, for $a$ we get $d log^2 (d) / m norm(w)^2$ 
		* These both follow by Hoeffding's and rely on this online SGD independence
		* The $a$ bound has a dependence on $norm(w)$ because the $ell_rho$ gradient is bounded wrt $norm(w)$ to apply Hoeffding's
	* The *train event* is just the intersection of the initialization events over all neurons, and the concentration events over all time steps
		* Both of these involve a union bound of polynomially many terms which is fine because bad events decay exponentially
	* The *concentration* even for a neuron on a test point $x tilde P_d (lambda)$ says that $abs(w_perp^top x) < C norm(w_perp) log^(1 slash 2) (d)$ for $x$ and any sign flip of its entries (stated for $i > 3$ but you can flip $0,1,2$ also since they vanish)
		* So we're just saying that $w_perp$ doesn't align with $x$ such that the inner product contributes like $d norm(w_perp)$ 
		* This is used in Phase I to establish that $wsp$ determines sign even if $norm(wsp)$ is only larger than $norm(bw_perp)$ by like $log d$ 
## F.2 From Booleans to Gaussians
* The main results are that $w_perp x$ behaves roughly Gaussian like (although the appendix uses a generic vector v), with a refined Barry-Esseen following under stronger assumptions to get error like $1 slash sqrt(d)$ instead of a ratio of norms
* Then an approximate parallelism condition is shown for the gradient of the $L_0$ loss with respect to $w_perp$, so most of the norm of the gradient lives along the direction of $w_perp$ which we consider in section A
	* This is crucial for the $w_perp$ inductive step which must bound the component of the $L_0$ gradient norm in the orthogonal subspace (the others are one dimensional so this doesn't come up)
## F.3 Simultaneous Training of Two-Layer ReLU Neural Networks
