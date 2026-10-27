---
tags: [spurious-xor]
---
![](../Proof%20Overview.md#^d10)

*Proof of [Lemma](../Proof%20Overview.md#^d10).* We want want to show that if the IH holds for $k <= t$ and we have $cal(E)_"train"$ which is needed for the lemmas that establish asymptotics, then we have
$$
wsps^((t+1)) - wsps^((t)) = eta (1 plus.minus o(log^(-2)(d))) (1/2 - lambda) sgn(a^((0))) (abs(wsps) + theta)
$$
and I will not use the superscript notation to denote the iteration as most of the time it's $t$ or otherwise clear. It's important to note we have $sgn(a^((0)))$ in the statement though.

We first consider the definition of our SGD update; we have that
$$
wsps^((t+1)) - wsps^((t)) = - eta partial_wsps hat(L)_rho = - eta (partial_wsps L_0 + partial_wsps (hat(L)_rho - L_0)) = - eta/wsps (wsp^top grad_bw L_0 + wsp^top grad_bw (hat(L)_rho - L_0))
$$
and in [Lemma](../Proof%20Overview.md#^b2) we established that
$$
-wsp^top grad_bw L_0 = a wsps (1/2 + epsilon_bw/4 - lambda)
$$
where we will show that from [Lemma](../Proof%20Overview.md#^b7) it follows that $abs(epsilon_bw) leqa log^(-2)(d)$. From there we use [Equation](../Proof%20Overview.md#^phase1-asymp-norm-a) and [Equation](../Proof%20Overview.md#^phase1-asymp-2norm-wperp) in the Phase I asymptotics to establish that $abs(a^((t))) = (1 + o(log^(-2)(d))) (abs(wsps) + theta)$ implying
$$
-wsp^top grad_bw L_0 = (1 plus.minus o(log^(-2)(d)))(1/2 - lambda) sgn(a^((t))) sgn(wsps) abs(wsps) (abs(wsps) + theta)
$$
we will then show that the $wsp^top grad_bw (hat(L)_rho - L_0)$ term is asymptotically dominated such that
$$
wsps^((t+1)) - wsps^((t)) = - eta / wsps (-(1 plus.minus o(log^(-2)(d)))(1/2 - lambda) sgn(a^((t))) sgn(wsps) abs(wsps) (abs(wsps) + theta))
$$
$$
= eta (1 plus.minus o(log^(-2)(d))) (1/2 - lambda) sgn(a^((t))) (abs(wsps) + theta)
$$
$$
= eta (1 plus.minus o(log^(-2)(d))) (1/2 - lambda) sgn(a^((0))) (abs(wsps) + theta)
$$
Where we used [Equation](../Proof%20Overview.md#^phase1-asymp-sign-a-alignment) in the last step. Okay so then it just remains to show the claimed asymptotic bound on $abs(epsilon_bw)$ and to establish that the $wsp^top grad_bw (hat(L)_rho - L_0)$ is asymptotically small. First considering $abs(epsilon_bw)$ recall that by [Lemma](../Proof%20Overview.md#^b7) we have
$$
abs(epsilon_bw) leqa norm(bw_(1:2))/norm(bw_perp) exp((- norm(wsp)^2 + 2 sqrt(2) norm(bw_(1:2)) norm(wsp))/(2 norm(bw_perp)_2^2)) + norm(bw_perp)_3^3 / norm(bw_perp)^3  \
  <=
  norm(bw_(1:2))/norm(bw_perp) exp((2 sqrt(2) norm(bw_(1:2)) norm(wsp))/(2 norm(bw_perp)_2^2)) + norm(bw_perp)_infinity / norm(bw_perp)
$$
and we plug in our scalings
$$
norm(bw_(1:2)) leqa (theta log^(2 C)(d)) slash sqrt(d) \
  norm(bw_perp)_2 asymp theta \
  norm(wsp) leqa theta log^(C) (d) \
  norm(bw_perp)_infinity leqa theta log ^(4 C) (d) slash sqrt(d) \
$$
to get that the above is
$$
leqa (theta log^(2 C) (d) slash sqrt(d))/theta exp((C theta log^(2C) (d) dot theta log^(C) (d))/(theta^2 sqrt(d))) + (theta log^(4 C) (d) )/(theta sqrt(d))  \
  = log^(2C) slash sqrt(d) dot  exp(C log^(3 C) (d) slash sqrt(d)) + log^(4 C) (d) slash sqrt(d)
$$
and use that $1 + u leqa exp(u)$ (yes this isn't meant to be $1+x <= exp(x)$) to get
$$
leqa 1/sqrt(d) (log^(2C) (1 + log^(3C)(d)) + log^(4 C)(d))  leqa log^(5 C) (d) slash sqrt(d) leqa log^(2 C) (d)
$$
as desired. Now considering $-wsp^top grad_bw (hat(L)_rho - L_0)$ observe that

> [!todo] type up this lemma at some point and ref

in the $i=3$ case states
$$
abs(partial_wsp (hat(L)_rho - L_0)) leqa theta^3 log^(4 C) (d) + theta log^(-2)(d) slash sqrt(d)
$$
and so
$$
abs(wsp^top grad_bw (hat(L)_rho - L_0)) &<= norm(wsp) dot norm(bold(e)_3^top grad_bw (hat(L)_rho - L_0)) \
  &= abs(wsps) dot norm(partial_wsp (hat(L)_rho - L_0))\
  &leqa abs(wsps) (theta^3 log^(4C) (d)  +theta log^(-2)(d) slash sqrt(d))
$$
our scalings assume that $theta << log^(-5C) (d)$ so this is
$$
leqa abs(wsps) (theta log^(-6C)(d) + theta log^(-2)(d) slash sqrt(d)) leqa abs(wsps) theta leqa wsp^top grad_bw L_0
$$
as claimed.

∎
