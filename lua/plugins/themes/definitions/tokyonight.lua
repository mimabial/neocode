-- Tokyonight Theme Definition
return {
  icon = "",
  variants = { "night", "storm", "day", "moon" },
  setup = function(variant, transparency)
    require("tokyonight").setup({
      style = variant,
      transparent = transparency,
    })
    vim.cmd("colorscheme tokyonight" .. (variant and "-" .. variant or ""))
  end,
}
