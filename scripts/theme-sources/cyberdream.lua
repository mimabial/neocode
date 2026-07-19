-- Plugin-backed applier for cyberdream, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires cyberdream.nvim installed.
return {
  all_variants = { "default", "light" },
  bootstrap_variants = { "default", "light" },
  exclude = {
    "^RedrawDebug",
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "cyberdream.nvim" } })
    vim.o.background = (variant == "light") and "light" or "dark"
    require("cyberdream").setup({
      variant = variant,
      transparent = opts.transparency,
      terminal_colors = true,
      cache = false,
    })
    vim.cmd("colorscheme cyberdream")
  end,
}
