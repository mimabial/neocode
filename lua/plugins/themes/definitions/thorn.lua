return {
  variants = { "warm", "cold" },
  setup = function(opts)
    -- Use current vim.o.background if not specified (preserves background when cycling variants)
    local bg = opts.background or vim.o.background or "dark"
    require("thorn").setup({
      theme = bg,
      background = opts.variant or "warm",
      transparent = opts.transparency,
    })
    vim.o.background = bg
    vim.cmd("colorscheme thorn")
  end,
}

