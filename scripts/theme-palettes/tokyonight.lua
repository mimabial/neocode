-- Curated hex -> name map for tokyonight (storm). Names reference the shared
-- vocabulary (V.*, typo-checked). Tokyonight has a deep blue/cyan spread
-- (blue0..7, cyan, magenta/magenta2, green1, etc.); those map onto the
-- vocabulary's blue/sky/cyan/aqua/teal hue roots by appearance and role.
local V = require("theme-palettes._vocabulary")

return {
  -- Blues
  ["#7aa2f7"] = V.blue,
  ["#8db0ff"] = V.blue_light,
  ["#a4daff"] = V.blue_pale,
  ["#607dbf"] = V.blue_muted,
  ["#3d59a1"] = V.blue_dark,   -- blue0 (Search)

  -- Sky / cyan / aqua / teal
  ["#7dcfff"] = V.sky,
  ["#89ddff"] = V.sky_light,
  ["#57c5e5"] = V.sky_bright,
  ["#0db9d7"] = V.cyan,        -- blue2 (DiagnosticInfo)
  ["#2ac3de"] = V.cyan_bright, -- blue1
  ["#29a4bd"] = V.cyan_dark,   -- FloatBorder
  ["#b4f9f8"] = V.cyan_pale,   -- blue6
  ["#8cf8f7"] = V.aqua,
  ["#1abc9c"] = V.teal,        -- teal (DiagnosticHint)
  ["#73daca"] = V.mint,        -- green1

  -- Greens
  ["#9ece6a"] = V.green,
  ["#9fe044"] = V.lime,        -- bright accent (sp)

  -- Yellows / oranges
  ["#e0af68"] = V.yellow,
  ["#faba4a"] = V.yellow_bright,
  ["#373640"] = V.yellow_dim,  -- warn vtext / DapStoppedLine tint
  ["#ff9e64"] = V.orange,
  ["#e78a4e"] = V.orange_bright,
  ["#dab484"] = V.orange_light,

  -- Reds / magenta / purple
  ["#f7768e"] = V.red,
  ["#db4b4b"] = V.red_dark,    -- red1 (DiagnosticError)
  ["#ff899d"] = V.red_light,   -- bright accent (sp)
  ["#362c3d"] = V.red_dim,     -- error vtext tint
  ["#bb9af7"] = V.magenta,
  ["#ff007c"] = V.magenta_bright, -- magenta2
  ["#9d7cd8"] = V.purple,
  ["#c7a9ff"] = V.purple_bright,  -- bright accent (sp)

  -- Neutrals / foregrounds
  ["#c0caf5"] = V.fg,
  ["#a9b1d6"] = V.fg_alt,      -- fg_dark
  ["#737aa2"] = V.fg_dim,      -- dark5
  ["#545c7e"] = V.gray,        -- dark3
  ["#565f89"] = V.comment,

  -- Surfaces
  ["#24283b"] = V.bg,
  ["#1f2335"] = V.bg_dark,
  ["#1d202f"] = V.bg_darker,
  ["#262c40"] = V.bg_alt,      -- inlay hint
  ["#272b3f"] = V.bg_dim,      -- pmenu scrollbar
  ["#292e42"] = V.cursorline,  -- bg_highlight
  ["#2e3c64"] = V.selection,   -- Visual
  ["#363d59"] = V.float,       -- PmenuSel
  ["#3b4261"] = V.indent,      -- fg_gutter / indent guides
  ["#414868"] = V.overlay,     -- terminal_black
  ["#28304b"] = V.surface,     -- signature active param
  ["#4f5258"] = V.shadow,

  -- Git signs
  ["#449dab"] = V.git_add,
  ["#6183bb"] = V.git_change,
  ["#914c54"] = V.git_delete,
  ["#ffc0b9"] = V.git_removed,

  -- Diffs
  ["#2b485a"] = V.diff_add,
  ["#272d43"] = V.diff_change,
  ["#52313f"] = V.diff_delete,
  ["#394b70"] = V.diff_text,   -- blue7

  -- Diagnostic tint surfaces
  ["#22374b"] = V.info_dim,
  ["#233745"] = V.hint_dim,

  -- Neovim-default leakage / semantic
  ["#ff0000"] = V.error,
  ["#b3f6c0"] = V.success,
}
