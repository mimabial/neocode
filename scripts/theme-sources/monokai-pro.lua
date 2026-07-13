-- Plugin-backed applier for monokai-pro, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires monokai-pro.nvim.
return {
  all_variants = { "pro", "classic", "machine", "octagon", "ristretto", "spectrum" },
  bootstrap_variants = { "ristretto" },
  exclude = {
    '^RedrawDebug',
    '^Notify',
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "monokai-pro.nvim" } })
    vim.o.background = "dark"
    require("monokai-pro").setup({
      filter = variant,
      transparent_background = opts.transparency,
    })
    vim.cmd("colorscheme monokai-pro")
  end,
}
