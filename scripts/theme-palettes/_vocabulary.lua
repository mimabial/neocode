-- Canonical palette-name vocabulary, grounded in scheme-independent sources so
-- no single theme defines the canon:
--   * the 16 ANSI colors            (fixed terminal meaning)
--   * a standard named-hue set       (X11/CSS-style)
--   * a shade-modifier grammar       (<hue> + _bright/_light/_pale/_muted/_dim/_dark/_soft)
--   * standard editor surfaces
--   * Neovim's semantic highlight roles
--
-- Per-scheme theme-palettes/<scheme>.lua maps reference these (V.purple,
-- V.git_add, ...) so a role gets the same name in every scheme. A scheme omits
-- roles it lacks, and may name a genuinely unique color with a free string.
-- To promote such a color to the canon, add its name to the lists below.
--
-- Access is strict: V.<typo> raises, so map authors can't silently drift.

local V = {}

-- Hue roots: ANSI chromatic + standard extended hues (X11/CSS).
local hues = {
  "red", "green", "yellow", "blue", "magenta", "cyan",
  "purple", "orange", "pink", "teal", "coral", "violet",
  "sky", "lime", "mint", "aqua", "gold", "rose",
}
-- Shade modifiers applicable to any hue.
local modifiers = { "bright", "light", "pale", "muted", "dim", "dark", "soft" }
for _, h in ipairs(hues) do
  V[h] = h
  for _, m in ipairs(modifiers) do V[h .. "_" .. m] = h .. "_" .. m end
end

local function add(list)
  for _, n in ipairs(list) do V[n] = n end
end

-- ANSI neutrals + foregrounds.
add({ "black", "white", "black_bright", "white_bright",
      "gray", "gray_dim", "gray_dark", "gray_muted", "gray_light",
      "fg", "fg_dim", "fg_alt", "comment" })

-- Editor surfaces: background tiers + special surfaces.
add({ "bg", "bg_alt", "bg_dim", "bg_dark", "bg_darker", "bg_darkest",
      "surface", "overlay", "selection", "cursorline", "float", "shadow",
      "indent", "indent_scope" })

-- Neovim semantic highlight roles (colors a theme designs for a purpose).
add({ "error", "warning", "info", "hint", "success", "string",
      "info_dim", "hint_dim", "diag_dim",
      "git_add", "git_change", "git_delete", "git_removed",
      "git_staged_add", "git_staged_change", "git_staged_delete", "git_staged_topdelete",
      "diff_add", "diff_change", "diff_delete", "diff_text",
      "debug_composed", "debug_recompose", "debug_clear" })

return setmetatable(V, {
  __index = function(_, k)
    error(("unknown canonical role %q -- add it to theme-palettes/_vocabulary.lua"):format(tostring(k)), 2)
  end,
})
