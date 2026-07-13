-- Plugin-backed applier for everforest, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires everforest.
-- Variant keys encode contrast+background ("<contrast>-<bg>") since everforest's
-- contrast level and light/dark background are independent axes.
return {
  all_variants = {
    "soft-dark", "medium-dark", "hard-dark",
    "soft-light", "medium-light", "hard-light",
  },
  bootstrap_variants = { "soft-dark", "hard-light" },
  exclude = { "^RedrawDebug" },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "everforest" } })
    local contrast, bg = variant:match("^(%a+)-(%a+)$")
    vim.o.background = bg
    vim.g.everforest_background = contrast
    vim.g.everforest_transparent_background = opts.transparency and 2 or 0
    vim.cmd("colorscheme everforest")
  end,
}
