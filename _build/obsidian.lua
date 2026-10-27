-- Obsidian Markdown -> Typst. Three passes, run in order (see the bottom):
--   1. embeds:  `![](other.md)` is replaced by that note's body, recursively;
--               frontmatter `tags:`/`definitions:` of every included note
--               become `#import`/`#let` lines at the top.
--   1b. proofs: open-form proofs (`*Proof.* ... ∎`) become `> [!proof]`.
--   1c. todos:  `> [!todo]` callouts become `#todo-box` and are listed for
--               the "Open TODOs" table (on for papers, `todo-table:` elsewhere).
--   2. labels:  Obsidian block IDs (`^id` on its own line after a callout,
--               or right after a `$$` block) become Typst labels.
--   3. convert: math, links/references, callouts -> environments.
--   4. todo table: the collected todos go to the template as `todo-table`.

-- Keep in sync with FROM in build.sh
local FROM = "markdown+wikilinks_title_after_pipe+lists_without_preceding_blankline-blank_before_blockquote-latex_macros-raw_tex"
local VAULT = pandoc.path.directory(pandoc.path.directory(PANDOC_SCRIPT_FILE))
local TAGS_DIR = "_build/tags"  -- Typst Mate: Import path = _build

local envs = { theorem=1, lemma=1, definition=1, problem=1,
               remark=1, proof=1, solution=1 }
local numbered_envs = { theorem=1, lemma=1, definition=1, problem=1 }
-- Link text that asks for a numbered reference ("Lemma 2.1") instead of a
-- plain link with the given text.
local ref_words = { theorem=1, lemma=1, definition=1, problem=1,
                    section=1, lecture=1, chapter=1, exercise=1,
                    equation=1, eq=1, ["eq."]=1 }

local included = {}   -- absolute path -> true, for every note in this build
local note_labels = {} -- absolute path -> label placed at the note's start
local doc_type = "note"
local todo_on = false
local todos = {}      -- { id, where = Inlines, text = Inlines }, in order
local preamble = {}   -- the `#import`/`#let` lines put above the body
local labels = {}     -- label -> true if it can be #ref'd, false if only linked
local headings = {}   -- normalized heading text -> identifier

-- helpers --------------------------------------------------------------------

