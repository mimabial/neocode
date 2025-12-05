-- Catppuccin Theme Definition
return {
  icon = "",
  variants = { "latte", "frappe", "macchiato", "mocha" },
  setup = function(variant, transparency)
    require("catppuccin").setup({
      flavour = variant or "mocha",
      transparent_background = transparency,
    })
    require("catppuccin").compile()
    vim.cmd("colorscheme catppuccin" .. (variant and ("-" .. variant) or ""))
  end,
}
