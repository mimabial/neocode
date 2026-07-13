-- Curated hex -> name map for solarized (dark). Names reference the shared
-- vocabulary (V.*, typo-checked) and follow Ethan Schoonover's Solarized roles:
-- base03..base3 monotones + the eight accents (yellow/orange/red/magenta/
-- violet/blue/cyan/green).
local V = require("theme-palettes._vocabulary")

return {
  -- Accents (the Solarized eight)
  ["#b58900"] = V.yellow,
  ["#cb4b16"] = V.orange,
  ["#dc322f"] = V.red,
  ["#d33682"] = V.magenta,
  ["#6c71c4"] = V.violet,
  ["#268bd2"] = V.blue,
  ["#2aa198"] = V.cyan,
  ["#859900"] = V.green,
  ["#e78a4e"] = V.orange_bright, -- computed light orange (navic icons)

  -- Monotones (base03 darkest .. base3 lightest)
  ["#002731"] = V.bg_dark,   -- below-base window fill
  ["#002b36"] = V.bg,        -- base03 (Normal)
  ["#073642"] = V.surface,   -- base02 (highlighted surface)
  ["#586e75"] = V.comment,   -- base01
  ["#839496"] = V.fg,        -- base0 (body text)
  ["#93a1a1"] = V.fg_alt,    -- base1 (emphasized)
  ["#eee8d5"] = V.white,     -- base2 (light-tone highlight)

  -- Accent-tinted dark surfaces
  ["#2c4e56"] = V.selection,     -- Visual / Search
  ["#0c4e53"] = V.cyan_dark,     -- word/reference highlight
  ["#0b4764"] = V.blue_dark,     -- float title / hunk header
  ["#204060"] = V.blue_dim,      -- active button
  ["#274c25"] = V.green_dark,    -- lsp reference write/read
  ["#3f2e4c"] = V.violet_dark,   -- IncSearch
  ["#422d33"] = V.diff_delete,   -- neogit delete highlight
  ["#1d706a"] = V.teal,          -- inlay hint

  -- Neovim-default leakage (no scheme override) -- shared names across schemes
  ["#4f5258"] = V.shadow,
  ["#ff0000"] = V.error,
  ["#b3f6c0"] = V.success,
  ["#ffc0b9"] = V.git_removed,
}
