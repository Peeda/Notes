// WORKAROUND PROTOTYPE — not part of the supported pipeline.
//
// Loaded with `node --import` (see scripts/build-site.sh, enabled by QUARTZ_TYPST_WORKAROUND=1).
// The Quartz latex plugin passes `typstOptions` to @myriaddreamin/rehype-typst, which ignores every
// option except `errorColor`: there is no supported way to give the Typst renderer a preamble.
// This monkeypatches NodeCompiler.prototype.compile (the copy rehype-typst actually loads) to:
//   1. prepend the contents of $TYPST_PREAMBLE_FILE (e.g. _build/macros.typ) to every equation
//      document, so `ip(u, v)`, `Var`, ... resolve;
//   2. throw on compile errors. rehype-typst <= 0.7 returns `{}` on error and then crashes the whole
//      page with "Spread syntax requires ...iterable"; throwing instead lands in its own try/catch,
//      which renders the raw source in a red <span class="typst-error">.
import { createRequire } from "node:module"
import { readFileSync } from "node:fs"
import path from "node:path"

const quartzDir = process.env.QUARTZ_DIR
const preambleFile = process.env.TYPST_PREAMBLE_FILE
if (!quartzDir) throw new Error("typst-preamble.mjs: QUARTZ_DIR not set")

// Resolve exactly as the latex plugin does: plugin dist -> rehype-typst -> compiler
const fromPlugin = createRequire(path.join(quartzDir, ".quartz/plugins/latex/dist/index.js"))
const rehypeTypstEntry = fromPlugin.resolve("@myriaddreamin/rehype-typst")
const fromRehype = createRequire(rehypeTypstEntry)
const { NodeCompiler } = fromRehype("@myriaddreamin/typst-ts-node-compiler")

// Leading `#let`s produce no content, so the page size / baseline measurement is unaffected.
const preamble = preambleFile ? readFileSync(preambleFile, "utf8") + "\n" : ""

const compile = NodeCompiler.prototype.compile
NodeCompiler.prototype.compile = function (opts) {
  const patched =
    opts && typeof opts.mainFileContent === "string"
      ? { ...opts, mainFileContent: preamble + opts.mainFileContent }
      : opts
  const res = compile.call(this, patched)
  if (!res.result) {
    const diags = this.fetchDiagnostics(res.takeDiagnostics())
    throw new Error(diags.map((d) => d.message).join("; ") || "typst compile failed")
  }
  return res
}
