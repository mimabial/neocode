return {
  icon = "",
  setup = function(opts)
    vim.o.background = "dark"

    require("gruber-darker").setup()
    vim.cmd("colorscheme gruber-darker")

    if opts.transparency then
      vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    end
  end,
}
