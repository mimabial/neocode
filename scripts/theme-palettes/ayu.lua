-- Curated hex -> name map for ayu (mirage). Names reference the shared
-- vocabulary (V.*, typo-checked) and follow ayu's roles: warm accent yellows,
-- a salmon/coral markup+operator pair, cyan/blue entities, and mirage's dark
-- blue-gray surface ramp.
local V = require("theme-palettes._vocabulary")

return {
  -- Yellows / oranges (ayu's warm accents)
  ["#ffcc66"] = V.yellow,        -- accent
  ["#ffd173"] = V.gold,          -- functions
  ["#ffdfb3"] = V.yellow_light,  -- structure
  ["#ffa759"] = V.orange,        -- keyword
  ["#ffad66"] = V.orange_light,  -- title / headings
  ["#e78a4e"] = V.orange_bright, -- navic icons

  -- Coral / salmon (markup + operator)
  ["#f28779"] = V.coral,
  ["#f29e74"] = V.coral_light,

  -- Reds / pink
  ["#ff6666"] = V.red,
  ["#f27983"] = V.red_light,     -- removed / deleted text
  ["#d3869b"] = V.pink,

  -- Greens
  ["#d5ff80"] = V.green,         -- string
  ["#87d96c"] = V.green_bright,  -- added / new
  ["#95e6cb"] = V.mint,          -- regexp

  -- Cyan / blue / aqua
  ["#5ccfe6"] = V.cyan,          -- tag / entity
  ["#73d0ff"] = V.blue,          -- entity name
  ["#80bfff"] = V.blue_light,    -- staged / changed
  ["#8cf8f7"] = V.aqua,          -- quickfix line

  -- Purples
  ["#dfbfff"] = V.purple,        -- constant
  ["#d3b8f9"] = V.purple_muted,  -- type parameter

  -- Neutrals / foregrounds
  ["#cccac2"] = V.fg,
  ["#ffffff"] = V.white,
  ["#6c7a8b"] = V.comment,
  ["#707a8c"] = V.gray,
  ["#969696"] = V.gray_light,
  ["#9b9ea4"] = V.gray_muted,

  -- Surfaces (mirage dark blue-gray ramp)
  ["#1f2430"] = V.bg,
  ["#1c212b"] = V.bg_alt,       -- statusline
  ["#161922"] = V.bg_dim,       -- inactive tabline
  ["#101521"] = V.bg_dark,      -- separators / fill
  ["#07080d"] = V.bg_darkest,   -- winbar
  ["#171b24"] = V.cursorline,
  ["#23344b"] = V.selection,    -- cursor word / DiffChange
  ["#4a505a"] = V.overlay,      -- DiffText / blame
  ["#323843"] = V.indent,       -- line nr / indent marker
  ["#4f5258"] = V.shadow,

  -- Diffs
  ["#313d37"] = V.diff_add,
  ["#3e373a"] = V.diff_delete,

  -- Neovim-default leakage / semantic
  ["#b3f6c0"] = V.success,
  ["#ff0000"] = V.error,
  ["#ffc0b9"] = V.git_removed,
}
