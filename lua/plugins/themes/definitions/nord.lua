local live = require("lib.live_theme")

return live.definition({
  plugin = "nord.nvim",
  background = "dark",
  apply = function(_, opts)
    vim.g.nord_disable_background = opts.transparency
    vim.cmd.colorscheme("nord")
  end,
})
