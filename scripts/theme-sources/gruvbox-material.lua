-- Plugin-backed applier for gruvbox-material, used ONLY by
-- scripts/snapshot_theme.lua to capture snapshots. Not loaded at runtime.
-- Variant keys encode contrast+background ("<contrast>-<bg>") since the
-- contrast level and light/dark background are independent axes.
return {
  all_variants = {
    "hard-dark", "medium-dark", "soft-dark",
    "hard-light", "medium-light", "soft-light",
  },
  bootstrap_variants = { "medium-dark" },
  exclude = { "^RedrawDebug" },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "gruvbox-material" } })
    local contrast, bg = variant:match("^(%a+)-(%a+)$")
    vim.o.background = bg
    vim.g.gruvbox_material_background = contrast
    vim.g.gruvbox_material_transparent_background = opts.transparency and 2 or 0
    vim.cmd("colorscheme gruvbox-material")
  end,
}
