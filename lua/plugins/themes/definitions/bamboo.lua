-- Bamboo Theme Definition
return {
  icon = "",
  variants = { "vulgaris", "multiplex", "light" },
  setup = function(variant, transparency)
    require("bamboo").setup({
      style = variant,
      transparent = transparency,
    })
    require("bamboo").load()
  end,
}