local function url_decode(s)
  return (s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

local function has_scheme(t) return t:match("^%a[%w+.-]*:") ~= nil end

-- join + normalize, resolving "." and ".."
local function resolve(dir, rel)
  local path = rel:sub(1, 1) == "/" and rel or (dir .. "/" .. rel)
  local parts = {}
  for part in path:gmatch("[^/]+") do
    if part == ".." then table.remove(parts)
    elseif part ~= "." then table.insert(parts, part) end
  end
  return "/" .. table.concat(parts, "/")
end

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local src = f:read("a"); f:close()
  return src
end

local function unquote(item)
  local q = item:match("^'(.*)'$")
  if q then return (q:gsub("''", "'")) end
  return item:match('^"(.*)"$') or item
end

-- Items of a frontmatter list, read from the raw text (Pandoc would parse the
-- `$...$` in metadata as Markdown). Supports `key: [a, b]`, `key: a` and a
-- block list of plain or 'quoted' items.
local function fm_items(src, key)
  local fm = src:match("^%-%-%-\r?\n(.-)\r?\n%-%-%-")
  local items, inside = {}, false
  for line in (fm or ""):gmatch("[^\r\n]+") do
    local rest = line:match("^" .. key .. ":%s*(.-)%s*$")
    if rest then
      inside = rest == ""
      local flow = rest:match("^%[(.*)%]$")
      for item in (flow or rest):gmatch("[^,]+") do
        item = unquote(item:match("^%s*(.-)%s*$"))
        if item ~= "" then table.insert(items, item) end
      end
    elseif inside then
      local item = line:match("^%s+%-%s+(.-)%s*$")
      if item then table.insert(items, unquote(item))
      elseif not line:match("^%s*#") then inside = false end
    end
  end
  return items
end

local function normalize(s) return (s:lower():gsub("[^%w]", "")) end

-- pass 1: embeds -------------------------------------------------------------

-- Make a note's relative links absolute (filesystem paths) and its images
-- vault-absolute (Typst --root is the vault), so they survive being embedded
-- into a note in another folder.
local function rebase(blocks, dir)
  return blocks:walk {
    Link = function(el)
      if has_scheme(el.target) or el.classes:includes("wikilink") then return end
      local path, frag = el.target:match("^([^#]*)(#?.*)$")
      if path ~= "" then el.target = resolve(dir, url_decode(path)) .. frag; return el end
    end,
    Image = function(el)
      if has_scheme(el.src) then return end
      local path = resolve(dir, url_decode(el.src))
      -- embeds (whole notes or one block) keep the filesystem path;
      -- expand_embeds reads them
      local note = path:match("%.md$") or path:match("%.md#")
      el.src = note and path or "/" .. pandoc.path.make_relative(path, VAULT)
      return el
    end,
  }
end

-- Source-level fixes before Pandoc parses a note (outside frontmatter and
-- code fences):
--  * drop Obsidian `%% comments %%` (inline or spanning lines);
--  * Obsidian starts a heading or a (deeper) quote/callout right after a line
--    of text (or a quote), where Pandoc would fold it into the paragraph,
--    list item or quote above: insert the blank line Pandoc wants (a bare
--    `>` inside a quote).
local function quote_depth(line)
  local markers = line:match("^[> ]*"):gsub(" ", "")
  return #markers
end

-- returns the line without comments, and whether a comment is still open
local function strip_comments(line, open)
  local kept, rest = "", line
  while true do
    local s, e = rest:find("%%", 1, true)
    if not s then
      if not open then kept = kept .. rest end
      return kept, open
    end
    if not open then kept = kept .. rest:sub(1, s - 1) end
    open = not open
    rest = rest:sub(e + 1)
  end
end

local function preprocess(src)
  local lines = {}
  for line in (src .. "\n"):gmatch("(.-)\r?\n") do table.insert(lines, line) end
  local out, n = {}, 1
  if lines[1] == "---" then  -- frontmatter: copy verbatim
    repeat
      table.insert(out, lines[n]); n = n + 1
    until n > #lines or lines[n - 1]:match("^%-%-%-$") and n > 2 or lines[n - 1] == "..."
  end
  local prev, fence, comment = "", nil, false
  for i = n, #lines do
    local line = lines[i]
    local f = line:match("^%s*(```+)") or line:match("^%s*(~~~+)")
    if fence or f then
      if fence and f and f:sub(1, 1) == fence:sub(1, 1) then fence = nil
      elseif not fence then fence = f end
      table.insert(out, line)
    else
      local stripped
      stripped, comment = strip_comments(line, comment)
      -- a line that was only a comment disappears (no blank line left behind)
      if stripped:match("%S") or not line:match("%S") then
        line = stripped
        if prev:match("%S") then
          local d, pd = quote_depth(line), quote_depth(prev)
          local prev_text = prev:gsub("^[> ]*", "") ~= ""
          if d == 0 and line:match("^#+ ") then
            table.insert(out, "")
          elseif d > pd and prev_text then
            table.insert(out, string.rep(">", pd))
          end
        end
        table.insert(out, line)
      end
    end
    prev = out[#out] or ""
  end
  return table.concat(out, "\n")
end

local function read_note(text)
  return pandoc.read(preprocess(text), FROM, PANDOC_READER_OPTIONS)
end

local function embed_src(block)
  local inl = (block.t == "Para" or block.t == "Plain") and block.content
  if block.t == "Figure" and #block.content == 1 then inl = block.content[1].content end
  if not inl or #inl ~= 1 or inl[1].t ~= "Image" then return nil end
  local src = inl[1].src
  if has_scheme(src) then return nil end
  return src
end

local function embed_target(block)
  local src = embed_src(block)
  return src and src:match("%.md$") and src or nil
end

-- `![](note.md#^id)`: Obsidian shows that one block (a paper's proof note
-- previews the statement it proves)
local function partial_embed(block)
  local src = embed_src(block)
  return src ~= nil and src:match("%.md#") ~= nil
end

-- The PDF restates the callout that `![](note.md#^id)` points to, as course
-- notes put a theorem's box right above its proof; anything else is left
-- out. The copy keeps its number but drops its `^id`s, so labels stay unique.
local function restated(src)
  local path, id = src:match("^(.-%.md)#%^([%w_-]+)$")
  local text = path and read_file(path)
  if not text then return nil end
  local blocks = read_note(text).blocks
  for i = 2, #blocks do
    local p = blocks[i]
    if p.t == "Para" and #p.content == 1 and p.content[1].t == "Str"
       and p.content[1].text == "^" .. id and blocks[i - 1].t == "BlockQuote" then
      return rebase(pandoc.Blocks{ blocks[i - 1]:clone() }, pandoc.path.directory(path)):walk {
        Inlines = function(inl)
          local out = pandoc.Inlines{}
          for _, x in ipairs(inl) do
            if not (x.t == "Str" and x.text:match("^%^[%w_-]+$")) then out:insert(x) end
          end
          return out
        end,
      }
    end
  end
end

-- the label a link to the whole note (`[Proof](Proofs/B.1 Foo.md)`) points to
local function note_label(path)
  local name = pandoc.path.filename(path):gsub("%.md$", ""):lower()
  local id = "note-" .. (name:gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", ""))
  note_labels[path] = id
  labels[id] = false
  return pandoc.RawBlock("typst", "#metadata(none) <" .. id .. ">")
end

-- paper numbers ("B.10", "D.2") in reading order: letter, then each number
local function number_parts(s)
  local parts = { s:match("^(%a*)") }
  for n in s:gmatch("%d+") do table.insert(parts, tonumber(n)) end
  return parts
end

local function number_less(a, b)
  local x, y = number_parts(a), number_parts(b)
  if x[1] ~= y[1] then return x[1] < y[1] end
  for i = 2, math.max(#x, #y) do
    local p, q = x[i] or -1, y[i] or -1
    if p ~= q then return p < q end
  end
  return false
end

-- the overview's own heading for section B (`# B Title`, `# Section B - ...`),
-- or "Section B: ..." for a `# B. ...` one, or just "Section B"
local function section_title(blocks, letter)
  local t = pandoc.Inlines{ pandoc.Str("Section"), pandoc.Space(), pandoc.Str(letter) }
  for _, b in ipairs(blocks) do
    local c = b.t == "Header" and b.level == 1 and b.content
    if c and c[1] and c[1].t == "Str" and (c[1].text == letter or c[1].text == "Section"
       and c[3] and c[3].t == "Str" and c[3].text:match("^" .. letter .. "%W?$")) then
      return c:clone()
    elseif c and c[1] and c[1].t == "Str" and c[1].text == letter .. "." then
      t[#t] = pandoc.Str(letter .. ":")
      for i = 2, #c do t:insert(c[i]) end
      break
    end
  end
  return t
end

local function expand_embeds(doc)
  local cwd = pandoc.system.get_working_directory()
  local main = resolve(cwd, PANDOC_STATE.input_files[1])
  local tags, defs, seen = {}, {}, {}
  local function collect(src)
    for _, t in ipairs(fm_items(src, "tags")) do
      t = t:gsub("^#", "")
      if not seen["t" .. t] then seen["t" .. t] = 1; table.insert(tags, t) end
    end
    for _, d in ipairs(fm_items(src, "definitions")) do
      if not seen["d" .. d] then seen["d" .. d] = 1; table.insert(defs, d) end
    end
  end

  local function expand(blocks, stack)
    local out = pandoc.Blocks{}
    for _, b in ipairs(blocks) do
      local src = embed_target(b)
      if partial_embed(b) then
        out:extend(restated(embed_src(b)) or {})
      elseif src then
        -- rebase() already made it absolute
        local path = src
        if stack[path] then error("embed cycle at " .. path) end
        local text = read_file(path) or error("embedded note not found: " .. path)
        included[path] = true
        collect(text)
        local sub = read_note(text).blocks
        stack[path] = true
        out:insert(note_label(path))
        out:extend(expand(rebase(sub, pandoc.path.directory(path)), stack))
        stack[path] = nil
      else
        out:insert(b)
      end
    end
    return out
  end

  included[main] = true
  local main_src = read_file(main) or ""
  collect(main_src)
  -- re-read the note itself through preprocess() (Pandoc's own parse lacks it)
  local dir = pandoc.path.directory(main)
  local blocks = rebase(read_note(main_src).blocks, dir)

  -- a course or book index with no embeds of its own includes every note in
  -- its folder whose name starts with a number (01 Groups.md, 02 ...), in order
  local has_embeds = false
  for _, b in ipairs(blocks) do has_embeds = has_embeds or embed_target(b) ~= nil end
  local main_type = fm_items(main_src, "type")[1]
  doc_type = main_type or "note"
  local todo_fm = fm_items(main_src, "todo-table")[1]
  todo_on = todo_fm == "true" or (todo_fm == nil and main_type == "paper")
  if main_type == "paper" and not has_embeds then
    -- a paper's overview is followed by a "Proofs" appendix: every note in
    -- Proofs/ named by its paper number (B.1 Foo.md), grouped by section
    local pdir = dir .. "/Proofs"
    local ok, names = pcall(pandoc.system.list_directory, pdir)
    local proofs = {}
    for _, name in ipairs(ok and names or {}) do
      local n = name:match("^(%u[%.%d]*)%s.*%.md$")
      if n then table.insert(proofs, { n = n, name = name }) end
    end
    table.sort(proofs, function(a, b) return number_less(a.n, b.n) end)
    if #proofs > 0 then
      local overview = blocks:clone()
      blocks:insert(pandoc.RawBlock("typst", "#pagebreak(weak: true)"))
      blocks:insert(pandoc.Header(1, "Proofs", pandoc.Attr("proofs")))
      local letter
      for _, p in ipairs(proofs) do
        if p.n:sub(1, 1) ~= letter then
          letter = p.n:sub(1, 1)
          blocks:insert(pandoc.Header(2, section_title(overview, letter),
            pandoc.Attr("proofs-" .. letter:lower())))
        end
        blocks:insert(pandoc.Para{ pandoc.Image({}, pdir .. "/" .. p.name) })
      end
    end
  elseif (main_type == "course" or main_type == "book") and not has_embeds then
    local lectures = {}
    for _, name in ipairs(pandoc.system.list_directory(dir)) do
      local n = name:match("^(%d+).*%.md$")
      if n then table.insert(lectures, { tonumber(n), name }) end
    end
    table.sort(lectures, function(a, b) return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2]) end)
    for _, l in ipairs(lectures) do
      -- a book's chapters keep the book's numbers (05 Modules.md is
      -- Chapter 5), even when chapters are skipped
      if main_type == "book" then
        blocks:insert(pandoc.RawBlock("typst", "#counter(heading).update(" .. (l[1] - 1) .. ")"))
      end
      blocks:insert(pandoc.Para{ pandoc.Image({}, dir .. "/" .. l[2]) })
    end
  end
  doc.blocks = expand(blocks, { [main] = true })
  doc.blocks:insert(1, note_label(main))

  local head = pandoc.Blocks{}
  for _, t in ipairs(tags) do
    local rel = TAGS_DIR .. "/" .. t:gsub("/", ".") .. ".typ"
    if read_file(VAULT .. "/" .. rel) then
      table.insert(preamble, '#import "/' .. rel .. '": *')
    end
  end
  for _, d in ipairs(defs) do table.insert(preamble, "#let " .. d) end
  for _, line in ipairs(preamble) do head:insert(pandoc.RawBlock("typst", line)) end
  head:extend(doc.blocks)
  doc.blocks = head
  return doc
end

-- pass 1b: open-form proofs --------------------------------------------------
-- A paragraph starting with an emphasized "Proof" (`*Proof.*`,
-- `*Proof of [Lemma](#^id).*`, same for "Solution") starts a proof. It runs
-- through the first paragraph ending in ∎/□, or up to the next heading,
-- theorem-like callout or proof. It is rewritten as a `> [!proof]` callout,
-- which pass 3 turns into the environment.

local function proof_start(b)
  if b.t ~= "Para" or not b.content[1] or b.content[1].t ~= "Emph" then return nil end
  local em = b.content[1].content
  local first = em[1] and em[1].t == "Str" and em[1].text
  local kind = first and first:match("^(Proof)%.?:?$") or first and first:match("^(Solution)%.?:?$")
  if not kind then return nil end
  -- title: the emphasized words after "Proof", minus a trailing "." or ":"
  local title = pandoc.Inlines{}
  for i = 2, #em do title:insert(em[i]) end
  while title[1] and title[1].t == "Space" do title:remove(1) end
  local last = title[#title]
  if last and last.t == "Str" then
    last.text = last.text:gsub("[.:]$", "")
    if last.text == "" then title:remove(#title) end
  end
  local body = pandoc.Inlines{}
  for i = 2, #b.content do body:insert(b.content[i]) end
  if body[1] and body[1].t == "Str" then body[1].text = body[1].text:gsub("^[.:]", "") end
  while body[1] and (body[1].t == "Space" or (body[1].t == "Str" and body[1].text == "")) do body:remove(1) end
  return kind:lower(), title, body
end

-- strip a trailing ∎/□ from a paragraph; true if there was one
local function strip_qed(b)
  if b.t == "BulletList" or b.t == "OrderedList" then  -- ∎ after the last item
    local item = b.content[#b.content]
    return item ~= nil and #item > 0 and strip_qed(item[#item])
  end
  if b.t ~= "Para" and b.t ~= "Plain" then return false end
  local last = b.content[#b.content]
  if not last or last.t ~= "Str" then return false end
  local text
  for _, qed in ipairs({ "∎", "□" }) do  -- multibyte: no Lua character class
    if last.text:sub(-#qed) == qed then text = last.text:sub(1, -#qed - 1) end
  end
  if not text then return false end
  if text == "" then b.content:remove(#b.content) else last.text = text end
  while #b.content > 0 and (b.content[#b.content].t == "Space"
        or b.content[#b.content].t == "SoftBreak") do b.content:remove(#b.content) end
  return true
end

local function ends_proof(b)
  if b.t == "Header" or b.t == "HorizontalRule" then return true end
  local kind = b.t == "BlockQuote" and b.content[1] and b.content[1].t == "Para"
    and b.content[1].content[1] and b.content[1].content[1].t == "Str"
    and b.content[1].content[1].text:match("^%[!([%w-]+)%]")
  return (kind and envs[kind:lower()]) or proof_start(b) ~= nil
end

local function group_proofs(doc)
  local blocks, out, i = doc.blocks, pandoc.Blocks{}, 1
  while i <= #blocks do
    local kind, title, body = proof_start(blocks[i])
    if not kind then
      out:insert(blocks[i]); i = i + 1
    else
      local head = pandoc.Inlines{ pandoc.Str("[!" .. kind .. "]") }
      if #title > 0 then head:insert(pandoc.Space()); head:extend(title) end
      local first = pandoc.Para(body)
      local done = strip_qed(first)
      head:insert(pandoc.SoftBreak()); head:extend(first.content)
      local inner = pandoc.Blocks{ pandoc.Para(head) }
      i = i + 1
      while not done and i <= #blocks and not ends_proof(blocks[i]) do
        local b = blocks[i]
        done = strip_qed(b)
        if not ((b.t == "Para" or b.t == "Plain") and #b.content == 0) then inner:insert(b) end
        i = i + 1
      end
      out:insert(pandoc.BlockQuote(inner))
    end
  end
  doc.blocks = out
  return doc
end

-- pass 1c: todos ------------------------------------------------------------
-- `> [!todo] text` becomes `#todo-box[text] <todo-N>`, wherever it sits (in a
-- proof, a list item, another callout). Each is recorded with where it is: the
-- proof it is in ("Proof of Lemma B.1"), else the heading above it.

local function callout_tag(b)
  local p = b.t == "BlockQuote" and b.content[1]
  local tag = p and p.t == "Para" and p.content[1]
  return tag and tag.t == "Str" and tag.text:match("^%[!([%w-]+)%][+-]?$")
end

-- the inlines of a callout's first line after its `[!kind]` tag
local function callout_title(b)
  local t = pandoc.Inlines{}
  local p = b.content[1].content
  for i = 2, #p do
    if p[i].t == "SoftBreak" or p[i].t == "LineBreak" then break end
    t:insert(p[i])
  end
  while t[1] and t[1].t == "Space" do t:remove(1) end
  return t
end

local function mark_todos(doc)
  local where = pandoc.Inlines{}
  local function walk(blocks)
    local out = pandoc.Blocks{}
    for _, b in ipairs(blocks) do
      local kind = callout_tag(b)
      kind = kind and kind:lower()
      if b.t == "Header" then
        where = b.content:clone()
        out:insert(b)
      elseif kind == "todo" then
        local text = pandoc.Inlines{}
        local p = b.content[1].content
        for i = 2, #p do text:insert(p[i]) end
        while text[1] and (text[1].t == "Space" or text[1].t == "SoftBreak") do text:remove(1) end
        local id = "todo-" .. (#todos + 1)
        table.insert(todos, { id = id, where = where:clone(), text = text:clone() })
        labels[id] = false
        out:insert(pandoc.RawBlock("typst", "#todo-box["))
        if #text > 0 then out:insert(pandoc.Para(text)) end
        for k = 2, #b.content do out:insert(b.content[k]) end
        out:insert(pandoc.RawBlock("typst", "] <" .. id .. ">"))
      elseif b.t == "BlockQuote" then
        local saved = where
        if kind == "proof" or kind == "solution" then
          local title = callout_title(b)
          local name = kind:sub(1, 1):upper() .. kind:sub(2)
          if #title > 0 then
            where = pandoc.Inlines{ pandoc.Str(name), pandoc.Space() }
            where:extend(title)
          else
            where = pandoc.Inlines{ pandoc.Str(name), pandoc.Space(), pandoc.Str("in") , pandoc.Space() }
            where:extend(saved)
          end
        end
        b.content = walk(b.content)
        where = saved
        out:insert(b)
      elseif b.t == "BulletList" or b.t == "OrderedList" then
        for i, item in ipairs(b.content) do b.content[i] = walk(item) end
        out:insert(b)
      elseif b.t == "Div" then
        b.content = walk(b.content)
        out:insert(b)
      else
        out:insert(b)
      end
    end
    return out
  end
  doc.blocks = walk(doc.blocks)
  return doc
end

-- pass 2: block IDs -> labels ------------------------------------------------

local LABEL_MARK = "obsidian-label"

local function block_id(b)
  if b.t ~= "Para" or #b.content ~= 1 or b.content[1].t ~= "Str" then return nil end
  return b.content[1].text:match("^%^([%w_-]+)$")
end

local function callout_kind(b)
  if b.t ~= "BlockQuote" then return nil end
  local p = b.content[1]
  local tag = p and p.t == "Para" and p.content[1]
  return tag and tag.t == "Str" and tag.text:match("^%[!([%w-]+)%][+-]?$")
end

local function attach_labels(doc)
  local heading_numbering = doc.meta["heading-numbering"]
  local numbered_headings = not (heading_numbering
    and pandoc.utils.stringify(heading_numbering) == "none")
  doc = doc:walk {
    -- `$$ ... $$` followed by `^id` (same paragraph, possibly with more
    -- equations after it) -> labelled equation; a trailing `^id` anywhere
    -- else is dropped (Typst can't label a paragraph)
    Inlines = function(inl)
      -- a lone `^id` paragraph is handled by Blocks below
      if #inl == 1 then return nil end
      local out = pandoc.Inlines{}
      for i, x in ipairs(inl) do
        local id = x.t == "Str" and x.text:match("^%^([%w_-]+)$")
        local j = #out
        while j > 0 and (out[j].t == "Space" or out[j].t == "SoftBreak") do j = j - 1 end
        local m = out[j]
        if id and m and m.t == "Math" and m.mathtype == "DisplayMath" then
          for _ = j + 1, #out do out:remove(#out) end
          out[j] = pandoc.RawInline("typst", "$ " .. m.text .. " $ <" .. id .. ">")
          labels[id] = true
        elseif id and i == #inl then
          while #out > 0 and (out[#out].t == "Space" or out[#out].t == "SoftBreak") do out:remove(#out) end
        else
          out:insert(x)
        end
      end
      return out
    end,
    -- `^id` paragraph right after a callout -> label on its environment
    Blocks = function(blocks)
      local out = pandoc.Blocks{}
      for _, b in ipairs(blocks) do
        local id = block_id(b)
        local prev = out[#out]
        local kind = id and prev and callout_kind(prev)
        if kind and envs[kind:lower()] then
          prev.content:insert(pandoc.RawBlock(LABEL_MARK, id))
          labels[id] = numbered_envs[kind:lower()] ~= nil
        elseif not id then
          out:insert(b)
        end
      end
      return out
    end,
    Header = function(h)
      headings[normalize(pandoc.utils.stringify(h.content))] = h.identifier
      labels[h.identifier] = numbered_headings
    end,
  }
  return doc
end

-- pass 3: convert ------------------------------------------------------------

-- Math: Pandoc stores $...$ verbatim; emit it as raw Typst
local function Math(el)
  if el.mathtype == "DisplayMath" then
    return pandoc.RawInline("typst", "$ " .. el.text .. " $")
  end
  return pandoc.RawInline("typst", "$" .. el.text .. "$")
end

local function find_included(name)
  for path in pairs(included) do
    if pandoc.path.filename(path):gsub("%.md$", "") == name then return path end
  end
end

-- Links into this build (`#^id`, `note.md#^id`, `#Heading`, wikilinks)
-- -> #ref / #link; links to other notes -> plain text; URLs unchanged.
local function Link(el)
  local target = el.target
  if has_scheme(target) then return nil end
  local path, frag = target:match("^([^#]*)#?(.*)$")
  frag = url_decode(frag)
  if el.classes:includes("wikilink") then
    if path ~= "" then
      path = find_included(path)
      if not path then return el.content end
    end
  end
  if path ~= "" and not included[path] then return el.content end
  if path ~= "" and frag == "" and note_labels[path] then
    local out = pandoc.Inlines{ pandoc.RawInline("typst", "#link(<" .. note_labels[path] .. ">)[") }
    out:extend(el.content)
    out:insert(pandoc.RawInline("typst", "]"))
    return out
  end
  local id
  if frag:sub(1, 1) == "^" then id = frag:sub(2)
  elseif frag ~= "" then id = headings[normalize(frag)] end
  if not id or labels[id] == nil then
    if frag ~= "" then io.stderr:write("obsidian.lua: no target for link #" .. frag .. "\n") end
    return el.content
  end
  local text = pandoc.utils.stringify(el.content)
  if labels[id] and (text == "" or ref_words[text:lower()]) then
    return pandoc.RawInline("typst", "#ref(<" .. id .. ">)")
  end
  local out = pandoc.Inlines{ pandoc.RawInline("typst", "#link(<" .. id .. ">)[") }
  out:extend(el.content)
  out:insert(pandoc.RawInline("typst", "]"))
  return out
end

-- Callouts -> #theorem(title: [...])[ ... ] <label>
local function BlockQuote(el)
  local label = ""
  local lastb = el.content[#el.content]
  if lastb and lastb.t == "RawBlock" and lastb.format == LABEL_MARK then
    label = " <" .. lastb.text .. ">"
    el.content:remove(#el.content)
  end
  local p = el.content[1]
  if not p or p.t ~= "Para" then return nil end
  local tag = p.content[1]
  if not tag or tag.t ~= "Str" then return nil end
  local kind = tag.text:match("^%[!([%w-]+)%][+-]?$")
  if not kind then return nil end
  kind = kind:lower()

  local title, body, i = pandoc.Inlines{}, pandoc.Inlines{}, 2
  while i <= #p.content and p.content[i].t ~= "SoftBreak"
        and p.content[i].t ~= "LineBreak" do
    title:insert(p.content[i]); i = i + 1
  end
  for j = i + 1, #p.content do body:insert(p.content[j]) end
  -- a paper numbers its results by hand: `> [!lemma] B.3 Title` -> "Lemma B.3"
  local number
  if doc_type == "paper" and numbered_envs[kind] then
    while title[1] and title[1].t == "Space" do title:remove(1) end
    number = title[1] and title[1].t == "Str" and title[1].text:match("^(%u?%.?[%d.]*%d)%.?$")
    if number then
      title:remove(1)
      while title[1] and title[1].t == "Space" do title:remove(1) end
    end
  end
  local has_title = pandoc.utils.stringify(title):match("%S")

  -- Other callout types (note, tip, warning, ...): plain quote with a bold
  -- heading, so the "[!note]" marker never leaks into the PDF.
  if not envs[kind] then
    local head = pandoc.Inlines{}
    if has_title then
      head:extend(title)
      while head[1] and head[1].t == "Space" do head:remove(1) end
    else
      head:insert(pandoc.Str(kind:sub(1, 1):upper() .. kind:sub(2)))
    end
    local blocks = pandoc.Blocks{ pandoc.Para({ pandoc.Strong(head) }) }
    if #body > 0 then blocks:insert(pandoc.Para(body)) end
    for k = 2, #el.content do blocks:insert(el.content[k]) end
    return pandoc.BlockQuote(blocks)
  end

  local head = "#" .. kind
  local args = {}
  if number then table.insert(args, 'number: "' .. number .. '"') end
  if has_title then
    local t = pandoc.write(pandoc.Pandoc{pandoc.Plain(title)}, "typst")
    table.insert(args, "title: [" .. (t:gsub("^%s+", ""):gsub("%s+$", "")) .. "]")
  end
  if #args > 0 then head = head .. "(" .. table.concat(args, ", ") .. ")" end
  head = head .. "["

  local out = pandoc.Blocks{}
  if #body > 0 then
    body:insert(1, pandoc.RawInline("typst", head))
    out:insert(pandoc.Para(body))
  else
    out:insert(pandoc.RawBlock("typst", head))
  end
  for k = 2, #el.content do out:insert(el.content[k]) end

  local last = out[#out]
  if last.t == "Para" or last.t == "Plain" then
    last.content:insert(pandoc.RawInline("typst", "]" .. label))
  else
    out:insert(pandoc.RawBlock("typst", "]" .. label))
  end
  return out
end

-- pass 4: todo table ---------------------------------------------------------
-- Rows for `#todo-table` in the template: (label, where, text), converted the
-- same way as the body. The table comes before the body, so it repeats the
-- body's imports for its math.
local function todo_table(doc)
  if not todo_on or #todos == 0 then return nil end
  local function typst(inl)
    local conv = pandoc.Inlines(inl):walk { Math = Math, Link = Link }
    local t = pandoc.write(pandoc.Pandoc{ pandoc.Plain(conv) }, "typst")
    return (t:gsub("^%s+", ""):gsub("%s+$", ""))
  end
  local rows = {}
  for _, t in ipairs(todos) do
    table.insert(rows, "  (<" .. t.id .. ">, [" .. typst(t.where) .. "], [" .. typst(t.text) .. "]),")
  end
  doc.meta["todo-table"] = pandoc.MetaBlocks{
    pandoc.RawBlock("typst", table.concat(preamble, "\n") .. "\n#todo-table((\n"
      .. table.concat(rows, "\n") .. "\n))") }
  return doc
end

return {
  { Pandoc = expand_embeds },
  { Pandoc = group_proofs },
  { Pandoc = mark_todos },
  { Pandoc = attach_labels },
  { Math = Math, Link = Link, BlockQuote = BlockQuote },
  { Pandoc = todo_table },
}
