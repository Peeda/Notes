#set page(
  paper: "us-letter",
  margin: 1in,
  numbering: "1",
  number-align: right + top,
)

#set text(
  font: ("Times New Roman", "TeX Gyre Termes", "Libertinus Serif"),
  size: 12pt,
)

// Approximates double spacing, with no extra gap between paragraphs
#set par(leading: 1.5em, spacing: 1.5em, justify: false)

// Math font that matches Times
#show math.equation: set text(
  font: ("STIX Two Math", "TeX Gyre Termes Math", "New Computer Modern Math"),
)

// Plain centered title
#show heading: it => {
  set text(size: 12pt, weight: "regular")
  align(center, it.body)
  v(0.5em)
}

// 0.5in hanging indent on the citation; annotation starts 1in from the margin
#let annotated(citation, annotation) = {
  par(hanging-indent: 0.5in, citation)
  pad(left: 1in, annotation)
}

// Citation with a hanging indent, annotation indented below it
#let annotated(citation, annotation) = {
  par(hanging-indent: 1.5em, citation)
  pad(left: 2em, right: 2em, annotation)
  v(0.5em)
}

= Annotated Bibliography

// Strive for complete citations -- identify the topic/issue addressed by the source, the claim the researcher writer makes, evaluate the evidence the researcher uses to argue for their claim, and consider the source's significance for your research project. Be certain to consider the role the source plays in realtion to your research: foundation (history, context, establishing objectives and scope), methods, foil (challenge or leaving an importnt gap you want to address), or some other function. Follow standard bibliography conventions.

// foundation, methods, foil
#annotated[
  Ryan Alweiss, Yang P. Liu, and Mehtaab Sawhney. Discrepancy minimization via a self-balancing
  walk, 2020. #link("https://arxiv.org/abs/2006.14009").
][
  Alweiss, Liu, and Sawhney demonstrate the existence of an online algorithm for the Komlos vector balancing problem with a logarithmic subgaussianity guarantee. Put another way, they show it's possible achieve constant subgaussianity if a constant proportion, for example $5$ percent, of the input vectors are discarded. This is a key paper in establishing the context in algorithmic discrepancy as it runs in linear time as opposed to polynomial time, meaning that their algorithm is much faster and scales better than the Gram-Schmidt Walk, to be studied in our work. On the other hand, their algorithm has weaker distributional guarantees as their dependence is logarithmic so the tradeoff between the two is nuanced.
]
#annotated[
  Emile Anand, Jan van den Brand, Mehrdad Ghadiri, and Daniel J. Zhang. The Bit Complexity of Dynamic Algebraic Formulas and Their Determinants. In Karl Bringmann, Martin Grohe, Gabriele
  Puppis, and Ola Svensson, editors, 51st International Colloquium on Automata, Languages, and
  Programming (ICALP 2024), volume 297 of Leibniz International Proceedings in Informatics
  (LIPIcs), pages 10:1–10:20, Dagstuhl, Germany, 2024. Schloss Dagstuhl – Leibniz-Zentrum fur¨
  Informatik. ISBN 978-3-95977-322-5. doi: 10.4230/LIPIcs.ICALP.2024.10. #link("https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ICALP.2024.10")
][
  This ICALP paper demonstrates that Dynamic Algebraic Formulas, which are expressions involving matrices that are maintained under rank-one updates to the underlying matrix, are numerically stable. Their approach builds upon a prevoius result that shows a result in infinite precision arithmetic by bounding the condition number of a certain matrix involved in that previous paper. Their analysis is closely related to ours in the sense of considering numerical stability however they analyze a deterministic algorithm whereas ours is randomized and so our analysis must take into account impacts on a distribution rather than a single deterministic output.
]

