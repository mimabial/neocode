-- Plugin-backed applier for moonfly, used ONLY by scripts/snapshot_theme.lua to
-- capture snapshots. Not loaded at runtime. Requires moonfly.
return {
  all_variants = { "dark" },
  bootstrap_variants = { "dark" },
  exclude = {
    '^RedrawDebug',
    '^Moonfly',
    '^BlinkIndent',
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "moonfly" } })
    vim.o.background = "dark"
    vim.g.moonflyTransparent = opts.transparency == true
    vim.cmd("colorscheme moonfly")
  end,
}
