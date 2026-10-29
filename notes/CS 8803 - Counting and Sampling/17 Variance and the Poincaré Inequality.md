---
tags:
  - counting_and_sampling
---
# Variance and the Poincaré Inequality
## The Mixing Time Bound Recipe
Recall that $tmix$ is defined to be the minimum $t$ such that running our Markov chain for $t$ steps guarantees tv distance at most $1 slash 4$, formally we have
$$
tmix = min {t | tv(P^t(x, dot), pi) < 1 slash 4,  forall x in Omega}
$$
We will often bound the mixing time as follows:
1) Choose a metric $D$ over the space of distributions (could be a distance metric, or statistical divergence) so that bounding $D$ implies a bound on the tv distance
2) Prove a one-step contraction in $D$ so $D(mu P, pi) <= (1 - gamma) D (mu, pi)$ so that we have guaranteed multiplicative progress towards the stationary distribution at each step

Therefore if we have
$$
tv(P^t (x, dot) , pi) &<= D(P^t (x, dot) , pi)) \
&<= (1 - gamma)^t D(delta x, pi), forall x in Omega \
&<= e^(-gamma t) D(delta x, pi)
$$
we can set $e^(-gamma t) D(delta x, pi) < 1 slash 4$ to see that $t > 1/(gamma log(1 slash 4)) log(D(delta x, pi))$ suffices implying
$$
tmix =O(1/gamma log(max_x D(delta x, pi))).
$$