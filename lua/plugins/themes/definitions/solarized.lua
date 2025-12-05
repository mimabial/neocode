-- Solarized Theme Definition
return {
  icon = "",
  variants = { "dark", "light" },
  setup = function(variant, transparency)
    vim.o.background = variant or "dark"
    require("solarized").setup({
      transparent = {
        enabled = transparency,
      },
    })
    vim.cmd("colorscheme solarized")
  end,
}
