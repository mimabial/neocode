-- Plugin-backed applier for onedark, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires onedark.nvim installed.
return {
  all_variants = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },
  bootstrap_variants = { "dark" },
  exclude = {
    "^RedrawDebug",  -- nvim internal repaint debugger
    "^GitConflict",  -- git-conflict.nvim tints
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "onedark.nvim" } })
    vim.o.background = (variant == "light") and "light" or "dark"
    require("onedark").setup({
      style = variant,
      transparent = opts.transparency,
    })
    vim.cmd("colorscheme onedark")
  end,
}
