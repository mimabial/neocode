-- Curated hex -> name map for rose-pine (main = dark, dawn = light). Both
-- variants are parallel: each role has one hex per variant, so the two hex
-- sets never collide. Names reference the shared vocabulary (V.*, typo-checked)
-- and follow rose-pine's own palette semantics (base/surface/overlay,
-- love/gold/rose/pine/foam/iris, highlight tiers).
local V = require("theme-palettes._vocabulary")

return {
  -- Accents (main / dawn)
  ["#9ccfd8"] = V.cyan,        ["#56949f"] = V.cyan,        -- foam
  ["#ebbcba"] = V.rose,        ["#d7827e"] = V.rose,        -- rose
  ["#f6c177"] = V.gold,        ["#ea9d34"] = V.gold,        -- gold
  ["#c4a7e7"] = V.purple,      ["#907aa9"] = V.purple,      -- iris
  ["#eb6f92"] = V.red,         ["#b4637a"] = V.red,         -- love
  ["#31748f"] = V.blue,        ["#286983"] = V.blue,        -- pine
  ["#95b1ac"] = V.teal,        ["#6d8f89"] = V.teal,        -- muted foam
  ["#908caa"] = V.gray,        ["#797593"] = V.gray,        -- subtle
  ["#b3f6c0"] = V.success,     ["#005523"] = V.success,     -- OkMsg

  -- Neutrals / foregrounds
  ["#e0def4"] = V.fg,          ["#464261"] = V.fg,          -- text
  ["#6e6a86"] = V.comment,     ["#9893a5"] = V.comment,     -- muted

  -- Surfaces (background + highlight tiers)
  ["#191724"] = V.bg,          ["#faf4ed"] = V.bg,          -- base
  ["#1f1d2e"] = V.surface,     ["#fffaf3"] = V.surface,     -- surface
  ["#26233a"] = V.overlay,     ["#f2e9e1"] = V.overlay,     -- overlay
  ["#21202e"] = V.bg_dim,      ["#f4ede8"] = V.bg_dim,      -- highlightLow
  ["#403d52"] = V.selection,   ["#dfdad9"] = V.selection,   -- highlightMed
  ["#524f67"] = V.cursorline,  ["#cecacd"] = V.cursorline,  -- highlightHigh
  ["#1d1b2a"] = V.bg_darker,   ["#fdf8f1"] = V.bg_darker,   -- inactive statusline
  ["#221f2e"] = V.bg_dark,     ["#f0eae6"] = V.bg_dark,     -- inlay hint
  ["#4f5258"] = V.shadow,      ["#9b9ea4"] = V.shadow,      -- float shadow

  -- Diffs
  ["#333c48"] = V.diff_add,    ["#d9e1dd"] = V.diff_add,
  ["#433842"] = V.diff_change, ["#f3ddd7"] = V.diff_change,
  ["#43293a"] = V.diff_delete, ["#ecd7d6"] = V.diff_delete,
  ["#6d5960"] = V.diff_text,   ["#ecc6c1"] = V.diff_text,

  -- Semantic tint surfaces (diagnostic vtext bgs, keyword-comment bgs, search)
  ["#262936"] = V.info_dim,     ["#eaeae5"] = V.info_dim,     -- DiagVText info
  ["#2a2538"] = V.hint_dim,     ["#efe8e6"] = V.hint_dim,     -- DiagVText hint
  ["#2e202f"] = V.red_dark,     ["#f3e6e2"] = V.red_dark,     -- DiagVText error
  ["#2f282c"] = V.gold_dark,    ["#f8ebdb"] = V.gold_dark,    -- DiagVText warn
  ["#252632"] = V.green_dark,   ["#eceae3"] = V.green_dark,   -- DiagVText ok
  ["#332d41"] = V.purple_muted, ["#eae2e3"] = V.purple_muted, -- @comment.hint / Visual
  ["#2d333f"] = V.blue_dark,    ["#e1e6e1"] = V.blue_dark,    -- @comment.info
  ["#1d2534"] = V.blue_dim,     ["#dbdfdd"] = V.blue_dim,     -- @comment.note
  ["#39303b"] = V.rose_dark,    ["#f5e3dc"] = V.rose_dark,    -- @comment.todo
  ["#453935"] = V.gold_muted,   ["#f7e3c8"] = V.gold_muted,   -- Search
  ["#274f64"] = V.teal_dark,    ["#7ca1ad"] = V.teal_dark,    -- terminal statusline
  ["#1f2e3f"] = V.blue_muted,   ["#c6d1d3"] = V.blue_muted,   -- MatchParen

  -- Git
  ["#ffc0b9"] = V.git_removed,  ["#590008"] = V.git_removed,
}
