-- Gruvbox Material Theme Definition
return {
  icon = "",
  variants = { "hard", "medium", "soft" },
  setup = function(variant, transparency)
    vim.o.background = "dark"
    if variant then
      vim.g.gruvbox_material_background = variant
    end
    vim.g.gruvbox_material_transparent_background = 0

    vim.cmd("colorscheme gruvbox-material")
  end,
}
