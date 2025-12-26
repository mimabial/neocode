-- Solarized Theme Definition
return {
  setup = function(opts)
    local bg = opts.background or "dark"
    -- Always call setup to handle transparency toggle
    require("solarized").setup({
      transparent = {
        enabled = opts.transparency,
      },
    })
    vim.o.background = bg
    vim.cmd("colorscheme solarized")
  end,
}
