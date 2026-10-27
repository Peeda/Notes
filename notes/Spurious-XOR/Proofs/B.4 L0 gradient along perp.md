---
tags: [spurious-xor]
---
![](../Proof%20Overview.md#^b4)

*Proof of [Lemma](../Proof%20Overview.md#^b4).* As before we can use the definition of $L_0$ to see that
$$
-bw_perp^top grad_bw L_0 = -bw_perp^top EE[-y(bx) a sigma' (bw^top bx) bx] = EE[y(bz) a sigma' (bw^top bx) bw_perp^top bxi]
$$
and here we'll appeal to the symmetry of $bxi$ right at the start to get this equals
$$
= 1/2 a EE[y(bz) bw_perp^top bxi (sigma'(bw^top bz + bw^top bs + bw^top bxi) - sigma'(bw^top bz + bw^top bs - bw^top bxi))]
$$
$$
= 1/2 a EE[y(bz) bw_perp^top bxi (bb(1)[bw^top bz + bw^top bs + bw^top bxi] - bb(1)[bw^top bz + bw^top bs - bw^top bxi])]
$$
as before, notice that $bb(1)[a+b+c] - bb(1)[a+b-c]$ is one when $-c <= a+b<= c$ and negative one when $c <= a + b <= -c$ and so it equals $sgn(c) bb(1)[abs(a+b) <= abs(c)]$, and so the above equals, after using $sgn(x)x=abs(x)$,
$$
= 1/2 a EE[y(z) abs(bw_perp^top bxi) bb(1) [abs(bw_perp^top bxi) >= abs(bw^top bz + bw^top bs)] ]
$$
unlike the proof of [Lemma](../Proof%20Overview.md#^b1) we're not doing any conditioning on whether $wsig||bz$ so we just expand here over $(bz,bs)$, grouping $1-lambda$ terms and $lambda$ terms that have the same value because of absolute values to get
$$
= 1/8 a EE[&abs(bw_perp^top bxi) (\
  & bb(1) [abs(bw^top bxi) >= abs(bw^top bold(mu_1) + wsps)] \
  + & bb(1) [abs(bw^top bxi) >= abs(bw^top bold(mu_1) - wsps)] \
  - & bb(1) [abs(bw^top bxi) >= abs(bw^top bold(mu_2) + wsps)] \
  - & bb(1) [abs(bw^top bxi) >= abs(bw^top bold(mu_2) - wsps)] \
  )]
$$
and if $(bw,a)$ is a positive neuron then $bw^top bold(mu_1) = sqrt(2) norm(wsig)$, and for negative neurons $wsig, wopp$ swap roles (so they get opposite signs). Given that negative neurons have $a < 0$ we can compactly write this as
$$
= 1/8 abs(a) EE[&abs(bw_perp^top bxi) (\
  & bb(1) [abs(bw^top bxi) >= sqrt(2)norm(wsig) + wsps)] \
  + & bb(1) [abs(bw^top bxi) >= sqrt(2)norm(wsig) - wsps)] \
  - & bb(1) [abs(bw^top bxi) >= sqrt(2)norm(wopp) + wsps)] \
  - & bb(1) [abs(bw^top bxi) >= sqrt(2)norm(wopp) - wsps)] \
  )]
$$
as desired.

> [!todo] why is this expression uglier than the signal direction's expression? Does it say something interesting about how xi and the first two coordinates behave differently?

∎
