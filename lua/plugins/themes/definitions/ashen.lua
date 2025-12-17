-- Ashen Theme Definition
return {
  icon = "",
  setup = function(opts)
    require("ashen").setup({ transparent = opts.transparency })
    vim.cmd("colorscheme ashen")
  end,
}
