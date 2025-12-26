-- Oxocarbon Theme Definition
return {
  icon = "",
  setup = function(opts)
    vim.o.background = opts.background or "dark"
    -- Apply colorscheme first, then override for transparency
    vim.cmd("colorscheme oxocarbon")
    if opts.transparency then
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    end
    -- Note: disabling transparency requires reloading colorscheme (done above)
  end,
}
