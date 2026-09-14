local live = require("lib.live_theme")

return live.definition({
  plugin = "moonfly",
  background = "dark",
  apply = function(_, opts)
    vim.g.moonflyTransparent = opts.transparency == true
    vim.cmd.colorscheme("moonfly")
  end,
})
