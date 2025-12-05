-- Gruvbox Theme Definition
return {
  icon = "",
  variants = { "dark", "light" },
  setup = function(variant, transparency)
    require("gruvbox").setup({
      terminal_colors = true,
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true,
      contrast = "",
      palette_overrides = {},
      overrides = {},
      dim_inactive = false,
      transparent_mode = transparency,
    })

    if variant == "light" then
      vim.o.background = "light"
    else
      vim.o.background = "dark"
    end
    vim.cmd("colorscheme gruvbox")
  end,
}
