-- Plugin-backed applier for ashen, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires ashen.nvim installed.
return {
  all_variants = { "dark" },
  bootstrap_variants = { "dark" },
  exclude = { "^RedrawDebug" },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "ashen.nvim" } })
    vim.o.background = "dark"
    require("ashen").setup({ transparent = opts.transparency })
    vim.cmd("colorscheme ashen")
  end,
}
