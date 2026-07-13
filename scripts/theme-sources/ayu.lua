-- Plugin-backed applier for ayu, used ONLY by scripts/snapshot_theme.lua to
-- capture snapshots. Not loaded at runtime. Requires neovim-ayu installed.
return {
  all_variants = { "dark", "light", "mirage" },
  bootstrap_variants = { "mirage" },
  exclude = {
    "^RedrawDebug", -- nvim internal repaint debugger
    "^Notify",      -- nvim-notify per-level border/icon tints
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "neovim-ayu" } })
    vim.o.background = (variant == "light") and "light" or "dark"
    require("ayu").setup({
      mirage = (variant == "mirage"),
      terminal = true,
    })
    vim.cmd("colorscheme ayu-" .. variant)
  end,
}
