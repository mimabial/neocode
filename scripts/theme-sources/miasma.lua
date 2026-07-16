-- Plugin-backed applier for miasma, used ONLY by scripts/snapshot_theme.lua to
-- capture snapshots. Not loaded at runtime. Requires miasma.nvim.
-- miasma is a single dark "swamp" scheme (.vim colorscheme, no options).
return {
  exclude = {
    '^RedrawDebug',
    '^Headline',
  },
  apply = function(_, opts)
    require("lazy").load({ plugins = { "miasma.nvim" } })
    vim.o.background = "dark"
    vim.cmd("colorscheme miasma")
  end,
}
