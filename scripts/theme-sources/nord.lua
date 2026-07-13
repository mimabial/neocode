-- Plugin-backed applier for nord, used ONLY by scripts/snapshot_theme.lua to
-- capture snapshots. Not loaded at runtime. Requires nord.nvim.
return {
  all_variants = { "dark" },
  bootstrap_variants = { "dark" },
  exclude = {
    '^RedrawDebug',
    '^Headline',
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "nord.nvim" } })
    vim.o.background = "dark"
    vim.g.nord_disable_background = opts.transparency or false
    vim.cmd("colorscheme nord")
  end,
}
