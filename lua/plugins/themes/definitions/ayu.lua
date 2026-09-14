local live = require("lib.live_theme")

return live.definition({
  plugin = "neovim-ayu",
  variants = { "dark", "light", "mirage" },
  default = "mirage",
  background = function(variant)
    return variant == "light" and "light" or "dark"
  end,
  apply = function(variant)
    require("ayu").setup({
      mirage = variant == "mirage",
      terminal = true,
    })
    vim.cmd.colorscheme("ayu-" .. variant)
  end,
})
