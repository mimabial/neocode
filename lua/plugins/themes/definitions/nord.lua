-- Nord Theme Definition
return {
  icon = "",
  variants = {},
  setup = function(variant, transparency)
    if transparency then
      vim.g.nord_disable_background = true
    end
    vim.cmd("colorscheme nord")
  end,
}
