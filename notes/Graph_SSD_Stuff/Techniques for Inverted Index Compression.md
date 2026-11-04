---
type: article
title: Techniques for Inverted Index Compression
author: Peter Chen
---
# Paper Summary
## Single Integer Compression
* A code is just a map $C: ZZ^+ -> {0,1}^*$ mapping positive integers to bitstrings
* Observe that with respect to compression quality codes are the same up to swapping around assignments to some fixed length $k$
	* So really all we care about is $abs(C): ZZ^+ -> NN$ the length of each assignment (for compression quality not speed)
	* We want to choose how many bits each number will get, so that the common ones get shorter bitstrings and we use less space
* For any fixed $C$ we can find some distribution on the integers such that $C$ is information-theoretic optimal, by solving for $EE_x [abs(C(x))] = log (1 slash abs(C(x)))$ (we encode with exactly the distribution's entropy, on average)
	* If $C$ is just the standard binary representation then the optimal distribution is uniform because $abs(C(x)) = ceil(log_2 (x))$
		* Can think of this is uar over the uniform distribution, or as minimizing the total number of bits needed to encode every integer in our universe exactly once
	* If $C$ is the unary representation then the optimal distribution is $P(x) = 1 slash 2^x$
### Unary, Binary, and their variants
#### Unary, Binary
* Unary encodes $x$ as basically $x$ of either $0,1$ and the other bit gets used as a delimiter, so like $x = 1^(x-1) 0$ such that $abs(C(x)) = x$
* Binary is standard, but note that it's not uniquely decodable unless we know the number of bits being used up front
#### Delta, Gamma Codes
* Delta codes are just the unary representation of the number of bits being used, then the binary rep in that number of bits
* Gamma codes are Delta codes but you encode the number of bits with a Delta encoding
* k-Gamma codes group k integers into a group all encoded in a common number of bits, described just once for the whole group
* These are optimal for distributions with like $1 slash n^2$ decay, maybe a log factor depending on which we're talking about
#### Golomb, Rice Codes and Variants
* Choose some divisor $q$ and write $x = q r + b$
* Then encode $q$ in unary, and $b$ in binary
* This is optimal when $x$ is distributed with a geometric distribution

* Rice codes are when you take $b=2^k$ so you divide by a power of two which is fast, and choosing the divisor optimally ends up not mattering so much

* Exponential Golomb, Zeta, and Fibonacci codes are similar ideas of splitting into parts and encoding separately
	* First two are optimal for power law distributions, Fibonacci for decay like $1 slash 2 n^(1.44)$
* Zeta codes are used in web graphs so I'll say what they are:
	* You split the integers into ranges that grow by $2^k$ each time, then encode $x$ by first a bitstring identifying which range it falls in, followed by its binary representation
	* So it's like a Golomb code but instead of relying on division to partition the integers you use windows that grow exponentially in size
	* Apparently they decode fast
#### VByte and variants
* These are byte aligned coding methods (byte granularity instead of bitstrings)
* VByte - try to fit the number in binary in 7 bits, otherwise set the overflow bit and go again on the next byte
	* $abs(C(x)) = ceil(ceil(log_2 (x+1)) slash 8)$ so this is optimal for $P(x) = 1 slash x^(8 slash 7)$
* VarInt-GB uses a control byte to handle the next four integers (which vary in how many bits they need) instead of having each byte carry the continue bit
	* This has some perf issues because the next read location depends on the contents of the previous control byte, that's a serial dependency
	* StreamVByte is VarInt-GB with  the control bytes in their own stream, and plus SIMD
		* So the serial dependency issue is improved because the next read is always just the next location in the control stream
		* Also splitting things makes simd easier although Masked-VByte shows how to do simd for normal VByte
* VarIntG8IU - uses a control byte to handle the next eight bytes, and tells you how many integers fit in there (so we vary the number of integers, and fix the number of bytes)
* SC-Dense is like VByte but more general, assign the integers to either be stop or continue values and adapt to your specific distribution
	* VByte is the case where all the values with the control bit set are continue values, and the rest are stop values
## Integer List Compression
* Assume lists are sorted, don't do delta encoding up front although some get this type of behavior naturally
### Binary Packing
* You split your list into blocks and encode each block together
	* for example you can find the max in the block then use a fixed binary encoding
* The hope is that the lists will be locally similar
	* This is not true for adjacency list deltas I believe
### Simple
* Split your sequence according to some fixed block size (the blocks aren't that big, the survey lists 32 bits as an example), then pack as many integers as possible into that block size
	* So this is basically VarIntG8IU
* Simple9 dedicates 4 bits for control, 28 for data
	* The control bit says how many integers are being packed and how big they are
* There are some tricks to reuse control bit info between controls, relative encoding

* QMX uses 128 or 256 bits for SIMD reasons, and keeps the controls in their own stream (Like StreamVByte but we are fixing the memory size, not the number of integers)
	* And then you apply run length encoding on the stream of selectors (this could actually be a good idea? Does this save a significant amount of memory?)
### PForDelta
* The idea is that blocking is bad when we have really big outliers
* So then let's just find some $k$ such that most of the ints in the block can be encoded with $k$ bits instead of using a real maximum
### Elias-Fano and Variants
* You choose some logarithmically small cutoff $ell = log_2 (U slash n)$ where $U$ is our universe (so all integers considered are at most $U$) and store the low $ell$ bits of the list in their own stream, and then can choose a clever way to encode the remaining bits using the fact we've cut off the low bits
* You can do random access decoding!

* PEF is partitioned Elias-Fano which handles skewed distributions better, there's a two level recursive thing going on that relies on vanilla Elias-Fano

* Roaring is like Elias-Fano but we choose the cutoff size $ell$ differently
* Slicing does some complicated recursive thing inspired by Van Ende Boas trees that somehow corresponds to Elias-Fano but choosing the cutoff such that we adapt better
	* Both Roaring and Slicing were worse than VByte-Delta when I tested, the survey lists them as fast to decode
### Interpolative Codes
* Binary Interpolative Code, BIC
* This one is cool and got the best compression quality in tests
* Encode the middle thing and recurse on the halves, maintaining a lower and upper bound on the values in this range
* Encode the middle thing in $mid - ell - h + 1$ bits
* Not entirely clear on how encoding/decoding works but intervals naturally get encoded with no bits which is possibly why they got good compression quality
### Directly Addressable Approaches
* Directly-Addressable Codes, DAC
* Somehow we reduce the problem to binary ranking and fall back on binary ranking data structures
### Hybrid Approaches
* You can use some statistics to choose to encode different parts with different schemes
* Navigate a space-time tradeoff
### Entropy Coding
* Huffman codes are within $1$ bit of entropy-optimality
	* But they are sloow
* Arithmetic codes are also basically optimal
	* but we need real valued arithmetic
	* There's some idea of considering $(0,1)$ and having each symbol $x$ restrict to a subinterval of size $p(x)$ (so you're encoding the whole list not the individual symbols)
	* In the end you get something sized like $Pi 1/p(x)$ and so each decode is like a binary search over this interval which takes $EE [log_2 1 slash p(x)]$, which is the entropy of the distribution
* ANS is an integer version of arithmetic coding
## Many-List Compression
* Basically the idea is to encode lists relative to each other to take advantage of similarity
* For example you can cluster the lists by similarity, then within a cluster a list is described as a diff from some base list chosen for that cluster
## Decoding
* I sort of glossed over this, but the different schemes are qualitatively different in ways that make decoding unique for each
	* The beta, zeta, gamma, type codes assign each integer $x$ to some code independent of data, whereas Huffman's mapping depends on a learned distribution
		* Huffman builds this table based on frequencies and decoding is doing a lookup on the reverse I think, and there's some way to speed up
		* beta, zeta, gamma codes don't depend on the data but nevertheless it seems like you build a table and do reverse lookups
	* Arithmetic codes, BIC, encode a whole list as a single thing
		* Don't fully understand how the decoding works for these but it is slow
	* The byte aligned codes (VByte and variants) naturally lend themselves to simple decoding schemes that are essentially "do the encoding process in reverse"
		* Because the encoding is defined implicitly by a process rather than some explicit mapping as in the case of beta, zeta, gamma codes or Huffman
		* You might think Huffmann codes should count as defining the mapping via process but there it's like you're filling out a table to later be used in coding, the byte aligned codes literally operate on the data and the mapping is defined as the thing that result
# Okay so what's the takeaway
* Some codes support random access which is neat but I don't see a use for right now
* The different choices of codes have a tradeoff between compression quality and speed
* Why do we care about compressing the adjacency lists in the first place?
	* For Ligra+ the motivation is that we can fit larger graphs into memory
		* Here though, we only load parts of the edge data into memory at a time and we can afford to put really big graphs on SSD anyways
* We care in the Multi-SSD setting because cheap compression lets us move more stuff across our fixed memory bandwidth
	* Recall that for shared memory algorithms it's like the entire graph lives in RAM and the processes are allowed to just go in and read what they need into cache
		* You're then memory bottlenecked when your many CPUs are reading a lot of data because they're working through it too fast
	* In the Multi-SSD setting, only part of the edge data lives in RAM at a time, and so we have two things going on:
		* DMA controllers are bringing in async reads from disk into RAM, which live temporarily and will be overwritten as soon as the CPUs are done with it
		* CPUs are reading from these temporary buffers into cache, like before
		* These two things compete with each other for the same shared memory bandwidth, so it's easier to be memory limited and have CPUs waiting around
			* It's not obvious to me if we'd expect the usage to be balanced between these or not though
* Okay so it's easier for us to be memory-limited
	* Although maybe for very work intensive algorithms this won't be the case
	* Maybe we won't need compression at all!
* So if we're very memory bottlenecked we can get a speedup with codes that get better compression quality even if decoding is slow
* It's tempting to say that we should try to adaptively pick a decoding scheme that's on the pareto frontier
	* but this depends too much on machine config and the specific algorithm to work I think

* I think that probably bfs is the only algorithm that could benefit from a more efficient code, everything else would lean towards just using the byte aligned codes
	* They have compression that's basically competitive, definitely not more than twice the size of any other code, and decode like eight times faster probably