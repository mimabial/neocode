-- Plugin-backed applier for poimandres, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires poimandres.nvim.
return {
  all_variants = { "dark" },
  bootstrap_variants = { "dark" },
  exclude = { "^RedrawDebug" },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "poimandres.nvim" } })
    vim.o.background = "dark"
    require("poimandres").setup({
      disable_background = opts.transparency,
      disable_float_background = opts.transparency,
    })
    vim.cmd("colorscheme poimandres")
  end,
}
