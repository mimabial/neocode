local live = require("lib.live_theme")

return live.definition({
  plugin = "citruszest.nvim",
  background = "dark",
  apply = function(_, opts)
    require("citruszest").setup({ option = { transparent = opts.transparency } })
    vim.cmd.colorscheme("citruszest")
  end,
})
