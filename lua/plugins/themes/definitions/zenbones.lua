local live = require("lib.live_theme")

return live.definition({
  plugin = "zenbones",
  variants = { "default" },
  default = "default",
  background = "dark",
  apply = function(_, opts)
    vim.g.zenbones_darkness = nil
    vim.g.zenbones_transparent_background = opts.transparency
    vim.cmd.colorscheme("zenbones")
  end,
})
