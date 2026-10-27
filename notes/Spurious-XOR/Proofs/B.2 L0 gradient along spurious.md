---
tags: [spurious-xor]
---
![](../Proof%20Overview.md#^b2)

*Proof of [Lemma](../Proof%20Overview.md#^b2).* Begin as before using that $grad_bw L_0 = EE_x [-y(z) a sigma'(bw^top bx) bx]$ to get
$$
-wsp^top grad_bw L_0 = EE_bx [y(bz) a sigma'(bw^top bx) wsp^top bs]
$$
and then expand over $bs$ using that $bs = y(bz)$ with probability $1-lambda$, with $bx, bxi$ independent of $bs$ to get
$$
= a((1 - lambda) &EE_(bz, bxi) [y(bz) sigma'(bw^top bz + bw^top y(bz) e3 + bw^top bxi) wsp^top y(bz) e3 ] \
  + lambda &EE_(bz, bxi) [y(bz) sigma'(bw^top bz - bw^top y(bz) e3 + bw^top bxi) wsp^top (-y(bz) e3)]) )
$$
and we factor out $y(bz)^2 = 1$, rewriting expectations of indicators as probabilities (using again that the derivative of the relu is an indicator) to get
$$
= a w_"sp" (
  (1-lambda) &Pr_(bz, bxi) [bw^top bz + bw^top bxi >= -y(bz) w_"sp"] \
  + lambda &Pr_(bz, bxi) [bw^top bz + bw^top bxi >= y(bz) w_"sp"]  )
$$
from here observe that by symmetry of $bz$ and the fact that $y(bz) = y(-bz)$ followed by using the symmetry of $bxi$ we have
$$
&Pr_(bz, bxi) [bw^top bz + bw^top bxi >= -y(bz) w_"sp"] + Pr_(bz, bxi) [bw^top bz + bw^top bxi >= y(bz) w_"sp"] \
  = &Pr_(bz, bxi) [bw^top bz + bw^top bxi >= -y(bz) w_"sp"] + Pr_(bz, bxi) [-bw^top bz + bw^top bxi >= y(bz) w_"sp"] \
  = &Pr_(bz, bxi) [bw^top bz + bw^top bxi >= -y(bz) w_"sp"] + Pr_(bz, bxi) [-bw^top bz - bw^top bxi >= y(bz) w_"sp"] \
  = &Pr_(bz, bxi) [bw^top bz + bw^top bxi >= -y(bz) w_"sp"] + Pr_(bz, bxi) [bw^top bz + bw^top bxi < -y(bz) w_"sp"]  = 1
$$
I'm not being careful here with strict inequalities vs including the equals case but I don't think it matters. This gives that our desired quantity equals
$$
= a w_"sp" (Pr_(bz, bxi) [bw^top bz +bw^top bxi >= -y(bz) wsp] - lambda )
$$
so it remains to show that the above probability equals $1/2 + epsilon_bw/4$. We first expand over the distribution of $z in {plus.minus mu_1, plus.minus mu_2}$ unifomrly to get
$$
Pr_(bz, bxi) [bw^top bz +bw^top bxi >= -y(bz) wsp] = Pr_(bz, bxi) [bw^top bxi + y(bz) w_"sp" > -bw^top bold(mu)_1]
  \ = 1/4 (
  Pr_bxi [bw^top bxi + w_"sp" > - bw^top bold(mu)_1] \
  +Pr_bxi [bw^top bxi + w_"sp" >  bw^top bold(mu)_1] \
  +Pr_bxi [bw^top bxi - w_"sp" > - bw^top bold(mu)_2] \
  +Pr_bxi [bw^top bxi - w_"sp" >  bw^top bold(mu)_2]
  )
$$
and then take complements for the first two probabilities, and use the symmetry of $bxi$ for the last two to rewrite the above as
$$
= 1/2 + 1/4 (
  -&Pr_bxi [bw^top bxi + w_"sp" <= - bw^top bold(mu)_1] \
  -&Pr_bxi [bw^top bxi + w_"sp" <= bw^top bold(mu)_1] \
  +&Pr_bxi [bw^top bxi + w_"sp" <=  bw^top bold(mu)_2] \
  +&Pr_bxi [bw^top bxi + w_"sp" <= - bw^top bold(mu)_2])
$$
let $A <= B <= C <= D$ be the ordering of ${plus.minus bw^top bold(mu)_1, plus.minus bw^top bold(mu)_2}$, observing that $A = -D$ and $B = -C$ with $A,B <= 0$ and $C,D >= 0$. Therefore the ordering is determined by whether $abs(A),abs(B)$ is bigger, which is equivalent to whether $sgn(w_1) = sgn(w_2)$ as $bold(mu)_1, bold(mu)_2$ subtract and add these two entries respectively when taking inner products.

Considering first the case where $sgn(w_1)=sgn(w_2)$ and so $bw^top bold(mu)_2$ is larger in absolute value write $X = bw^top bxi + w_"sp"$; we have that the above probability is
$$
-Pr[X <= B] - Pr[X <= C] + Pr[X <= A] + Pr[X <= D]  \
  = Pr[X <= A] + Pr[X <= D] - Pr[X <= B] - Pr[X <= C] \
  = Pr[X <= A] + (Pr[X <= A] + Pr[A <= X <= D]) \ - (Pr[X <= A] + Pr[A <= X <= B]) - (Pr[X <= A] + Pr[A <= X <= C)] \
  = Pr[A <= X <= D] - Pr[A <= X <= B] - Pr[A <= X <= C] \
  = Pr[C <= X <= D] - Pr[A <= X <= B]
$$
and we notice that the above is $Pr[bw^top bxi + w_"sp" in [C,D]] - Pr[bw^top bxi + w_"sp" in [A,B]]$ where the symmetry of $bxi$ gives that the first term equals $Pr[-bw^top bxi + w_"sp" in [C,D]] = Pr[bw^top bxi - w_"sp" in [A,B]]$ where we used that $A=-C, B=-D$. Therefore as desired, the above equals
$$
Pr[bw^top bxi - w_"sp" in [A,B]] - Pr[bw^top bxi + w_"sp" in [A,B]]
$$
In the case where $sgn(w_1) != sgn(w_2)$ you can check that we get the negation of the original expression with respect to the ordering of $A,B,C,D$ so the same argument applies with the result being the negation of the above probability, as claimed.

∎
