---
tags: [spurious-xor]
---
![](../Proof%20Overview.md#^b1)

*Proof of [Lemma](../Proof%20Overview.md#^b1).* Note that we have by definition of $L_0$ as the first order approximation and a previous calc that
$$
-wsig^top grad_w L_0 &= -wsig^top EE[p partial/(partial bw) -y(bx) f_rho (bx)] \
  &= wsig^top EE[ y(x) p partial/(partial bw) 1/p sum_j a_j sigma(bw^top bx)  ] \
  &= wsig^top EE[y(x) a sigma' (bw^top bx) bx]
$$
and by recognizing that $wsig^top$ is orthogonal to $bx - bz$ we can split the above by using $bx = bz + bold(s) + bxi$ so that the above equals $EE[y(bz) a sigma'(bw^top bx) wsig^top bz]$ also using that $y$ is determined by $bz$. So intuitively this part gradient only depends on $bx$ in units $3,...,d$ via this inner sigmoid, as everything else is projected into $mu_"sig"$'s span. From here we use iterated expectations to condition on whether $wsig || bz$, noting that the above is zero when the two are orthogonal to get
$$
&= 1/2 limits(EE)_(x,z \ wsig|| bz) [y(z) a sigma'(bw^top bx) wsig^top bz] \
  &= 1/2 limits(EE)_(x,z \ wsig|| bz) [y(z) a sigma'(wsig^top bz + bw^top bold(s) + bw^top bxi) wsig^top bz]
$$
letting $bz_0$ denote one of the two values of $bz$ such that we have $wsig || z_0$ (so if $a > 0$ then $mu_1$ else $mu_2$) we know that $(bz,bs)$ are independent and $bz$ is $plus.minus bz_0$ with probability $1 slash 2$ each, and that $bs$ is $smaj$ with prob $1-lambda$ and $smin$ with prob $lambda$. Recall that $smaj$ is just aligned with the sign of $a$ and so we have $bs=smaj$ with prob $1-lambda$ because $s=smaj$ if and only if $s$ and $a$ share signs, which is the same as $s$ being one for $z= plus.minus mu_1$ and $-1$ otherwise.

> [!todo] Okay I should review this at some point since walking back how things are defined relative to sign of $a$ seems difficult to me, there's probably an easier way to see it, any way this allows us to expand the above. This is probably the same as just thinking of $smaj$ as the xor of $bz_0$ but that's not the definition itself.

Noting that we're just varying the signs of $bz, bs$ let's introduce the shorthand $sigma'(plus.minus, plus.minus)$ to mean $sigma'(wsig^top (plus.minus bz) + bw^top (plus.minus bs) + bw^top bxi)$ so the above equals
$$
= 1/2 a(\
  (1/2 - lambda/2) dot &EE_bxi [y(bz_0) sigma'(+, +) wsig^top bz_0] \
  + lambda/2 dot &EE_bxi [y(bz_0) sigma'(+, -) wsig^top bz_0] \
  + (1/2 - lambda/2) dot &EE_bxi [y(-bz_0) sigma'(-, +) wsig^top (-bz_0)] \
  + lambda/2 dot &EE_bxi [y(-bz_0) sigma'(-,-) wsig^top (-bz_0)] \
  )
$$
and we  can factor our the $1 slash 2$, then observe that $y(bz_0) = y(-bz_0)$ with $a y(bz_0) = a y(-bz_0) = abs(a)$ by the fact $bz_0$'s xor aligns with the sign of $a$ to get
$$
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
$$
from here we'll group terms according to the sign of $smaj$ (this will let us apply an identity about differences of certain indicators) to get
$$
= 1/4 abs(a) wsig^top bz_0 ( \
  &EE_bxi [sigma'(+,+) - sigma'(-, +)] \
  + lambda &EE_bxi [sigma'(-,+) - sigma'(+, +)] \
  + lambda &EE_bxi [sigma'(+,-) - sigma'(-, -)] )
$$
unrolling definitions now since the manipulations are done and recognizing $sigma'(x) = bb(1) [x >= 0]$, the above is
$$
= 1/4 abs(a) wsig^top bz_0 ( \
  &EE_bxi [bb(1)[wsig^top bz + bw^top bs + bw^top bxi] - bb(1)[wsig^top (-bz) + bw^top bs + bw^top bxi]] \
  + lambda &EE_bxi [bb(1)[wsig^top (-bz) + bw^top bs + bw^top bxi] - bb(1)[wsig^top bz + bw^top bs + bw^top bxi]] \
  + lambda &EE_bxi [bb(1)[wsig^top bz + bw^top (-bs) + bw^top bxi] - bb(1)[wsig^top (-bz) + bw^top (-bs) + bw^top bxi]] )
$$
From here consider that for $a,b,c in RR$ we have
$$
bb(1)[a+b+c >= 0] - bb(1)[-1+b+c >= 0] = bb(1)[b+c >= -a] - bb(1)[b+c>=a]
$$
where the above is $1$ if and only if the first indicator is true and the second false, and $-1$ if the first false and the second true, and $0$ otherwise. Therefore the above is
$$
= cases(1 &"when" a <= b + c <= -a, -1 &"when" -a <= b + c <= a, 0 &"else")
$$
or equivalently, this is nonzero when $abs(b+c) <= abs(a)$ with the sign being the opposite of $a$'s sign as the sign of $a$ determines whether which case is valid. This type of argument works for all three differences of indicators and actually lets us group the first two differences of indicators since they share $bw^top bs + bw^top bxi$ just up to a sign flip so the above equals
$$
= 1/4 abs(a) wsig^top bz_0 ( \
  (1-lambda) &Pr_bxi [abs(bw^top smaj + bw^top bxi) <= abs(wsig^top bz_0)]sgn(wsig^top bz_0)  \
  + lambda &Pr_bxi [abs(-bw^top smaj + bw^top bxi) <= abs(wsig^top bz_0)]sgn(wsig^top bz_0)
  ).
$$
We now observe that $wsig^top bz_0 sgn(wsig^top bz_0) = abs(wsig^top bz_0) = norm(wsig^top) norm(z_0) = sqrt(2) norm(wsig^top)$ with the last two steps following from the fact $wsig || bz_0$ and so Cauchy-Schwarz is tight here, with $norm(bz_0) = sqrt(2)$ following from definition of $bz_0$. We use this to factor out $sgn(wsig^top bz_0)$ from both terms and also to rewrite the $abs(wsig^top bz_0)$ term inside each probability:
$$
= sqrt(2)/4 abs(a) norm(wsig)( \
  (1-lambda) &Pr_bxi [abs(bw^top smaj + bw^top bxi) <= sqrt(2) norm(wsig)] \
  + lambda &Pr_bxi [abs(-bw^top smaj + bw^top bxi) <= sqrt(2) norm(wsig)]
  ).
$$
and we conclude the proof by noting that $bxi$ is symmetric, so in particular we can flip $bxi$ with $-bxi$ while preserving probabilities; because of the absolute value this is the same as flipping the sign of $smaj$ so
$$
Pr_bxi [abs(-bw^top smaj + bw^top bxi) <= sqrt(2) norm(wsig)]=
  Pr_bxi [abs(bw^top smaj + bw^top bxi) <= sqrt(2) norm(wsig)]= \
  Pr_bxi [abs(bw^top bold(e)_3 + bw^top bxi) <= sqrt(2) norm(wsig)]
$$
which allows us to conclude the above equals
$$
= sqrt(2)/4 abs(a) norm(wsig) Pr_bxi [abs(bw^top bold(e)_3 + bw^top bxi) <= sqrt(2) norm(wsig)]
$$
as desired.

∎
