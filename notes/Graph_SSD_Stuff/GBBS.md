# High Level Summary
* Builds on [Ligra, Ligra+](Ligra,%20Ligra+.md) with more primitives and many examples
	* Obs: oftentimes edgemap reuses the frontier, so let's have primitives for that case (I think this is what's meant)
	* Also add more functional primitives, not just map, for better expressibility
	* Uses bucketing from Julienne
	* Maybe can be used for clustering? Not on the website
* Some algorithms apparently require deletions from graph data? so you actually modify it? or is it just that you're taking a subgraph
	* 