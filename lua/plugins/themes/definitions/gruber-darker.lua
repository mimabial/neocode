return {
  icon = "",
  setup = function(opts)
    vim.o.background = "dark"

    require("gruber-darker").setup()
    vim.cmd("colorscheme gruber-darker")
  end,
}
