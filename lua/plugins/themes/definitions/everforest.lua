-- Everforest Theme Definition
-- variants are contrast levels (soft/medium/hard), independent of background (dark/light)
return {
  icon = "",
  variants = { "soft", "medium", "hard" },
  setup = function(opts)
    -- Preserve current background if not specified (variants are independent of background)
    local bg = opts.background or vim.o.background or "dark"
    vim.o.background = bg

    if opts.variant then
      vim.g.everforest_background = opts.variant
    end

    if opts.transparency then
      vim.g.everforest_transparent_background = 2
    else
      vim.g.everforest_transparent_background = 0
    end

    vim.cmd("colorscheme everforest")
  end,
}