#annotated[
  Wojciech Banaszczyk. Balancing vectors and gaussian measures of n-dimensional convex bodies.
  Random Struct. Algorithms, 12(4):351–360, July 1998. ISSN 1042-9832.
][
  This seminal paper of Banaszyczyk demonstrates the existence of a coloring for the Komlos problem such that the discrepancy of the relevant matrix is proportional to the square root of the logarithm of the number of columns in the matrix. His approach relies on a connection between theorems in geometry which relate back to the original vector balancing problem. This result would later motivate the discovery of the Gram-Schimidt Walk algorithm as a way to constructively recover the existence result shown and so it is a key background paper in understanding the existing literature in this field.
]
#annotated[
  Nikhil Bansal, Daniel Dadush, Shashwat Garg, and Shachar Lovett. The gram-schmidt walk: A cure
  for the banaszczyk blues, 2017. #link("https://arxiv.org/abs/1708.01079")
][
  The result of Bansal, Dadush, Garg, and Lovett in the above paper serves as the introduction of the Gram-Schmidt Walk algorithm which our work centers on. Their approach introduces the notion of pivot phases which is reused by later analyses, as well as the introduction of potential based methods to bound the moment generating function to ultimately show a subgaussianity result which would later be used in Spielman's work. A key observation in the development of algorithmic discrepancy is that the authors are concerned here with just existence of a certain algorithm in infinite precision whereas later applications of the algorithm care about actually using it for downstream tasks such as experimental design, without analyzing whether the original guarantees hold in finite precision. Therefore this is one of the two key papers in framing the contributions of our work, notably that we provide a refined analysis of the algorithm that accounts for calculation errors in finite precision arithmetic.
]
#annotated[
  Annabelle Michael Carrell, Albert Gong, Abhishek Shetty, Raaz Dwivedi, and Lester Mackey. Lowrank thinning. In Proceedings of the 42nd International Conference on Machine Learning, volume 267 of Proceedings of Machine Learning Research, pages 6811–6848. PMLR, 2025. #link("https://proceedings.mlr.press/v267/carrell25a.html")

][
  The above ICML paper serves as a key bridge between the literature on algorithmic discrepancy and the machine learning community, as it demonstrates that the problem of data thinning, choosing some subset of points to represent a whole distribution, is closely related to the algorithmic discrepancy problem of vector balancing. They prove this both experimentally as well as theoreticlaly, and in this way their paper serves as key context and motivation for our work in that it further cements the connection between the pure math analysis of a certain algorithm and downstream applications in data thinning.
]
#annotated[
  Jerry Chee, Arturs Backurs, Rainie Heck, Li Zhang, Janardhan Kulkarni, Thomas Rothvoss, and
  Sivakanth Gopi. Discquant: A quantization method for neural networks inspired by discrepancy
  theory, 2025. #link("https://arxiv.org/abs/2501.06417")
][
  Discquant demonstrates that discrepancy theory can also be applied to what is called neural network quantization, wherein one trains or runs inference on a neural network with a reduced amount of bits used for each number. Intuitively this means that we will get faster and more efficient performance, but suffer an accuracy loss. It should be noted that their work applies discrepancy to devise a way to properly round in neural networks rather than analyze how rounding impacts the discrepancy algorithm itself, and so their work is distinct although it draws upon the same combination of literature as our work.
]
#annotated[
  Daniel Dadush, Shashwat Garg, Shachar Lovett, and Aleksandar Nikolov. Towards a constructive
  version of banaszczyk’s vector balancing theorem, 2016. #link("https://arxiv.org/abs/1612.04304")
][
  Dadush, Garg, Lovett, and Nikolov show that Banaszcyk's proof of the existence of colroings achieving discrepancy on the order of the square root of the logarithm is equivalent to the existence of a subgaussian distribution over colorings. Put simply they connect the geometric ideas of Banascyk's proof to probabilistic notions of distributional concentration, which would later lead to the development of the Gram-Schmidt Walk algorithm. Therefore this paper is a key part of the context and literature survey in the development of the Gram-Schmidt Walk and algorithmic discrepancy theory more broadly.
]
#annotated[
  Yichuan Deng, Xiaoyu Li, Zhao Song, and Omri Weinstein. Discrepancy minimization in inputsparsity time. In Forty-second International Conference on Machine Learning, 2025. #link("https://openreview.net/forum?id=TmJvacopmV")
][
  In their work presented at ICML, Deng, Li, Song, and Weinstein demonstrate an efficient combinatorial algorithm that achieves an approximation guarantee in terms of the hereditary discrepancy of the input matrix. They do this by leveraging techniques commonly used in the machine learning community such as score sampling and therefore demonstrate the connection between the two groups of literature. It should be noted that whereas their algorithm provides a single good coloring, the Gram-Schmidt Walk provides a random coloring that is extremely likely to be good. Although it may seem like the former is strictly better than the latter, the precise meaning of what constitutes a good coloring implies that the two types of guarantees serve complementary purposes depending on the application and so a comparison between the two would serve to better place our work in the broader literature.
]
#annotated[
  Josef Dick and Friedrich Pillichshammer. Discrepancy theory and quasi-monte carlo integration. In
  A panorama of discrepancy theory, pages 539–619. Springer, 2014.
][
  In their textbook on discrepancy theory, Dick and Pillichshammer demonstrate that algorithms for discrepancy theory can be applied to the practical task of quasi-monte carlo integration, in which one wishes to approximate the integral of a certain continuous function by choosing some subset of points and adding the function's evaluation at these points in a similar vein to the application to data thinning. Their approach is to apply algorithmic discrepancy to carefully select this subset rather than naively choosing at random to ensure improved approximation quality by choosing points that better represent the function's behavior over the desired interval. This work is therefore relevant in establishing downstream applications impacted by numerical stability issues in discrepancy theory, which motivates our work.
]
#annotated[
  Mehrdad Ghadiri, Richard Peng, and Santosh S. Vempala. The bit complexity of efficient continuous optimization. In 2023 IEEE 64th Annual Symposium on Foundations of Computer Science
  (FOCS), pages 2059–2070, 2023. doi: 10.1109/FOCS57990.2023.00125.
][
  The above work presented at FOCS analyzes certain key continous optimization routines such as interior point methods for efficiently solving linear programs. To that end they focus on inverse maintenance, a key subroutine underlying many such optimization routines, and demonstrate that inverse maintenance is stable. Their work relates to ours as the Gram-Schmidt Walk involves such a optimization problem at each iteration which could be implemented with inverse maintenance and so their analysis can be built upon or used as an existing result in our analysis.
]

