-- Plugin-backed applier for solarized, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires solarized.nvim installed.
-- solarized has no variant axis: light/dark is the background, and the plugin
-- reads it straight off vim.o.background.
return {
  exclude = {
    "^RedrawDebug",     -- nvim internal repaint debugger
    "^RenderMarkdown",  -- render-markdown.nvim heading-bg blends
    "^TodoBg",          -- todo-comments.nvim marker-bg blends (builtin Todo kept)
    "^Leap",            -- leap.nvim jump-target tints
  },
  apply = function(_, opts)
    require("lazy").load({ plugins = { "solarized.nvim" } })
    vim.o.background = opts.background or "dark"
    require("solarized").setup({
      transparent = { enabled = opts.transparency },
    })
    vim.cmd("colorscheme solarized")
  end,
}
