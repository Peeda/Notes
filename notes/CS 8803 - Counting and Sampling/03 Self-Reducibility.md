---
tags:
  - counting_and_sampling
---
# Self Reducibility
## Approximate Counting and Sampling
For some finite ground set $U$ with a family of subsets $Omega subset.eq 2^U$ and weight function $Omega -> RR^+$ we are interested in $Z = sum_(x in Omega) w(x)$. Note that if our weight function is $x arrow.bar 1$ then $Z$ is the size of $Omega$. We think of $Omega$ as being subsets that satisfy a certain property that we'd like to count, for example out of all edge subsets in a graph we might be concerned with how many are perfect matchings.

> [!definition] FPRAS 
> A *fully polynomial time randomized approximation scheme* is a randomized algorithm with output $hat(Z)$ such that for any approximation error $epsilon in (0,1)$ and any failure probability $delta in (0,1)$ $hat(Z)$ is within $epsilon$-multiplicative error of $Z$ with probability $1-delta$ in time $poly(n, 1 / epsilon log(1 slash delta))$. Stated as an event we require that 
> $$
> Pr[(1-epsilon)Z <= hat(Z) <= (1+epsilon)Z] >= 1 - delta.
> $$

^def-FPRAS

On the sampling side, we require the following two definitions:
> [!definition] Gibbs Distribution
> Given some weight function $w$, the *Gibbs Distribution* assigns mass to some set $x in Omega$ according to its portion of the total weight,
> $$
> pi(x) = w(x)/Z, forall x in Omega
> $$

So in the case where $w(x)$ is the map $x arrow.bar 1$ this is just a uniform distribution over the outcomes in $Omega$. It should be noted then that our outcomes in this probability space are themselves sets with some structure (the things to be counted), and our events are collections of these sets.

> [!definition] Total Variation Distance
> Given probability distributions $mu, pi$ on some sample space $Omega$ the TV distance is
> $$
> tv(mu, pi) = 1/2 sum_(x in Omega) abs(mu(x) - pi(x)).
> $$

Interpreting $mu, pi$ as vectors in $RR^abs(Omega)$ this is equal to $1/2 norm(mu - pi)_1$. You can also check that $tv(mu, pi) = max_(A subset.eq Omega) abs(Pr_mu [A] - Pr_pi [A]).$ (consider the set of $x in Omega$ such that $mu(x) >= pi(x)$). With these definitions we can define our notion of an approximate sampler:

> [!definition] FPAS
> A *fully polynomial time approximate sampler* for some target distribution $pi$ on a finite set $Omega$ is a randomized algorithm such that, for any $delta in (0,1)$, outputs a random sample $x in Omega$ according to some distribution $mu$ such that
> $$
> tv(mu, pi) <= delta
> $$ 

in time $poly(n, log(1 slash delta))$. We now show that the existence of an FPRAS and an FPAS are equivalent (this holds generally for _self-reducible_ problems although we don't define this here). We instead focus specifically on the problem of counting matchings and show this is equivalent to sampling from the uniform distribution over these matchings.


> [!lemma]
> There exists an FPRAS for the number of matchings in a graph if and only if there exists an FPAS for the uniform distribution over such matchings.

*Proof*: todo!

## Markov Chain Basics