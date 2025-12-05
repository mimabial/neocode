-- Onedark Theme Definition
return {
  icon = "",
  variants = { "dark", "darker", "cool", "deep", "warm", "warmer" },
  setup = function(variant, transparency)
    require("onedark").setup({
      style = variant,
      transparent = transparency,
    })
    vim.cmd("colorscheme onedark")
  end,
}
