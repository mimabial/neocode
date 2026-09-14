local live = require("lib.live_theme")

return live.definition({
  plugin = "fluoromachine.nvim",
  variants = { "default", "glow" },
  default = "default",
  background = "dark",
  apply = function(variant, opts)
    require("fluoromachine").setup({
      theme = "fluoromachine",
      glow = variant == "glow",
      transparent = opts.transparency,
    })
    vim.cmd.colorscheme("fluoromachine")
  end,
})
