local live = require("lib.live_theme")

return live.definition({
  plugin = "ashen.nvim",
  background = "dark",
  apply = function(_, opts)
    require("ashen").setup({ transparent = opts.transparency })
    vim.cmd.colorscheme("ashen")
  end,
})
