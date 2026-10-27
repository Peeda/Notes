---
tags: [spurious-xor]
---
![](../Proof%20Overview.md#^b5)

*Proof of [Lemma](../Proof%20Overview.md#^b5).* This proof can be done in the same way as [Lemma](../Proof%20Overview.md#^b4) just applied coordinate wise, although here I will do a slightly different approach that expands over $x_i$, using that $x_i$ is Rademacher for $i > 3$, rather than appealing to symmetry which changes the first few steps. Pretty sure that this works but it's late right now so

> [!todo] check this

From definition we have that
$$
-w_i partial_(w_i) L_0 = EE_x [a y(bx) sigma'(bw^top bx) w_i x_i] \
  = 1/2 a EE_x [y(z)(sigma'(bw^top xnoi + w_i)w_i - sigma'(bw^top xnoi - w_i)w_i)] \
  = 1/2 a w_i EE_x [y(z) (sigma'(bw^top xnoi + w_i) - sigma'(bw^top xnoi - w_i))]
$$
and we can reuse the same difference of indicators analysis to get that this equals
$$
= 1/2 a w_i EE_x [y(z) bb(1)[abs(bw^top xnoi) <= abs(w_i)] sgn(w_i)] \
  = 1/2 a abs(w_i) EE_x [y(z) bb(1)[abs(w_i) >= abs(bw^top xnoi)]] \
  = 1/2 a abs(w_i) EE_x [y(z) bb(1)[abs(w_i) >= abs(bw^top bz + bw^top bs + bw^top xinoi)]]
$$
as in [Lemma](../Proof%20Overview.md#^b4) we expand over the distribution $(bz,bxi)$, using the structure of the absolute value being taken on the right hand side to group pairs of terms with probability $1/4 (1-lambda)$ and $1/4 lambda$ that take matching values under absolute value to get
$$
= 1/2 a abs(w_i) EE_bxi \ [
  & bb(1)[abs(w_i) >= abs(bw^top bold(mu)_1 + wsp e3 + bw^top xinoi)] &&+ bb(1)[abs(w_i) >= abs(bw^top bold(mu)_1 - wsp e3 + bw^top xinoi)] \
  - &bb(1)[abs(w_i) >= abs(bw^top bold(mu)_2 + wsp e3 + bw^top xinoi)] &&- bb(1)[abs(w_i) >= abs(bw^top bold(mu)_2 - wsp e3 + bw^top xinoi)] ]
$$
and as in [Lemma](../Proof%20Overview.md#^b4) we note that when $a > 0$ we take $wsig$ to align with $bold(mu)_1$, and for $a < 0$ it's with $bold(mu)_2$ and so we can use that the above terms swap $bold(mu)_1, bold(mu)_2$'s roles up to signs to write this as
$$
= 1/2 abs(a) abs(w_i) EE_bxi \ [
  & bb(1)[abs(w_i) >= abs(sqrt(2) norm(wsig) + wsp e3 + bw^top xinoi)] &&+ bb(1)[abs(w_i) >= abs(sqrt(2) norm(wsig) - wsp e3 + bw^top xinoi)] \
  - &bb(1)[abs(w_i) >= abs(sqrt(2) norm(wopp) + wsp e3 + bw^top xinoi)] &&- bb(1)[abs(w_i) >= abs(sqrt(2) norm(wopp) - wsp e3 + bw^top xinoi)] ]
$$
with the $a$ being in absolute values handling the fact that for $a < 0$ we pick up a negative sign by swapping the roles of $bold(mu)_1, bold(mu)_2$. The result then follows by writing the expectation of an indicator as a probability.

∎
