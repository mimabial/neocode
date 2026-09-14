-- Optional snapshot generator for custom themes that need fully frozen,
-- editable highlights with no plugin dependency at runtime.
--
--   SNAPSHOT_SCHEME=<scheme> [SNAPSHOT_VARIANTS="v1 v2"] [SNAPSHOT_BACKGROUND=dark|light] \
--     nvim --headless -c "luafile scripts/snapshot_theme.lua" -c "qa"
--
-- Runs under --headless (not -l) so the full config + lazy are available.
-- With neither env set, captures the (variant, background) of every Hypr theme
-- pack whose $NVIM_SCHEME == <scheme> -- including packs with no $NVIM_VARIANT.
-- Names come from scripts/theme-palettes/<scheme>.lua (hex -> name) when it
-- exists; unlisted colors get a stable nearest-ANSI fallback name.
-- Set SNAPSHOT_RENAME_ONLY=1 to re-serialize the existing data with the current
-- palette map WITHOUT re-capturing -- use after editing theme-palettes/<scheme>.lua.

local scheme = os.getenv("SNAPSHOT_SCHEME")
if not scheme or scheme == "" then
  io.stderr:write("SNAPSHOT_SCHEME is required\n")
  os.exit(2)
end

local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local themes_dir = config_home .. "/hypr/themes"
local nvim_config = vim.fn.stdpath("config")
-- Let palette maps `require("theme-palettes._vocabulary")`.
package.path = nvim_config .. "/scripts/?.lua;" .. package.path
local source_path = nvim_config .. "/scripts/theme-sources/" .. scheme .. ".lua"
local palette_path = nvim_config .. "/scripts/theme-palettes/" .. scheme .. ".lua"
local data_path = nvim_config .. "/lua/plugins/themes/definitions/data/" .. scheme .. ".lua"

local function conf_value(file, key)
  for line in io.lines(file) do
    local v = line:match("^%s*%$" .. key .. "%s*=%s*(.-)%s*$")
    if v then
      return (v:gsub('^["\']', ""):gsub('["\']$', ""))
    end
  end
  return nil
end

