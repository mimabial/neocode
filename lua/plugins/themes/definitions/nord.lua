-- Nord Theme Definition
return {
  icon = "",
  setup = function(opts)
    if opts.transparency then
      vim.g.nord_disable_background = true
    end
    vim.cmd("colorscheme nord")
  end,
}
