// Reveal the real names of locked notes once the visitor has unlocked one.
//
// stage.sh titles every locked note "Locked" and writes _site/.locked-titles.tsv (slug <TAB> real
// name). This script, run by build-site.sh after the Quartz build:
//   1. encrypts that list as JSON with the site password, in the encrypted-pages plugin's own
//      format (base64 of salt16 + iv12 + tag16 + AES-256-GCM ciphertext, PBKDF2-SHA256 key), so
//      only someone with the password can read it -> public/static/locked-titles.enc;
//   2. writes the page script public/static/locked-titles.js (no secrets in it);
//   3. adds that script to the <head> of every page.
// usage: SITE_PASSWORD=... node locked-titles.mjs <tsv> <public dir> <url prefix, e.g. /Notes or "">
import { readFileSync, writeFileSync, readdirSync, statSync } from "node:fs"
import { join } from "node:path"
import crypto from "node:crypto"

const [tsv, pub, prefix = ""] = process.argv.slice(2)
const password = process.env.SITE_PASSWORD
const ITERATIONS = 600000 // the plugin's default (quartz.config.yaml: iterations)

const titles = {}
for (const line of readFileSync(tsv, "utf8").split("\n")) {
  const tab = line.indexOf("\t")
  if (tab > 0) titles[line.slice(0, tab)] = line.slice(tab + 1)
}
const count = Object.keys(titles).length
if (count && !password) {
  console.error("locked-titles: locked notes but no SITE_PASSWORD")
  process.exit(1)
}

function encrypt(plaintext) {
  const salt = crypto.randomBytes(16)
  const iv = crypto.randomBytes(12)
  const key = crypto.pbkdf2Sync(password, salt, ITERATIONS, 32, "sha256")
  const cipher = crypto.createCipheriv("aes-256-gcm", key, iv)
  const ct = Buffer.concat([cipher.update(plaintext, "utf8"), cipher.final()])
  return Buffer.concat([salt, iv, cipher.getAuthTag(), ct]).toString("base64")
}

writeFileSync(join(pub, "static", "locked-titles.enc"), count ? encrypt(JSON.stringify(titles)) : "")

// ---- the page script ------------------------------------------------------------------------
const pageScript = `// Shows the real names of locked notes after an unlock (see _site/scripts/locked-titles.mjs).
(() => {
  const PREFIX = ${JSON.stringify(prefix)}
  const ITERATIONS = ${ITERATIONS}
  const CACHE = "locked-titles-map"
  let titles = null
  let loading = null

  function passwords() {
    try { const p = JSON.parse(sessionStorage.getItem("encrypted-pages-passwords") || "[]"); return Array.isArray(p) ? p : [] }
    catch { return [] }
  }

  async function decrypt(b64, password) {
    const data = Uint8Array.from(atob(b64), (c) => c.charCodeAt(0))
    const salt = data.slice(0, 16), iv = data.slice(16, 28), tag = data.slice(28, 44), ct = data.slice(44)
    const withTag = new Uint8Array(ct.length + tag.length); withTag.set(ct); withTag.set(tag, ct.length)
    const base = await crypto.subtle.importKey("raw", new TextEncoder().encode(password), "PBKDF2", false, ["deriveKey"])
    const key = await crypto.subtle.deriveKey({ name: "PBKDF2", salt, iterations: ITERATIONS, hash: "SHA-256" },
      base, { name: "AES-GCM", length: 256 }, false, ["decrypt"])
    return new TextDecoder().decode(await crypto.subtle.decrypt({ name: "AES-GCM", iv }, key, withTag))
  }

  async function load() {
    if (titles) return titles
    try { const c = sessionStorage.getItem(CACHE); if (c) return (titles = JSON.parse(c)) } catch {}
    const pws = passwords()
    if (!pws.length) return null
    if (!loading) loading = (async () => {
      const b64 = (await (await fetch(PREFIX + "/static/locked-titles.enc")).text()).trim()
      if (!b64) return null
      for (const pw of pws) {
        try {
          const map = JSON.parse(await decrypt(b64, pw))
          try { sessionStorage.setItem(CACHE, JSON.stringify(map)) } catch {}
          return (titles = map)
        } catch {}
      }
      return null
    })().finally(() => { loading = null })
    return loading
  }

  // "/Notes/psets/MATH4320/HW1" or "../psets/MATH4320/HW1" -> "psets/MATH4320/HW1"
  function slugOf(href) {
    try {
      let p = decodeURI(new URL(href, location.href).pathname)
      if (PREFIX && p.startsWith(PREFIX + "/")) p = p.slice(PREFIX.length + 1); else p = p.replace(/^\\//, "")
      return p.replace(/\\.html$/, "").replace(/\\/$/, "")
    } catch { return null }
  }

  function apply(map) {
    for (const a of document.querySelectorAll("a[href]")) {
      if (a.textContent.trim() !== "Locked") continue
      const name = map[slugOf(a.getAttribute("href"))]
      if (!name) continue
      // replace only the text, keeping icons and other markup inside the link
      const walker = document.createTreeWalker(a, NodeFilter.SHOW_TEXT)
      for (let n = walker.nextNode(); n; n = walker.nextNode())
        if (n.nodeValue.trim() === "Locked") { n.nodeValue = n.nodeValue.replace("Locked", name); break }
    }
    const here = map[slugOf(location.href)]
    if (here) {
      // the page's own heading only; a hover preview's heading belongs to another page
      for (const h of document.querySelectorAll("h1.article-title"))
        if (!h.closest(".popover") && h.textContent.trim() === "Locked") h.textContent = here
      if (document.title.trim() === "Locked") document.title = here
    }
  }

  let timer = null
  function update() {
    clearTimeout(timer)
    timer = setTimeout(async () => { const map = await load(); if (map) apply(map) }, 50)
  }

  document.addEventListener("nav", update)
  document.addEventListener("render", update)
  new MutationObserver(update).observe(document.documentElement, { childList: true, subtree: true })
  update()
})()
`
writeFileSync(join(pub, "static", "locked-titles.js"), pageScript)

// ---- add the script to every page -----------------------------------------------------------
const tag = `<script src="${prefix}/static/locked-titles.js" defer></script>`
let pages = 0
function walk(dir) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name)
    if (statSync(p).isDirectory()) walk(p)
    else if (name.endsWith(".html")) {
      const html = readFileSync(p, "utf8")
      if (html.includes("locked-titles.js") || !html.includes("</head>")) continue
      writeFileSync(p, html.replace("</head>", tag + "</head>"))
      pages++
    }
  }
}
walk(pub)
console.log(`locked-titles: ${count} name(s) encrypted, script added to ${pages} page(s)`)
