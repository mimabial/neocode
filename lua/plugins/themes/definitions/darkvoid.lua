local live = require("lib.live_theme")

return live.definition({
  plugin = "darkvoid.nvim",
  variants = { "default", "glow" },
  default = "glow",
  background = "dark",
  apply = function(variant, opts)
    require("darkvoid").setup({
      glow = variant == "glow",
      transparent = opts.transparency,
    })
    vim.cmd.colorscheme("darkvoid")
  end,
})
