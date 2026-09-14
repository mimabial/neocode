local live = require("lib.live_theme")

return live.definition({
  plugin = "flexoki",
  variants = { "dark", "light" },
  default = "dark",
  background = function(variant) return variant end,
  apply = function(variant)
    vim.cmd.colorscheme("flexoki-" .. variant)
  end,
})
