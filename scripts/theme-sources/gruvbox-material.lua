-- Plugin-backed applier for gruvbox-material, used ONLY by
-- scripts/snapshot_theme.lua to capture snapshots. Not loaded at runtime.
-- The variant is the contrast level, exactly as the plugin names it. Light/dark
-- is an independent axis and arrives in opts.background (the pack's
-- $NVIM_BACKGROUND), so it must not be folded into the variant key.
return {
  all_variants = { "hard", "medium", "soft" },
  bootstrap_variants = { "medium" },
  exclude = { "^RedrawDebug" },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "gruvbox-material" } })
    vim.o.background = opts.background or "dark"
    vim.g.gruvbox_material_background = variant
    vim.g.gruvbox_material_transparent_background = opts.transparency and 2 or 0
    vim.cmd("colorscheme gruvbox-material")
  end,
}
