-- Plugin-backed applier for fluoromachine, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires fluoromachine.nvim installed.
-- The plugin's `theme` is fixed to fluoromachine; the variant axis carries its
-- `glow` bloom (default = off, glow = on), mirroring darkvoid. glow bakes a bg
-- halo + bold into many groups and shifts the base bg, so it must be captured.
return {
  all_variants = { "default", "glow" },
  bootstrap_variants = { "default", "glow" },
  exclude = {
    "^RedrawDebug",
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "fluoromachine.nvim" } })
    vim.o.background = "dark"
    require("fluoromachine").setup({
      theme = "fluoromachine",
      glow = (variant == "glow"),
      transparent = opts.transparency,
    })
    vim.cmd("colorscheme fluoromachine")
  end,
}
