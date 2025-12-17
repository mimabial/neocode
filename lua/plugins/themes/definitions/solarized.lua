-- Solarized Theme Definition
return {
  setup = function(opts)
    local bg = opts.background or "dark"
    -- Only call setup and colorscheme on first load
    if vim.g.colors_name ~= "solarized" then
      require("solarized").setup({
        transparent = {
          enabled = opts.transparency,
        },
      })
      vim.o.background = bg
      vim.cmd("colorscheme solarized")
    else
      -- Just toggle background - defer to avoid flicker
      vim.schedule(function()
        vim.o.background = bg
      end)
    end
  end,
}
