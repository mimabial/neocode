return {
  icon = "",
  variants = { "dark", "light" },
  setup = function(variant, transparency)
    require("thorn").setup({
      theme = variant or "dark",
      background = "warm",
      transparent = transparency,
    })
    vim.cmd("colorscheme thorn")
  end,
}

