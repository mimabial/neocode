-- Gruvbox Material Theme Definition
-- variants are contrast levels (hard/medium/soft), independent of background (dark/light)
return {
  icon = "",
  variants = { "hard", "medium", "soft" },
  setup = function(opts)
    -- Preserve current background if not specified (variants are independent of background)
    local bg = opts.background or vim.o.background or "dark"
    vim.o.background = bg

    if opts.variant then
      vim.g.gruvbox_material_background = opts.variant
    end

    if opts.transparency then
      vim.g.gruvbox_material_transparent_background = 2
    else
      vim.g.gruvbox_material_transparent_background = 0
    end

    vim.cmd("colorscheme gruvbox-material")
  end,
}
