-- Plugin-backed applier for decay, used ONLY by scripts/snapshot_theme.lua to
-- capture snapshots. Not loaded at runtime. Requires decay.nvim.
-- The variant is decay's own style name, passed through untranslated.
return {
  all_variants = { "default", "dark", "decayce" },
  bootstrap_variants = { "default", "decayce" },
  exclude = {
    '^RedrawDebug',
    '^Moonfly',
    '^BlinkIndent',
    '^NvCheatsheet',
    '^Fzf',
    '^Notify',
  },
  -- decay's colorscheme files are named irregularly (decay-default.vim but
  -- decayce.vim), and each just calls load(<style>). Go through load directly
  -- so the variant is the plugin's own style name with no reconstruction.
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "decay.nvim" } })
    vim.o.background = opts.background or "dark"
    require("decay").setup({ style = variant, transparent = opts.transparency })
    require("decay").load(variant)
  end,
}
