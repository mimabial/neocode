local live = require("lib.live_theme")

return live.definition({
  plugin = "kanagawa.nvim",
  variants = { "wave", "dragon" },
  default = "wave",
  background = "dark",
  apply = function(variant, opts)
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
    vim.cmd.colorscheme("kanagawa")
  end,
})
