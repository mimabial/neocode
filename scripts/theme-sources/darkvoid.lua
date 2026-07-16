-- Plugin-backed applier for darkvoid, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires darkvoid.nvim.
return {
  all_variants = { "default", "glow" },
  bootstrap_variants = { "glow" },
  exclude = {
    '^RedrawDebug',
    '^Oil',
    '^GitSignsStaged',
    '^lualine',
    '^Notify',
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "darkvoid.nvim" } })
    vim.o.background = "dark"
    require("darkvoid").setup({
      glow = (variant == "glow"),
      transparent = opts.transparency,
    })
    vim.cmd("colorscheme darkvoid")
  end,
}
