local live = require("lib.live_theme")

return live.definition({
  plugin = "onedark.nvim",
  variants = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },
  default = "dark",
  background = function(variant)
    return variant == "light" and "light" or "dark"
  end,
  apply = function(variant, opts)
    require("onedark").setup({
      style = variant,
      transparent = opts.transparency,
    })
    vim.cmd.colorscheme("onedark")
  end,
})
