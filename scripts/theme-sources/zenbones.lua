-- Plugin-backed applier for zenbones, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires zenbones + lush.
return {
  all_variants = { "default" },
  bootstrap_variants = { "default" },
  exclude = {
    '^RedrawDebug',
    '^Notify',
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "zenbones" } })
    vim.o.background = "dark"
    vim.g.zenbones_darkness = nil
    vim.g.zenbones_transparent_background = opts.transparency == true
    vim.cmd("colorscheme zenbones")
  end,
}
