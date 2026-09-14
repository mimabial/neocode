local live = require("lib.live_theme")

return live.definition({
  plugin = "gruvbox.nvim",
  background = function(_, opts)
    return opts.background or vim.o.background
  end,
  apply = function(_, opts)
    require("gruvbox").setup({
      terminal_colors = true,
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true,
      contrast = "",
      palette_overrides = {},
      overrides = {},
      dim_inactive = false,
      transparent_mode = opts.transparency,
    })
    vim.cmd.colorscheme("gruvbox")
  end,
})
