-- Plugin-backed applier for decay, used ONLY by scripts/snapshot_theme.lua to
-- capture snapshots. Not loaded at runtime. Requires decay.nvim.
-- "green" is an alias for decay's signature default palette (its green look).
return {
  all_variants = { "green", "dark", "decayce" },
  bootstrap_variants = { "green" },
  exclude = {
    '^RedrawDebug',
    '^Moonfly',
    '^BlinkIndent',
    '^NvCheatsheet',
    '^Fzf',
    '^Notify',
  },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "decay.nvim" } })
    local style = (variant == "green") and "default" or variant
    vim.o.background = "dark"
    require("decay").setup({ style = style, transparent = opts.transparency })
    vim.cmd("colorscheme decay-" .. style)
  end,
}
