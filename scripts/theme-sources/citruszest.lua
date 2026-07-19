-- Plugin-backed applier for citruszest, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires citruszest.nvim installed.
-- Single dark scheme, no variant axis; options are transparent/italic/bold.
return {
  exclude = { "^RedrawDebug" },
  apply = function(_, opts)
    require("lazy").load({ plugins = { "citruszest.nvim" } })
    vim.o.background = "dark"
    require("citruszest").setup({ option = { transparent = opts.transparency } })
    vim.cmd("colorscheme citruszest")
  end,
}
