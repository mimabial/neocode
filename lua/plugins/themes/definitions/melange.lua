local live = require("lib.live_theme")

return live.definition({
  plugin = "melange",
  variants = { "dark", "light" },
  default = "light",
  background = function(variant, opts)
    return opts.background or variant
  end,
  apply = function()
    vim.cmd.colorscheme("melange")
  end,
})
