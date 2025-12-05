-- Decay Theme Definition
return {
  icon = "",
  variants = { "default", "dark", "light", "decayce" },
  setup = function(variant, transparency)
    if variant == "light" then
      vim.o.background = "light"
    else
      vim.o.background = "dark"
    end

    require("decay").setup({
      style = variant ~= "light" and variant or "default",
      transparent = transparency,
    })

    if variant == "decayce" then
      vim.cmd("colorscheme decayce")
      vim.g.colors_name = "decayce"
    else
      vim.cmd("colorscheme decay" .. (variant and "-" .. variant or ""))
      vim.g.colors_name = "decay" .. (variant and "-" .. variant or "")
    end
  end,
}
