-- Nord Theme Definition
return {
  icon = "",
  setup = function(opts)
    -- Must explicitly set to false to disable transparency (nil won't work)
    vim.g.nord_disable_background = opts.transparency or false
    vim.cmd("colorscheme nord")
  end,
}
