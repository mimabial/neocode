-- Ashen Theme Definition
return {
  icon = "",
  variants = {},
  setup = function(variant, transparency)
    require("ashen").setup({ transparent = transparency })
    vim.cmd("colorscheme ashen")
  end,
}
