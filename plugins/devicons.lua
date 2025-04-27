return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
  opts = {
    -- Override default icon colors based on gruvbox-material
    override_by_extension = {
      -- Example overrides (you can customize these based on your preference)
      ["lua"] = {
        color = "#89b482",
      },
      ["js"] = {
        color = "#d8a657",
      },
    },
  },
}
