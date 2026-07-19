-- Plugin-backed applier for dracula, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires dracula.nvim installed.
-- The "soft" variant is the plugin's separate `dracula-soft` colorscheme.
return {
  all_variants = { "default", "soft" },
  bootstrap_variants = { "default" },
  exclude = {
    "^RedrawDebug",
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "dracula.nvim" } })
    vim.o.background = "dark"
    require("dracula").setup({
      transparent_bg = opts.transparency,
    })
    vim.cmd("colorscheme " .. (variant == "soft" and "dracula-soft" or "dracula"))
  end,
}
