-- Dracula Theme Definition
return {
  icon = "",
  setup = function(opts)
    vim.o.background = opts.background or "dark"
    require("dracula").setup({
      transparent_bg = opts.transparency,
    })
    vim.cmd("colorscheme dracula")
  end,
}
