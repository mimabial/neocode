return {
  icon = "",
  setup = function(opts)
    vim.o.background = "dark"

    require("poimandres").setup({
      disable_background = opts.transparency,
      disable_float_background = opts.transparency,
    })
    vim.cmd("colorscheme poimandres")
  end,
}
