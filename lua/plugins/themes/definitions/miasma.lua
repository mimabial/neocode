local live = require("lib.live_theme")

return live.definition({
  plugin = "miasma.nvim",
  background = "dark",
  apply = function()
    vim.cmd.colorscheme("miasma")
  end,
})
