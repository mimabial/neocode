-- Rose Pine Theme Definition
return {
  icon = "",
  variants = { "main", "moon", "dawn" },
  setup = function(variant, transparency)
    require("rose-pine").setup({
      variant = variant,
      disable_background = transparency,
    })
    vim.cmd("colorscheme rose-pine")
  end,
}
