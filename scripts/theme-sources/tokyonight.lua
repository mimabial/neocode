-- Plugin-backed applier for tokyonight, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires tokyonight.nvim installed.
return {
  all_variants = { "night", "storm", "day", "moon" },
  bootstrap_variants = { "storm" },
  exclude = {
    "^RedrawDebug",                  -- nvim internal repaint debugger
    "^Notify",                       -- nvim-notify per-level border/bg tints
    "^Octo",                         -- octo.nvim github-UI tints
    "@markup%.heading%.%d.*markdown", -- markdown heading-bg decoration tints
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "tokyonight.nvim" } })
    local dark = { night = true, storm = true, moon = true }
    vim.o.background = dark[variant] and "dark" or "light"
    require("tokyonight").setup({
      style = variant,
      transparent = opts.transparency,
    })
    vim.cmd("colorscheme tokyonight-" .. variant)
  end,
}
