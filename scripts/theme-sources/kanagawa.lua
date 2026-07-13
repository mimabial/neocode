-- Plugin-backed applier for kanagawa, used ONLY by scripts/snapshot_theme.lua
-- to capture snapshots. Not loaded at runtime. Requires kanagawa.nvim installed.
-- Mirrors the definition's setup so the capture matches how it rendered.
return {
  all_variants = { "wave", "dragon", "lotus" },
  bootstrap_variants = { "wave" },
  exclude = { "^RedrawDebug" },
  apply = function(variant, opts)
    require("lazy").load({ plugins = { "kanagawa.nvim" } })
    local dark = { wave = true, dragon = true }
    vim.o.background = dark[variant] and "dark" or "light"
    require("kanagawa").setup({
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = opts.transparency,
      dimInactive = false,
      terminalColors = true,
      theme = variant,
      colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
    })
    vim.cmd("colorscheme kanagawa")
  end,
}