#annotated[
  Luc Giraud, Julien Langou, Miroslav Rozloznik, and Jasper van den Eshof. Rounding error analysis
  of the classical Gram–Schmidt orthogonalization process. Numerische Mathematik, 101(1):87–
  100, 2005. doi: 10.1007/s00211-005-0615-4.
][
  Giraud, Langoue, Rozlonik, and van den Eshof establish the classic result that the Gram-Schmidt Orthogonalization process is not numerically stable in general, with the orthogonal basis calcluated by the process degrading in quality as more arithmetic operations are performed. Despite the similar naming of the result to the proposed research work examining the stability of the Gram-Schmidt Walk, the two algorithms are actually quite different with the Gram-Schmidt Walk's naming referring to the usage of an ideal Gram-Schmidt walk in analysis only with an actual computation of an orthonormal basis not being necessary. The above result therefore is important as context in establishing how the classic Gram-Schmidt walk interacts with the numerical analysis literature, as a reference point for our analysis.
]
#annotated[
  Christopher Harshaw, Fredrik Savje, Daniel A. Spielman, and Peng Zhang. Balancing covariates in ¨
  randomized experiments with the gram–schmidt walk design. Journal of the American Statistical
  Association, 119(548):2934–2946, 2024. doi: 10.1080/01621459.2023.2285474. #link("https://doi.org/10.1080/01621459.2023.2285474")
][
  The Gram-Schmidt Walk design leverages the Gram-Schmidt Walk algorithm to balance covariates, a fundamental problem in experimental design. The authors show that the subgaussianity guarantee of the original algorithm allows one to effectively navigate what they dub the robustness-variance tradeoff by sampling colorings according to a certian interpolation between the standard basis and the experimental covariates. They also provide an improved analysis of the original algorithm with optimal constants, building upon the work of Bansal, Dadush, Lovett, and Garg. Furthermore they provide a matrix factorization scheme which preserves a Cholesky factorization of the augmented covariate matrix under rank-one downdates to improve the asymptotic runtime of the algorithm. Their work is therefore crucial in framing our improvements as it provides a downstream application of the Gram-Schmidt Walk and serves as the foundation upon which our approximate arithmetic analysis is built upon.
]
#annotated[
  Nicholas J. Higham. Accuracy and Stability of Numerical Algorithms. Society for Industrial and
  Applied Mathematics, second edition, 2002. doi: 10.1137/1.9780898718027. #link("https://epubs.siam.org/doi/abs/10.1137/1.9780898718027")
][
  Higham's standard textbook in numerical analysis establishes a number of classic results and definitions for the study of algorithmic stability. It is used in our work as a standard reference for results such as the accumulated relative error of repeated arithmetic operations with respect to the unit roundoff, as an important contextual work.
]
#annotated[
  Zohar Karnin and Edo Liberty. Discrepancy, coresets, and sketches in machine learning, 2019. #link("https://arxiv.org/abs/1906.04845")
][
  Karnin and Liberty's work in coreset applications in Machine Learning demonstrates a connection between discrepancy theory and machine learning by pointing out that a number of expensive machine learning algorithms can be sped up by applying discrepancy theory to select a subset of the input that approximates the whole. In this way it's a foundational paper that would be built upon in later works on attention approximation and dataset thinning via discrepancy theory and is crucial in motivating our current work.
]
#annotated[
  Ekaterina Kochetkova, Kshiteej Sheth, Insu Han, Amir Zandieh, and Michael Kapralov. Streaming
  attention approximation via discrepancy theory, 2026. #link("https://arxiv.org/abs/2502.07861")
][
  The BalanceKV system, contemporary with the Data Thinning paper, introduced the idea of applying Discrepancy Theory to Large Language Models by using vector balancing techniques to implement what's known as attention approximation whereby one speeds up the crucial attention mechanism which captures semantic dependencies between vectors in some input stream of text. In doing so they demonstrate the practical applictions of discrepancy theory to cutting edge problems and serve as a core part of our motivation in studying the numerical stability of the Gram-Schmidt Walk.
]
#annotated[
  Janardhan Kulkarni, Victor Reis, and Thomas Rothvoss. Optimal online discrepancy minimization. In Proceedings of the 56th Annual ACM Symposium on Theory of Computing, STOC 2024,
  page 1832–1840, New York, NY, USA, 2024. Association for Computing Machinery. ISBN 9798400703836. doi: 10.1145/3618260.3649720. #link("https://doi.org/10.1145/3618260.3649720")
][
  The above STOC 2024 paper due to Kulkarni, Reis, and Rothvoss demonstrates that for any input matrix $B$ with columns of Euclidean norm at most one there exists an optimal online discrepancy algorithm that achieves a subgaussianity guarantee matching that of the Gram-Schmidt Walk. Their algorithm notably runs in super exponential time and is not entirely constructive, as their result appeals to a nonconstructive fact about the existence of certain probability distribution over trees to argue for the existence of their algorithm. Therefore their work is built upon by ours as we provide an improved analysis of a numerically stable efficient algorithm with a matching asymptotic subgaussianity guarantee.
]
#annotated[
  Edo Liberty, Alexandr Andoni, and Eldar Kleiner. Nearly optimal attention coresets, 2026. #link("https://arxiv.org/abs/2605.05602")
][
  In "Nearly Optimal Attention Coresets" the authors leverage new mathematical tools to demonstrate the existence of very small coresets for attention approximation. They therefore strengthen the connection between discrepancy theory and machine learning which serves as a throughline in our introduction and motivation for studying the Gram-Schmidt Walk in finite precision.
]
#annotated[
  Linkai Ma, Christos Boutsikas, Mehrdad Ghadiri, and Petros Drineas. A note on the stability of
  the sherman–morrison–woodbury formula. SIAM Journal on Matrix Analysis and Applications,
  47(2):702–723, 2026. doi: 10.1137/25M1747087. #link("https://doi.org/10.1137/25M1747087")
][
  Ma, Boutsikas, Ghadiri, and Drineas characterize the stability of the Sherman-Morrison-Woodbury formula for the maintenance of a matrix inverse by relating the stability guarantee to the approximate inverse of the relevant matrix although the formula is not stable in general. As the Data Thinning paper proposes an implementation of the Gram-Schmidt Walk rely on inverse maintenance of a QR factorization, the above result demonstrates that a general stability result can not hold for such an implementation, demonstrating the Gram-Schmidt Walk will suffer from stability issues if not implemented carefully. This therefore motivates our work directly by demonstrating an existing gap in the literature.
]
#annotated[
  Joel Spencer. Six standard deviations suffice. Transactions of the American Mathematical Society,
  289(2):679–706, 1985. doi: 10.1090/S0002-9947-1985-0784009-0.
][
  Spencer's classic "Six Standard Deviations" result demonstrates that in the case of discrepancy on a set sysem of size $n$ supported on a universe of $n$ items, there exists a coloring of the underlying universe that achieves asymptotic discrepancy proportional to six times the square root of $n$, solving a long standing open problem by removing a logarithmic factor inside the square root. This work is a fundamental result in discrepancy and is therefore key in our introduction to ensure a complete introduction to the literature.
]
#annotated[
  Joel Spencer. Ten lectures on the probabilistic method. SIAM, 1994.
][
  Spencer's lectures on the probabilistic method introduce the technique whereby one argues for the existence of some mathematical structure satisfying some desired property by considering a random choice of such an object and arguing that such a choice satisfies the desired property with positive probability. This techinque is a fundamental baseline in discrepancy theory as one often considers how well a random partitioning of the data balances the dataset and then asks whether a more carefully chosen split that takes advantage of structural properties can improve upon this result. These techniques are important context for the history of discrepancy and therefore aid in establishing a proper introduction.
]
#annotated[
  Roman Vershynin. High-Dimensional Probability: An Introduction with Applications in Data Science. Cambridge Series in Statistical and Probabilistic Mathematics. Cambridge University Press,
  Cambridge, 2 edition, 2026.
][
  Vershynin's textbook on High-Dimensional Probability provides a definition of subgaussianity for random variables as well as its generalization to the random vector case. As the Gram-Schmidt Walk's guarantee is that the induced distribution over two colorings is subgaussian it is a necessary citation in introducing the relevant definition to the reader. It notably demonstrates the equivalence of four different characterizations of subgaussianity which improves upon the coverage in the original paper due to Bansal, Lovett, Dadush and Garg which only introduces the formulation in terms of moment generating functions.
]
