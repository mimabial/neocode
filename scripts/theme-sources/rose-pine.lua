-- Plugin-backed applier for rose-pine, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires rose-pine installed.
return {
  all_variants = { "main", "moon", "dawn" },
  bootstrap_variants = { "main", "dawn" },
  exclude = {
    "^RedrawDebug",     -- nvim internal repaint debugger
    "^RenderMarkdown",  -- render-markdown.nvim heading-bg blends
    "^Hop",             -- hop.nvim jump-key tints
    "^Pounce",          -- pounce.nvim jump-key tints
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "rose-pine" } })
    local dark = { main = true, moon = true }
    vim.o.background = dark[variant] and "dark" or "light"
    require("rose-pine").setup({
      variant = variant,
      disable_background = opts.transparency,
    })
    vim.cmd("colorscheme rose-pine")
  end,
}
