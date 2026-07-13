return {
  icon = "",
  setup = function(opts)
    vim.o.background = "dark"
    vim.cmd("colorscheme duskhaven")

    if opts.transparency then
      vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    end
  end,
}
