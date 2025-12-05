-- Monokai Pro Theme Definition
return {
  icon = "",
  variants = { "pro", "classic", "machine", "octagon", "ristretto", "spectrum" },
  setup = function(variant, transparency)
    require("monokai-pro").setup({
      filter = variant,
      transparent_background = transparency,
    })
    vim.cmd("colorscheme monokai-pro")
  end,
}
