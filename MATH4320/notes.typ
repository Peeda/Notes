#set text(font: "New Computer Modern Math")
= Exam One Brief Review
Topics:
- Basic Properties of complex numbers, polar form, multiplication and division
- Visualizing mappings from $CC -> CC$, constructing mappings with certain parts of the plane as images given some input region
  - Quadrants, slices of $theta$
- Cauchy Riemann Equations
- Analytic functions
- Differentiation in $t$ of some $f: RR -> CC$
- FTC for complex valued functions
- Curves and contour integrals
== Complex Numbers
- Complex numbers are a field, we can think of them as taking the field given by $R[x] slash (x^2 + 1)$, so taking the ring of real valued polynomials and adjoining some element $x$ such that $x^2 equiv -1$
  - Or more traditionally as the set of pairs $x + y i$ where $x,y in RR$ and $i in CC$ is some element such that $i^2 = -1$
- The special structure of $CC$ that differs from $RR^2$ is that we can multiply the elements of $CC$ as field elements via direct expansion and using $i^2 = -1$
- A complex number $x + y i$ can also be written in polar form, like the corresponding form for vectors in $RR^2$, specifically we have
$ x + y i = R e ^(i theta) $
- for $R = sqrt(x^2 + y^2), theta = tan^(-1) (y slash x)$ where $theta in [-pi,pi)$ I think (maybe the convention on $-pi$ is different, and the arctan function here uses a different domain than usual)
  - We take, in this course, the definition of the complex exponential to be given by Euler's formula (although there are other ways of arriving at this formula) and so $e^(i theta) = cos theta + i sin theta$, so we can think of this function as mapping some purely complex number $i theta$ to the vector of unit length that's a rotation of $theta$ counter clockwise from the origin
- Multiplication and division of complex numbers is often easier to think of in polar form, as one can check that it's the same as multiplying the magnitudes and adding the angles
  - So like some division such as $1 slash i = -i$ can be reasoned out by visualizing the rotation, because we divide we rotate clockwise by $pi/2$ since $i = exp(i pi / 2)$
