-- Curated hex -> name map for miasma (dark). miasma is a warm "swamp" scheme:
-- olive/lime greens with rust/gold/sand accents over a near-black surface ramp.
-- Names reference the shared vocabulary (V.*, typo-checked). The block below the
-- accents is recurring config-leak values, named to match the other palettes.
local V = require("theme-palettes._vocabulary")

return {
  -- Accents (miasma's own palette)
  ["#5f875f"] = V.green,
  ["#78824b"] = V.lime,
  ["#78834b"] = V.lime_bright,
  ["#b36d43"] = V.orange,
  ["#bb7744"] = V.orange_light,
  ["#685742"] = V.orange_muted, -- taupe: Cursor bg, DiffChange, warnings
  ["#fd9720"] = V.orange_bright,
  ["#c9a554"] = V.gold,
  ["#fbec9f"] = V.yellow_pale,

  -- Neutrals / foregrounds
  ["#d7c483"] = V.fg,
  ["#c2c2b0"] = V.white,
  ["#666666"] = V.comment,
  ["#444444"] = V.gray_dark,

  -- Surfaces (near-black ramp, darkest -> bg)
  ["#101010"] = V.bg_darker,
  ["#111111"] = V.bg_dark,
  ["#151515"] = V.bg_dim,
  ["#1c1c1c"] = V.cursorline,
  ["#222222"] = V.bg,

  -- Indent guides
  ["#242d1d"] = V.indent,
  ["#43492a"] = V.indent_scope,

  -- Recurring config leakage (named to match the other palettes)
  ["#000000"] = V.black,
  ["#07080d"] = V.bg_darkest,
  ["#45403d"] = V.overlay,
  ["#4f5258"] = V.shadow,
  ["#4f3552"] = V.purple_dark,
  ["#4f6752"] = V.green_dark,
  ["#79491d"] = V.orange_dark,
  ["#8a1f1f"] = V.red_dark,
  ["#8b8b8b"] = V.gray_light,
  ["#9b9ea4"] = V.gray_muted,
  ["#8cf8f7"] = V.aqua,
  ["#a9ff68"] = V.green_bright,
  ["#b3f6c0"] = V.success,
  ["#d484ff"] = V.purple_bright,
  ["#e0e2ea"] = V.white_bright,
  ["#f70067"] = V.red_bright,
  ["#f79000"] = V.orange_soft,
  ["#fce094"] = V.yellow_light,
  ["#ffc0b9"] = V.git_removed,
}
