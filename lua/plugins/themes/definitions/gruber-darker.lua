local live = require("lib.live_theme")

return live.definition({
  plugin = "gruber-darker.nvim",
  background = "dark",
  apply = function()
    require("gruber-darker").setup()
    vim.cmd.colorscheme("gruber-darker")
  end,
})
