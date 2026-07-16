-- Plugin-backed applier for nord, used ONLY by scripts/snapshot_theme.lua to
-- capture snapshots. Not loaded at runtime. Requires nord.nvim.
return {
  exclude = {
    '^RedrawDebug',
    '^Headline',
  },
  apply = function(_, opts)
    require("lazy").load({ plugins = { "nord.nvim" } })
    vim.o.background = "dark"
    vim.g.nord_disable_background = opts.transparency or false
    vim.cmd("colorscheme nord")
  end,
}