-- Captured opaque; theme_manager applies transparency at runtime.
local no_glob = (os.getenv("SNAPSHOT_NO_GLOB") or "") ~= ""
local rename_only = (os.getenv("SNAPSHOT_RENAME_ONLY") or "") ~= ""
local requested = {}
if not rename_only then
  local seen = {}
  local function request(variant, background)
    local key = tostring(variant) .. "\0" .. tostring(background)
    if seen[key] then return end
    seen[key] = true
    requested[#requested + 1] = { variant = variant, background = background }
  end

  local function nonempty(v)
    return (v and v ~= "") and v or nil
  end

  local variants_env = nonempty(os.getenv("SNAPSHOT_VARIANTS"))
  local bg_env = nonempty(os.getenv("SNAPSHOT_BACKGROUND"))
  local explicitly_requested = variants_env or bg_env
  if explicitly_requested then
    if variants_env then
      for v in variants_env:gmatch("%S+") do
        request(v, bg_env)
      end
    else
      request(nil, bg_env)
    end
  elseif no_glob then
    -- Dispatched child with no explicit axis: capture the scheme default once.
    request(nil, nil)
  else
    for _, f in ipairs(vim.fn.glob(themes_dir .. "/*/hypr.theme", false, true)) do
      if conf_value(f, "NVIM_SCHEME") == scheme then
        request(nonempty(conf_value(f, "NVIM_VARIANT")), nonempty(conf_value(f, "NVIM_BACKGROUND")))
      end
    end
  end
end
if #requested == 0 and not rename_only then
  io.stderr:write("no packs reference " .. scheme .. " and no variants given\n")
  os.exit(0)
end

-- Capturing multiple variants in one process leaks state: a plugin's variant
-- switch may not fully re-apply within a session, contaminating later captures.
-- Dispatch one fresh nvim per variant (each preserves the others in the data file).
if #requested > 1 and not no_glob then
  table.sort(requested, function(a, b)
    if tostring(a.variant) ~= tostring(b.variant) then
      return tostring(a.variant) < tostring(b.variant)
    end
    return tostring(a.background) < tostring(b.background)
  end)
  local script = nvim_config .. "/scripts/snapshot_theme.lua"
  for _, r in ipairs(requested) do
    print(("dispatch %s / %s / %s (fresh process)"):format(scheme, r.variant or "-", r.background or "-"))
    -- Arg list + env overlay: no shell, so variant/background never need quoting.
    -- SNAPSHOT_NO_GLOB stops the child from re-expanding packs and re-dispatching.
    local res = vim.system({ "nvim", "--headless", "-c", "luafile " .. script, "-c", "qa" }, {
      env = {
        SNAPSHOT_SCHEME = scheme,
        SNAPSHOT_VARIANTS = r.variant or "",
        SNAPSHOT_BACKGROUND = r.background or "",
        SNAPSHOT_NO_GLOB = "1",
      },
      text = true,
    }):wait()
    io.write(res.stdout or "")
    io.stderr:write(res.stderr or "")
  end
  os.exit(0)
end

local source = dofile(source_path)

-- Keyed so re-running one capture leaves the scheme's others intact.
local captured = {}
local function capture_key(variant, background)
  return tostring(variant) .. "\0" .. tostring(background)
end
local function put(entry)
  captured[capture_key(entry.variant, entry.background)] = entry
end
do
  local ok, existing = pcall(dofile, data_path)
  if ok and type(existing) == "table" then
    for _, entry in ipairs(existing) do
      if type(entry) == "table" and entry.highlights and entry.background then
        put(entry)
      else
        io.stderr:write(("ignoring unrecognised entry in %s -- recapture it\n"):format(scheme))
      end
    end
  end
end

if rename_only and next(captured) == nil then
  io.stderr:write(("SNAPSHOT_RENAME_ONLY set but no existing data at %s\n"):format(data_path))
  os.exit(1)
end

local function to_hex(v)
  if type(v) == "number" then
    return string.format("#%06x", v)
  end
  -- Some schemes set colors as hex strings; normalize case so #AABBCC and
  -- #aabbcc don't become two palette entries for one color.
  if type(v) == "string" then
    return v:lower()
  end
  return v
end

local exclude = source.exclude or {}
local function excluded(group)
  for _, pat in ipairs(exclude) do
    if group:match(pat) then return true end
  end
  return false
end

local function capture(variant, opts)
  -- Clean slate: reset every group and the terminal palette before applying, so
  -- nothing leaks from the startup theme or plugins that set globals eagerly
  -- (a scheme that doesn't define terminal colors would otherwise inherit them).
  vim.cmd("highlight clear")
  for i = 0, 15 do vim.g["terminal_color_" .. i] = nil end
  source.apply(variant, opts)

  -- Enumerate names from the bulk map, then query each by name with the
  -- default link=true so we record the group's OWN definition (attrs OR its
  -- {link=...}). Groups left to nvim's runtime default-links come back empty
  -- and are skipped, matching the plugin exactly. Excluded groups are dropped.
  local highlights = {}
  for group in pairs(vim.api.nvim_get_hl(0, {})) do
    if not excluded(group) then
      local spec = vim.api.nvim_get_hl(0, { name = group })
      local clean = {}
      for k, val in pairs(spec) do
        clean[k] = (k == "fg" or k == "bg" or k == "sp") and to_hex(val) or val
      end
      if next(clean) then
        highlights[group] = clean
      end
    end
  end

  local terminal = {}
  for i = 0, 15 do
    local tc = vim.g["terminal_color_" .. i]
    if tc then terminal[i] = to_hex(tc) end
  end

  return { background = vim.o.background, terminal = terminal, highlights = highlights }
end

for _, r in ipairs(requested) do
  local snap = capture(r.variant, { background = r.background })
  snap.variant = r.variant
  put(snap)
  print(("captured %s / %s / %s (%d groups)"):format(scheme, r.variant or "-", snap.background,
    vim.tbl_count(snap.highlights)))
end

local palette_map = {}
do
  local ok, m = pcall(dofile, palette_path)
  if ok and type(m) == "table" then palette_map = m end
end

-- Canonical vocabulary (for reporting which curated names are shared vs one-off).
local vocab = {}
do
  local ok, v = pcall(require, "theme-palettes._vocabulary")
  if ok and type(v) == "table" then
    for k in pairs(v) do vocab[k] = true end
  end
end

local ANSI = {
  "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white",
  "black_br", "red_br", "green_br", "yellow_br", "blue_br", "magenta_br", "cyan_br", "white_br",
}

local function rgb(hex)
  return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

local UI = {}
for _, g in ipairs({
  "Normal", "NormalNC", "NormalFloat", "FloatBorder", "FloatTitle", "FloatShadow", "FloatShadowThrough",
  "Cursor", "lCursor", "CursorLine", "CursorLineNr", "CursorColumn", "ColorColumn", "LineNr", "LineNrAbove",
  "LineNrBelow", "SignColumn", "FoldColumn", "Folded", "EndOfBuffer", "NonText", "Whitespace", "SpecialKey",
  "Conceal", "Visual", "VisualNOS", "Search", "IncSearch", "CurSearch", "Substitute", "MatchParen", "Pmenu",
  "PmenuSel", "PmenuSbar", "PmenuThumb", "PmenuKind", "PmenuKindSel", "PmenuExtra", "PmenuExtraSel", "WildMenu",
  "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel", "WinBar", "WinBarNC", "WinSeparator",
  "VertSplit", "Title", "Directory", "ModeMsg", "MoreMsg", "Question", "WarningMsg", "ErrorMsg", "MsgArea",
  "MsgSeparator", "QuickFixLine", "TermCursor", "TermCursorNC", "Underlined", "Ignore",
  "SpellBad", "SpellCap", "SpellLocal", "SpellRare",
}) do UI[g] = true end

local SYNTAX = {}
for _, g in ipairs({
  "Comment", "Constant", "String", "Character", "Number", "Boolean", "Float", "Identifier", "Function",
  "Statement", "Conditional", "Repeat", "Label", "Operator", "Keyword", "Exception", "PreProc", "Include",
  "Define", "Macro", "PreCondit", "Type", "StorageClass", "Structure", "Typedef", "Special", "SpecialChar",
  "Tag", "Delimiter", "SpecialComment", "Debug", "Todo", "Error",
}) do SYNTAX[g] = true end

local SECTION_ORDER = { "Editor & UI", "Syntax", "Treesitter", "LSP", "Diagnostics", "Git & diff", "Plugins & extras" }

local function section_of(g)
  if g:match("^@lsp") or g:match("^Lsp") then return "LSP" end
  if g:match("^@") then return "Treesitter" end
  if g:match("^Diagnostic") then return "Diagnostics" end
  if g:match("^GitSigns") or g:match("^Diff") or g:match("^MiniDiff")
    or g == "Added" or g == "Removed" or g == "Changed" then
    return "Git & diff"
  end
  if UI[g] then return "Editor & UI" end
  if SYNTAX[g] then return "Syntax" end
  return "Plugins & extras"
end

local function serialize(value)
  if type(value) == "string" then return string.format("%q", value) end
  if type(value) ~= "table" then return tostring(value) end
  local keys = {}
  for k in pairs(value) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
  local parts = {}
  for _, k in ipairs(keys) do
    local key = type(k) == "number" and ("[" .. k .. "]")
      or (k:match("^[%a_][%w_]*$") and k or ("[" .. string.format("%q", k) .. "]"))
    parts[#parts + 1] = key .. " = " .. serialize(value[k])
  end
  return "{ " .. table.concat(parts, ", ") .. " }"
end

local out = {}
local function w(s) out[#out + 1] = s end

w(("-- GENERATED by scripts/snapshot_theme.lua.\n"
  .. "-- Frozen %s colorscheme, no plugin dependency. Edit a palette value below\n"
  .. "-- to recolor every group that references it. NOTE: regeneration overwrites\n"
  .. "-- this file, so stop regenerating once you hand-edit.\n"
  .. "-- Shape: a list of { variant?, background, palette, terminal, highlights }.\n"
  .. "-- background is always present; variant appears only for schemes that have a\n"
  .. "-- variant axis, and both are named exactly as the plugin names them.\n"
  .. "-- Refresh: SNAPSHOT_SCHEME=%s nvim --headless -c 'luafile scripts/snapshot_theme.lua' -c 'qa'\n\n"
  .. "local M = {}\n\n"):format(scheme, scheme))

local entries = {}
for _, entry in pairs(captured) do entries[#entries + 1] = entry end
table.sort(entries, function(a, b)
  if tostring(a.variant) ~= tostring(b.variant) then
    return tostring(a.variant) < tostring(b.variant)
  end
  return a.background < b.background
end)

local function emit_palette(variant, background, snap, pvar)
  local hl, term = snap.highlights, snap.terminal

  local color_set = {}
  for _, spec in pairs(hl) do
    for _, role in ipairs({ "fg", "bg", "sp" }) do
      if spec[role] then color_set[spec[role]] = true end
    end
  end
  for i = 0, 15 do if term[i] then color_set[term[i]] = true end end

  -- Curated names first, then stable nearest-ANSI fallback for the rest.
  local name_of, taken = {}, {}
  for hex in pairs(color_set) do
    local n = palette_map[hex]
    if n then name_of[hex] = n; taken[n] = true end
  end
  local unmapped = {}
  for hex in pairs(color_set) do if not name_of[hex] then unmapped[#unmapped + 1] = hex end end
  table.sort(unmapped)
  for _, hex in ipairs(unmapped) do
    local r, g, b = rgb(hex)
    local best, bestd
    for i = 0, 15 do
      if term[i] then
        local tr, tg, tb = rgb(term[i])
        local d = (r - tr) ^ 2 + (g - tg) ^ 2 + (b - tb) ^ 2
        if not bestd or d < bestd then bestd = d; best = ANSI[i + 1] end
      end
    end
    local base = (best or "color") .. "_alt"
    local name, n = base, 1
    while taken[name] do n = n + 1; name = base .. n end
    name_of[hex] = name; taken[name] = true
  end

  -- Guard: two hexes sharing a name in one capture would collapse to one color
  -- (silent nuance loss). Fail loudly instead.
  do
    local seen = {}
    for hex, name in pairs(name_of) do
      if seen[name] then
        io.stderr:write(("collision in %s%s: %q maps both %s and %s -- give one a distinct name in theme-palettes/%s.lua\n")
          :format(variant and (variant .. "/") or "", background, name, seen[name], hex, scheme))
        os.exit(1)
      end
      seen[name] = hex
    end
  end

  -- Scheme-specific one-offs, or drift worth promoting into the vocabulary.
  if next(vocab) then
    local extras = {}
    for _, name in pairs(name_of) do
      if not vocab[name] then extras[name] = true end
    end
    local list = {}
    for name in pairs(extras) do list[#list + 1] = name end
    if #list > 0 then
      table.sort(list)
      print(("  %s%s: %d non-canonical name(s): %s"):format(variant and (variant .. "/") or "",
        background, #list, table.concat(list, ", ")))
    end
  end

  w(("-- %s%s\n"):format(variant and (variant .. " / ") or "", background))
  local pal = {}
  for hex, name in pairs(name_of) do pal[#pal + 1] = { name = name, hex = hex } end
  table.sort(pal, function(a, b) return a.name < b.name end)
  w("local " .. pvar .. " = {\n")
  for _, e in ipairs(pal) do w(("  %s = %q,\n"):format(e.name, e.hex)) end
  w("}\n\n")

  return name_of
end

local function emit_spec(spec, pvar, name_of)
  local keys = {}
  for k in pairs(spec) do keys[#keys + 1] = k end
  table.sort(keys)
  local parts = {}
  for _, k in ipairs(keys) do
    local v = spec[k]
    local rhs
    if (k == "fg" or k == "bg" or k == "sp") and type(v) == "string" then
      rhs = pvar .. "." .. name_of[v]
    elseif type(v) == "table" then
      rhs = serialize(v)
    elseif type(v) == "string" then
      rhs = string.format("%q", v)
    else
      rhs = tostring(v)
    end
    parts[#parts + 1] = k .. " = " .. rhs
  end
  return "{ " .. table.concat(parts, ", ") .. " }"
end

for index, snap in ipairs(entries) do
  local variant, background = snap.variant, snap.background
  local pvar = ((variant and (variant .. "_") or "") .. background):gsub("[^%w_]", "_") .. "_p"
  -- The palette local must be declared before the entry that references it.
  local name_of = emit_palette(variant, background, snap, pvar)
  local term, hl = snap.terminal, snap.highlights

  w(("M[%d] = {\n"):format(index))
  if variant then
    w(("  variant = %q,\n"):format(variant))
  end
  w(("  background = %q,\n"):format(background))
  w("  palette = " .. pvar .. ",\n")
  w("  terminal = {\n")
  for i = 0, 15 do
    if term[i] then w(("    [%d] = %s.%s,\n"):format(i, pvar, name_of[term[i]])) end
  end
  w("  },\n")
  w("  highlights = {\n")

  local buckets = {}
  for g in pairs(hl) do
    local s = section_of(g)
    buckets[s] = buckets[s] or {}
    buckets[s][#buckets[s] + 1] = g
  end
  for _, sec in ipairs(SECTION_ORDER) do
    local gs = buckets[sec]
    if gs then
      table.sort(gs)
      w("    -- " .. sec .. "\n")
      for _, g in ipairs(gs) do
        local key = g:match("^[%a_][%w_]*$") and g or ("[" .. string.format("%q", g) .. "]")
        w("    " .. key .. " = " .. emit_spec(hl[g], pvar, name_of) .. ",\n")
      end
      w("\n")
    end
  end

  w("  },\n}\n\n")
end

w("return M\n")

vim.fn.mkdir(vim.fn.fnamemodify(data_path, ":h"), "p")
local fh = assert(io.open(data_path, "w"))
fh:write(table.concat(out))
fh:close()
print(("wrote %s (%d capture(s))"):format(data_path, #entries))
