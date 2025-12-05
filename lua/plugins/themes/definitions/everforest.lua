-- Everforest Theme Definition
return {
  icon = "",
  variants = { "soft", "medium", "hard" },
  setup = function(variant, transparency)
    vim.o.background = "dark"
    if variant then
      vim.g.everforest_background = variant
    end
    if transparency then
      vim.g.everforest_transparent_background = 1
    end
    vim.cmd("colorscheme everforest")
  end,
}
