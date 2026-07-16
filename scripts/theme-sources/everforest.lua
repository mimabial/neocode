-- Plugin-backed applier for everforest, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires everforest.
-- The variant is the contrast level, exactly as the plugin names it. Light/dark
-- is an independent axis and arrives in opts.background (the pack's
-- $NVIM_BACKGROUND), so it must not be folded into the variant key.
return {
  all_variants = { "hard", "medium", "soft" },
  bootstrap_variants = { "hard", "soft" },
  exclude = { "^RedrawDebug" },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "everforest" } })
    vim.o.background = opts.background or "dark"
    vim.g.everforest_background = variant
    vim.g.everforest_transparent_background = opts.transparency and 2 or 0
    vim.cmd("colorscheme everforest")
  end,
}
