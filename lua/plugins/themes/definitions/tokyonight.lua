local live = require("lib.live_theme")

return live.definition({
  plugin = "tokyonight.nvim",
  variants = { "night", "storm", "day", "moon" },
  default = "storm",
  background = function(variant)
    return variant == "day" and "light" or "dark"
  end,
  apply = function(variant, opts)
    require("tokyonight").setup({
      style = variant,
      transparent = opts.transparency,
    })
    vim.cmd.colorscheme("tokyonight-" .. variant)
  end,
})
