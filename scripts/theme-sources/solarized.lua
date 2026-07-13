-- Plugin-backed applier for solarized, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires solarized.nvim installed.
return {
  all_variants = { "dark" },
  bootstrap_variants = { "dark" },
  exclude = {
    "^RedrawDebug",     -- nvim internal repaint debugger
    "^RenderMarkdown",  -- render-markdown.nvim heading-bg blends
    "^TodoBg",          -- todo-comments.nvim marker-bg blends (builtin Todo kept)
    "^Leap",            -- leap.nvim jump-target tints
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "solarized.nvim" } })
    vim.o.background = "dark"
    require("solarized").setup({
      transparent = { enabled = opts.transparency },
    })
    vim.cmd("colorscheme solarized")
  end,
}
