---
tags: []
---

# 01 More Argument Principle - Nov 26th
## How the argument principle connects to the argument
> [!theorem] The argument principle
> If $C$ is a simple closed curve with $f$ analytic on a neighborhood of $C$ and its interior except for finitely many singularities inside $C$ then
> $$
> integral_C frac(f'(z), f(z)) d z = 2 pi i (N - P)
> $$
> where $N$ is the number if zeros, and $P$ the number of poles. Observe that the integrand is a logarithmic derivative, and since we're just considering change there's no issues with branches.

By considering $w(t) = f(z(t))$ for $z(t)$ being some parameterization of $C$ such that $t in [a,b], z(a) = z(b)$ we can find continuous functions $r(t), theta(t)$ from $RR$ to $RR$ where $w(t) = r(t) e^(i theta(t))$ so that
$$
integral_C frac(f'(z), f(z)) d z = integral_a^b frac(d/(d t) f(z(t)), f(z(t))) d t = integral_b^a frac(r'(t), r(t)) d t + integral_a^b i theta' (t) d t = ln(frac(r(b), r(a))) + i (theta(b) - theta(a)) \
= i(theta(b) - theta(a))
$$

so the integral is just the increment of the argument over the curve. Let's define $Delta_C arg(f)$ to be the increment in the argument of $f$ over $C$ so that
$$
i (theta(b)- theta(a)) = i Delta_C arg(t)
$$
and $Delta_C arg (f) = 2 pi (N - P)$. 
## An example calculation
The rest of lecture walked through a calculation to find the number of zeroes of $f(z) = z^3 + z + 1$ in the right half plane, since this function has no poles it suffices to track the increment in the argument.
### A sketch:
* You then consider a semicircular contour with the curved part lying in $"Re"(z) > 0$ and radius tending to infinity such that all zeroes are captured
* On the vertical line we never wrap around zero; if $z = i y$ then $f(z) = 1 + i(y - y^3)$ and the $y^3$ dominates as $R -> oo$ implying the change in argument can be found by considering the endpoints, which gives $pi slash 2 - (- pi slash 2) = pi$.
* On the semi circular arc we have $z = R e ^(i theta), theta in [-pi slash 2, pi slash 2]$, you show it suffices to just consider the highest order term $g(z) = z^3$ so that $g(t) = R^3 e^(i 3 t)$ and plugging in $theta = -pi slash 2, theta = pi slash 2$ gives $3 pi$.
	* To handle the leftover we write $f(z) = 1 + z + z^3 = z^3 ( 1 + 1/z^2 + 1/z^3)$ such that for $z = R e^(i theta)$ the lower order terms contribute some small perturbation away from the origin as $R -> oo$ and so they're negligible for tracking the argument
	* it's not clear to me why we're allowed to take limits here? Are we choosing $R$ sufficiently large or actually considering the limit
	* The change in the argument should just depend on the number of zeroes enclosed so long as $R$ is big enough to enclose all
	* Okay I think the point is that if we take $R$ not going to infinity we would have to precisely track how these lower order terms contribute to the argument's increment, which will equal the behavior in the limit just having some complicated cancellation we don't need to worry about
	
Okay so we take $R arrow oo$ such that $Delta_C arg (f) arrow 3pi + pi = 4 pi$  so $N=2$, so $f$ has just two zeroes in the right half plane