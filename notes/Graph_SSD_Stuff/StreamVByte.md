# Motivation
* We're doing compression of unsigned integers where we care about speed
* Regime where CPU work is so fast that memory bandwidth is the bottleneck
	* If we can compress and decompress integers, we can move more
	* So we care both about compression quality as well as encode/decode speed
* In cases where the data is sorted we do delta encoding to reduce the magnitudes
	* We can then prefix sum quickly using simd after decoding
# Existing Schemes
* vbyte/varint - Each integer gets a variable number of bytes
	* A single byte describes as much as it can, then passes of to the next
	* So the msb is reserved as a continue bit
	* Branch prediction on every byte, predicting whether to continue
* varint-GB - Consider blocks of four integers with varying block size
	* So now instead of a continue bit we have a single control byte
	* We then do a table lookup on the control byte for every four ints decoded
	* But there's a data dependency:
		* We don't know where to read the next control until the first is read from ram
* varint-G8IU - Fix the block size, and vary the number of integers
	* This one is very fast, fixed block sizes give good perf
	* somewhat wasteful though if you have many big ints, but if they're all one byte I think it's more compact
* StreamVByte - Do varint-GB but move the control bytes out into their own stream
	* This gives better perf than varint-GB and slightly better than varint-G8IU
	* You've eliminated the data dependency
# SIMD
* Table lookups on the control byte give back a 16 byte shuffle
* This is then used with a SIMD shuffle instruction to decode four integers
	* varint-GB and StreamVByte share a shuffle scheme
		* We want to decode four integers that live in at most the next 16 (I think?) bytes
		* So we first read the next 16 bytes (this overreads but that's fine)
		* Then we perform a simd shuffle to move the prefix of the read, the useful stuff, into the corresponding lanes of four bytes each, decoding four integers
	* maskedVByte gives a way to make VByte work with SIMD
		* We have no control byte, so instead do a 16 byte read and collect the msbs
		* Use that to index a shuffle lookup table, shuffle, then clean up to ignore msbs
	* varint-G8IU needs two shuffles
		* Here we have a fixed 8 byte block and we want to extract a variable number of ints
		* It's more complicated because if the block is maximally dense you need two shuffles

## TODO - Connect back to [Ligra, Ligra+](Ligra,%20Ligra+.md)
* Think about run length encoding, are there similar tricks to be done in the graph setting?
* It seems that graph algorithms don't benefit from faster decoding since random reads or IOs will be the bottleneck?
	* Oh yeah so the CPU is waiting so much that we can waste cycles on expensive decoding and still be waiting for memory
* So then the calculus shifts towards just compression quality
	* But it seems like real world graph compression is well studied and it's just rle?