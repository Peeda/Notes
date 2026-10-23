---
title: ODE Exam 1 Review
author: Peter Chen
date: 2026-10-17
---

# ODE Exam One Review on the Plane
- Autonomous differential equations, phase portraits
- Solving First Order Differential Equations (separable, method of integrating factor)
- $2$d Systems of the form $arrow(x)'(t) = A arrow(x)(t)$

## Autonomous differential equations
- Recall a differntial equation is some equation that involves a function $f$ usually mapping $RR -> RR$ as well as its derivative
  - In this class usually we denote by $y(t)$ such a function $RR -> RR$
  - - PDEs consider more general maps and can impose relations between partials
- We say a differential equation is **autonomous** if it's time invariant, in other words if we have
  $$
  f'(t) = g(f(t))
  $$
for some function $g$. This notably means that the rate of change is entirely determined by the current function value and does not depend on the input/time
  - This means that if we draw it like a vector field the horizontal strips all have the same direction, we can only draw it like this because we can put $y$ on the $x$ axis which we can't do in general
- for example $y' = y(1-y)$ is an autonomous differential equation, but $y'(t) = t y(t)$ isn't
- Notice that for any $c$ such that $g(c) = 0$ we have that the constant function $y=c$ is a solution to this differential equation
  - Because of time invariance, the behavior of $g$ (in particular its sign) between these constant solutions lets us conclude any other solution must converge to one of these guys because we know $f'(t)$

## Solving First Order ODEs
- A first order ODE is an equation of the form
  $$
  y' = f(y,t)
  $$
- where the order denotes the highest derivative involved. This is more general than we'll actually be able to solve though
- If $f$ can be factored into a function of $y$ and a function of $t$ then we say the ODE is separable, in this case
  $$
  y' = p(y)q(t) -> 1/p(y) y' = q(t)
  $$
- and we can integrate using the chain rule (but remember to check for lost solutions)
- We say a differential equation is **linear** if the terms involving derivatives only use linear functions in $y^((k))$ (so they're allowed to depend on $t$)
  - For example $y'' = sin(y)$ is not allowed but $y'' = sin(t)y'$ is allowed.
  - Notably separable differential equations need not be linear unless $p$ is the identity (we can't always write some function $p(t) y + q(y)$ as the product of functions in $t,y$
- We mainly focus on first order linear differential equations, we say the standard form for such an ODE is
  $$
  y' + p(t) y = q(t)
  $$
- We solve these equations via the method of the integrating factor $mu = exp(integral p(t) d t))$, observe that multiplying this through gives that
  $$
  mu y' + mu p(t) y = mu q(t)
  $$
- where $mu' = mu p(t)$ so by the product rule we can write this as
  $$
  (mu y)' = mu q(t) -> y = 1/mu integral mu q(t) d t
  $$

## Two Dimensional ODEs
- Okay we generalize the above to systems that involve two functions $x_1(t), x_2(t)$ and write $arrow(x)(t) = vec(x_1(t), x_2(t))$
- We study two dimensional ODEs with constant coefficients, so systems of the form
  $$
  x_1 ' = a x_1 + b x_2
  $$

$$
x_2 ' = c x_1 + b x_2
$$
so we can write this as $arrow(x)' (t) = A x(t)$
- There's some way to write a second order ODE (with constant coefficients) as a two dimension first order ODE, I think you take $x_1 (t) = y$ and $x_2 (t) = y'$ or something like this
- Not sure where these equations come from but solve for the eigenvalues and eigenvectors; our solutions are of the form $c e^(lambda t) v$ for each pair
  - If there's just one then we form the second solution with $c e^(lambda t) (t v + w)$ I guess just remember this as the intuitive thing being to try $t v$ but for some reason we need to add $w$ for this to actually work
  - $w$ is such that $(A - lambda I) w = v$, so $A - lambda I$ kills $v$ but can only kill $w$ after two applications
- For the real eigenvalue case you just draw out our two solutions and draw the arrows according to the sign of $lambda$
  - Then the intermediate solutions get drawn towards the fast one more or less, but I think I will need to review all the pictures at some point
