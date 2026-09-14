local live = require("lib.live_theme")

return live.definition({
  plugin = "catppuccin",
  variants = { "latte", "frappe", "macchiato", "mocha" },
  default = "mocha",
  background = function(variant)
    return variant == "latte" and "light" or "dark"
  end,
  apply = function(variant, opts)
    require("catppuccin").setup({
      flavour = variant,
      term_colors = true,
      transparent_background = opts.transparency,
    })
    require("catppuccin").compile()
    vim.cmd.colorscheme("catppuccin-" .. variant)
  end,
})