- There's a formula in terms of the rectangular coordinates also but it's somewhat long, you can always do divisions by multiplying the denominator by the conjugate to get a real denominator then simplifying the numerator
== Mappings in $CC$
- We discuss mainly functions $f: CC -> CC$, so one can think of this like a vector field that associates some complex number with each point in the complex plane
- We are often asked to visualize functions in terms of their domain and image, for example we might want to find some function that maps a specific quadrant of the complex plane onto some area defined by a certain range of $theta$
- It's good to keep the following functions in mind as generally the desired mapping can be composed from them
  - $exp$ is defined as $exp(x + y i) = exp(x) (cos y + i sin y)$, so we take some complex number and interpret its $x$ position as our magnitude (after scaling it by $x arrow.bar e^x$, and its $y$ position as our angle
    - This means that horizontal lines in $CC$ where $y$ is constant and $x$ varies map into rays, with the angle given by $y$
    - Vertical lines, by similar reasoning, map into circles as we vary the angle and keep the magnitude constant
  - $log$ is the inverse of $exp$ so we take circles and map them to vertical lines, and map rays to horizontal lines but you have to fix some convention on branches otherwise it's a multifunction
  - $exp$ and $log$ give us a way to translate between regions defined by restricting $x,y$ to lie in some interval such as rectangles, and regions defined by restricting $r, theta$ like sectors and discs
  - Examples:
    - The action of $exp$ on the first quadrant is to map it to the first two quadrants/the upper half plane with $r > 1$ as the first quadrant is where $x,y > 0$ and so we have $e^x > 1$, $theta > 0$ under $exp$
    - The action of $log$ on the first quadrant is to map it into a vertical strip where $x > 0$ and $y in [0,pi/2]$ by similar reasoning, these two maps can be thought of as reinterpreting between rectangular and polar coordinates
  - Conjugation $z arrow.bar overline(z)$ reflects about the $x$ axis or equivalently negates the angle in polar representation
  - Multiplication by $e^(i theta)$ is a rotation of $theta$ radians, division follows similarly
  - $sin$ and $cos$ I don't really understand well
== The Cauchy Riemann Equations
- For complex functions $f: CC -> CC$ the output can be written in rectangular coordinates to reveal that the real and imaginary parts individually are a function from $CC -> RR$ or equivalently from $RR^2$ to $RR$
- So we can think of any function as a function from $RR^2 -> RR^2$, or as a pair of functions from $RR^2 -> RR$ each defining one part of the resulting complex number
  - You could also think of this splitting into two parts as first applying $f$ then projecting onto the real or imaginary part to get a function from $RR^2 -> RR$
- Any pair of functions $RR^2 -> RR$ therefore define a complex function $f: CC -> CC$
- We say a complex function is differentiable with respect to its input $z in CC$ at a point $z_0 in CC$ when the limit
$ lim_(h -> 0) frac(f(z +h) - f(z),h) $
- exists, here $h$ is a complex number which approaches zero in terms of modulus. You can think of functional limits as choosing some open neighborhood $epsilon$ sufficiently small such that anywhere in this neighborhood $f$ is $delta$ close to the limiting value for some desired $delta$
  - So functional limits can fail to exist if it's possible to choose two directions such that the limit disagrees, for example take $h -> 0$ as $x -> 0$ or $i y$ as $y-> 0$ or $t (1 + i)$ as $t-> 0$, if these disagree then we fail to find the desired open neighborhood
  - This also lets you calculate $f'(z_0)$ from the partials; given that all directions of approach agree it suffices to find a formula for the derivative just varying $x$ and seeing how $z$ changes
  - Note: the division here is by a complex number $h$
- The Cauchy-Riemann equations give a necessary condition for such a pair of functions to be complex differentiable; if $f(z) = u(x,y) + i v(x,y)$ for functions $u,v : RR^2 -> RR$ then it's necessary that $u_x = v_y, u_y = -v_x$. I don't have great intuition for this though, I think it's somehow connected to if you interpret this as a vector function this condition says the Jacobian is like a scaled rotation which could connect to the structure of complex multiplication
- One can also check that if $f(z) = u(r, theta) + i v (r, theta)$ so we have some complex function where the real and imaginary parts are expressed as functions of points in $RR^2$ expressed in polar coordinates then we need $u_r = 1/r v_theta, u_theta = -r v_r$
- Also when the partials are continuous the Cauchy Riemann equation are sufficient so this can be used as a way to check when $f$ is continuously differentiable
== Analytic Functions
- We say a function $f: CC -> CC$ is analytic over some open set $U$ (also called holomorphic) when it's continuously differentiable everywhere in $U$
  - This gives a lot of nice properties/things we can say about $f$ but these are not on this exam
== Contour Integrals
- Taking the definition of a real integral for granted, we define an integral for a function $f: RR -> CC$ as just
$ integral_a^b f(t) d t = integral_a^b u(t) + i v(t) d t = integral_a^b u(t) d t + i integral_a^b v(t) d t $
so more or less just assuming that the integral operator behaves linearly, although there's probably a more rigorous way to arrive at this definition.
- So computing such integrals reduces to taking our function from $RR$ to $CC$ and splitting into two functions from $RR$ to $RR$ and integrating separately
  - In particular you calculate some antiderivate for each part and apply the real FTC
  - You could take these two antiderivatives and get a complex function $RR -> CC$ and I believe this is defined as the complex antiderivative, using that differentiation is linear although we didn't do this in detail
- For a function $gamma: [a,b] -> CC$ for $a,b in RR$ we can visualize $gamma$ as tracing some path in the complex plane, and can consider integrating a complex function from $CC$ to $CC$ along this curve
- Define the contour integral of such a function $f: CC -> CC$ over a curve $gamma$ as defined above to be
$ integral_gamma f(z)d z = integral_a^b f(gamma(t)) gamma'(t) d t $
  - So intuitively what we're saying is that if we want to integrate a function that maps $CC$ to $CC$ we can add up its function values along some path in the complex plane, which reduces to the case of integrating a function from $RR$ to $CC$ by parameterizing over the curve.
  - We get a factor of $gamma'(t)$ in the integral, intuitively, to cancel out any variation in the parameterization of $gamma$, with curves traversing the same path faster giving more contribution for each small step, correcting for both speed and angle as this is a complex number
    - It's also just u substitution more or less
  - Here $d z$ is like a small change in $z$ along the curve; this is how we give a meaning to integrating over the complex plane which before hand doesn't really seem to make sense without choosing a particular curve
  - It can be shown that the parameterization doesn't impact the countour integral so long as you're tracing the same curve in the same direction and not repeating points
- And I believe you have an FTC for contour integrals as well under certain conditions although this stuff isn't on this first exam
