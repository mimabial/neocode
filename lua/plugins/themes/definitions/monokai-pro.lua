-- Monokai Pro Theme Definition
return {
  icon = "",
  variants = { "pro", "classic", "machine", "octagon", "ristretto", "spectrum" },
  setup = function(opts)
    require("monokai-pro").setup({
      filter = opts.variant,
      transparent_background = opts.transparency,
    })
    vim.cmd("colorscheme monokai-pro")
  end,
}
