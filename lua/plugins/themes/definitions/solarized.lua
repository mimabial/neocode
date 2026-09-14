local live = require("lib.live_theme")

return live.definition({
  plugin = "solarized.nvim",
  background = function(_, opts)
    return opts.background or vim.o.background
  end,
  apply = function(_, opts)
    require("solarized").setup({
      transparent = { enabled = opts.transparency },
    })
    vim.cmd.colorscheme("solarized")
  end,
})
