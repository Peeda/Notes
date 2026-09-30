= Chapter 0 Exercises
== 0.1
=== A
Recall that for any random variable $X$ we have $EE [(X - EE X)^2] = EE [X^2 - 2 X EE X + (EE X)^2] = EE X^2 - 2 (EE X)^2 + (EE X)^2 = EE [X^2] - EE[X]^2$. A similar linearity of expectation argument works for vectors using that $norm(x)_2^2 = x dot x$ with known properties of the dot product.
$ EE norm(Z - EE Z)_2^2 = EE [(Z - EE Z) dot (Z - EE Z)] = EE [norm(Z)_2^2 - 2 (Z dot EE Z) + norm(EE Z)_2^2] \
  = EE norm(Z)_2^2 - 2 EE [Z dot EE Z] +  norm(EE Z)_2^2 = EE norm(Z)_2^2 - norm(EE Z)_2^2
$
=== B
Recall that for scalar random variables $X,X'$ which are independent and equal in distribution we have $EE[(X - X')^2] = EE[X^2 - 2 X X' + X'^2] = EE X^2 - (2 $
