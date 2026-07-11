-- Moonfly Theme Definition
return {
  icon = "",
  setup = function(opts)
    vim.o.background = "dark"
      vim.g.moonflyTransparent = opts.transparency == true
    vim.cmd("colorscheme moonfly")
  end,
}
