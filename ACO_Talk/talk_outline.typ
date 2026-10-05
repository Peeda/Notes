= The Message
- I would think the talk went well if the audience walked away with
  - Some sense of what's discrepancy theory is about, both from a mathematical/existential results perspective and an applictions perspective
  - Some sense of the basic question and answer of this work, namely that the proof of this strong subgaussian distributional guarantee assumes infinite precision and it's not obvious that we should preserve that even though the alg is Markov

- Start the talk by saying I am Peter this is some work that I did with Emile and Jan
= The outline
== Discrepancy theory
- What is discrepancy theory about intuitively
- Define $"disc"(A)$ for a matrix $A$
- random assignments aren't best for binary sqaure $A$ (this is a set system on $[n]$ with $n$ sets), Spencer $1985$ is $6 sqrt(n)$ improving on random $sqrt(O(n log n))$
- It wasn't known for a long time if this existential result could be made algorithmic
  - But then Bansal did that
- and this is a long recurring theme in discrepancy theory and what's called algorithmic discrepancy, where existence proofs were shown non constructively and then refined later
  - Algorithmic results serve a dual purpose, both to better understand proofs/provide constructive results but also downstream applications
    - Attention approximation, rounding/quantization, survey sampling, monte carlo integration
    - Cases where you naturally want to approximate the whole with some part
- There's a ton of recent progress in discrepancy, lots of open problems have been solved recently
== The Gram-Schmidt Walk
- Algorithmic version of the Komlos problem, where we assume columns have $ell _2$ norm at most one
- Show the code and step the algorithm
- the output $z$ is such that $B z$ is a subgaussian random vector, so
$ EE [exp (chevron.l B z, v chevron.r)] <= exp (1/2 norm(v)^2) $
- which implies Gaussian type tail behavior, you can check that by considering $Pr[X >= t]$ and doing this Markov in the MGF type thing
- Talk about the two extreme examples for $B$, being the identity and the repeated vector case
  - So we can think of the algorithm as taking advantage of linear dependencies between the columns while still injecting enough randomness into the process such that we can get subgaussianity when the columns are orthogonal and there's no dependence to exploit
- This is used for downstream tasks also, mention Spielman
== Our Contributions
- Okay so notice that at each iteration you solve a least squares system
- and in practice you might want to do this by maintaining some matrix factorization for faster repeated solves
  - if this is going to be used for downstream tasks then we should check that doing approximate solves is fine
- The idea that the distribution is basically subgaussian is believable but not super obvious
  - In particular it's unclear how to reason about approximate updates at each step and how they impact the whole distribution
  - You can consider an edge case where you clip a corner and now you're going down a whole different path
- Experimental results show that really you get degrading performance as $n$ scales
  - This makes sense as at each step if you're taking an approximate step, then it's like you're incurring some free discrepancy according to how messed up your solution is
- and it probably is, most of the time, we show a result like
$ exp(1/2 norm(v)^2 + O(n^2 epsilon) norm(v)) $
where really $epsilon$ is broken down into more stuff to parameterize over different sources of error
- The proof of Spielman is somewhat technical so I will not show the whole thing
- The basic idea is to show a sort of MGF martingale condition where you break up the updates into bound
$ chevron.l B u_t, v chevron.r = sum_t delta_t chevron.l B u_t, v chevron.r + epsilon_t = sum_(S_p) (sum_t delta_t chevron.l B u_t, v chevron.r + epsilon_t) $
suffices to show that for each $S_p$
$ EE [exp (sum_(t in S_p) delta_t chevron.l B u_t ,v chevron.r + epsilon_t - Phi_t) | "past up to" S_p] <= 1 + epsilon_0 $
and then get the whole result by iterating this $n$ times, where the original proof shows a RHS of 1. Here the potential function $Phi_t$ is chosen to begin at $norm(v)^2$ and decay to zero
  - You're just taking the thing we care about and grouping according to pivot phases, which are the iterations over which a given unit is the pivot
  - in particular it's chosen by splitting $norm(v)^2$ into some orthogonal basis and distributing the terms according to what units get decided in each pivot phase
- The original proof does some complicated "backwards induction" style argument to show a tight concentration
  - You can use a lemma that characterizes the $B u_t$ as a sum of projections, then you condition such that the randomness is only over the $delta_t$ over the tail of the pivot phase
  - And show that the expectation is a matrix function that's decreasing over $2 times 2$ psd matrices
- so the fix here is just to split off the noise and bound these guys separately, using boundedness
- It then remains to analyze these perturbed updates $sum_(t in S_p) delta_t chevron.l B u_t, v chevron.r$
== Summary
- So yeah
- one thing is that the proof uses bounded noise but maybe you can get better results using statistical assumptions
