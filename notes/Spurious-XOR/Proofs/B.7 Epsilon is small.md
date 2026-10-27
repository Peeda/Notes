---
tags: [spurious-xor]
---
![](../Proof%20Overview.md#^b7)

*Proof of [Lemma](../Proof%20Overview.md#^b7).* Note that for bounding the absolute value, by the definition of $epsilon_bw$, we can take the first case without loss of generality such that $epsilon_bw = Pr_bxi [bw^top bxi - wsps in [A,B]] - Pr_bxi [bw^top bxi + wsps in [A,B]]$ as the other case has the same absolute value.

From here the high level appraoch is use a form of Berry-Esseen given in

> [!todo] appendix

to rewrite the above as a difference of Gaussian cdfs and apply a few identities to get our desired bound. Writing $phi(u)$ for the pdf of a Gaussian with mean zero and variance $norm(bw_perp)^2$, Berry-Esseen gives that
$$
epsilon_bw leqa integral_(A + wsps)^(B + wsps) phi(u) d u - integral_(A - wsps)^(B - wsps) phi(u) d u + frac(norm(bw_perp)_3^3, norm(bw_perp)^2^3)
  \ = integral_(A)^(B) (phi(u + wsps) - phi(u - wsps)) d u + frac(norm(bw_perp)_3^3, norm(bw_perp)_2^3)
$$
where the definition of the Gaussian pdf gives that the integral term is
$$
&integral_A^B 1/(norm(bw_perp) sqrt(2pi)) (e^(-(u + wsps)^2 slash 2 norm(bw_perp)^2) - e^(-(u - wsps)^2 slash 2 norm(bw_perp)^2)) d u  \
  &= integral_A^B 1/(norm(bw_perp) sqrt(2pi)) (e^((-u^2 - 2 u wsps - wsps^2) slash 2 norm(bw_perp)^2) - e^((-u^2 + 2 u wsps - wsps^2) slash 2 norm(bw_perp)^2)) d u  \
  &= integral_A^B 1/(norm(bw_perp) sqrt(2pi)) e^((-u^2 - wsps^2) slash 2 norm(bw_perp)^2) (e^(-2 u wsps slash 2 norm(bw_perp)^2) - e^(2 u wsps slash 2 norm(bw_perp)^2)) d u  \
  &= integral_A^B (1/(norm(bw_perp) sqrt(2pi)) e^(-wsps^2 slash 2 norm(bw_perp)^2)) e^(-u^2 slash 2 norm(bw_perp)^2) (e^(-2 u wsps slash 2 norm(bw_perp)^2) - e^(2 u wsps slash 2 norm(bw_perp)^2)) d u  \
  &= phi(wsps) integral_A^B e^(-u^2 slash 2 norm(bw_perp)^2) (e^(-u wsps slash norm(bw_perp)^2) - e^(u wsps slash norm(bw_perp)^2)) d u  \
  &= -2 phi(wsps) integral_A^B e^(-u^2 slash 2 norm(bw_perp)^2) sinh (u wsps slash norm(bw_perp)^2) d u  \
$$
and so we have
$$
abs(epsilon_bw) leqa phi(wsps) integral_A^B exp(-u^2 slash 2 norm(bw_perp)^2) abs(sinh(u wsps slash norm(bw_perp)^2)) d u + norm(bw_perp)_3^3/norm(bw_perp)_2^3
$$
from here we use that $abs(sinh x) <= cosh x <= exp (abs(x))$ and take a uniform upper bound to get
$$
&<= phi (wsps) (B - A) max_(u in [A,B]) underbrace(exp(-u^2 slash 2 norm(bw_perp)^2), <= 1) underbrace(exp(abs(frac(u wsps, norm(bw_perp)^2))),  "maxmized at" u=D=abs(A)) + norm(bw_perp)_3^3/norm(bw_perp)_2^3  \
  &<= phi(wsps) (B - A) exp(abs(A) wsps slash norm(bw_perp)^2) + norm(bw_perp)_3^3/norm(bw_perp)_2^3 \
  &= 1/(sqrt(2 pi) norm(bw_perp)) exp(-wsps^2 slash 2 norm(bw_perp)^2) (B - A) exp(abs(A) wsps slash norm(bw_perp)^2) + norm(bw_perp)_3^3/norm(bw_perp)_2^3 \
$$
from here we use that $B-A <= abs(A)$ as $A,B,C,D$ are the four ways we can assign signs to $w_1, w_2$ with $abs(A)=D$ being the maximizer, where $B-A in {A,B,C,D}$ by linearity. Furthermore $abs(A) <= sqrt(2) norm(bw_(1:2))$ by Cauchy-Schwarz so we have
$$
leqa (B-A)/norm(bw_perp) exp(frac(2 abs(A) wsps - wsps^2, 2 norm(bw_perp)_2^2)) + norm(bw_perp)_3^3/norm(bw_perp)_2^3  \
  leqa norm(bw_(1:2))/norm(bw_perp) exp(frac(sqrt(2) norm(bw_(1:2)) norm(wsp) - wsps^2, norm(bw_perp)_2^2)) + norm(bw_perp)_3^3/norm(bw_perp)_2^3
$$
as claimed.

∎
