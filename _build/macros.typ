// Vault-wide math macros. The PDF template imports this file; in Obsidian,
// Typst Mate's preamble imports it by absolute path:
//   #import "/Users/peter/Documents/Sync/typesetting/_build/macros.typ": *
// Per-course macros go in _build/tags/<tag>.typ, one-offs in a note's
// frontmatter `definitions:` list.
#let inner(a, b) = $lr(chevron.l #a, #b chevron.r)$
