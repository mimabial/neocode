local live = require("lib.live_theme")

return live.definition({
  plugin = "cyberdream.nvim",
  variants = { "default", "light" },
  default = "default",
  background = function(variant)
    return variant == "light" and "light" or "dark"
  end,
  apply = function(variant, opts)
    require("cyberdream").setup({
      variant = variant,
      transparent = opts.transparency,
      terminal_colors = true,
      cache = false,
    })
    vim.cmd.colorscheme("cyberdream")
  end,
})
