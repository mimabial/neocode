local live = require("lib.live_theme")

return live.definition({
  plugin = "duskhaven.nvim",
  background = "dark",
  apply = function()
    vim.cmd.colorscheme("duskhaven")
  end,
})
