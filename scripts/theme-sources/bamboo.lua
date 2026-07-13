-- Plugin-backed applier for bamboo, used ONLY by scripts/snapshot_theme.lua to
-- capture snapshots. Not loaded at runtime. Requires bamboo.nvim.
return {
  all_variants = { "vulgaris", "multiplex", "light" },
  bootstrap_variants = { "vulgaris" },
  exclude = {
    '^RedrawDebug',
    '^TSRainbow',
    '^rainbowcol',
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "bamboo.nvim" } })
    vim.o.background = (variant == "light") and "light" or "dark"
    require("bamboo").setup({ style = variant, transparent = opts.transparency })
    require("bamboo").load()
  end,
}
