-- Plugin-backed applier for thorn, used ONLY by scripts/snapshot_theme.lua to
-- capture snapshots. Not loaded at runtime. Requires thorn.nvim.
return {
  all_variants = { "forest", "field" },
  bootstrap_variants = { "forest" },
  exclude = {
    '^RedrawDebug',
    '^Notify',
    '^RenderMarkdown',
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "thorn.nvim" } })
    vim.o.background = (variant == "field") and "light" or "dark"
    require("thorn").setup({ theme = variant, transparent = opts.transparency })
    vim.cmd("colorscheme thorn")
  end,
}
