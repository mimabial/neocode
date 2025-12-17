-- Catppuccin Theme Definition
return {
  icon = "",
  variants = { "latte", "frappe", "macchiato", "mocha" },
  setup = function(opts)
    local variant = opts.variant
    local bg = opts.background

    -- Map variants to their background type
    local dark_variants = { frappe = true, macchiato = true, mocha = true }

    if variant and bg then
      -- Both set: background wins if conflict
      local variant_is_dark = dark_variants[variant]
      if (variant_is_dark and bg == "light") or (not variant_is_dark and bg == "dark") then
        variant = bg == "light" and "latte" or "mocha"
      end
    elseif variant then
      -- Only variant set: derive background from variant
      bg = dark_variants[variant] and "dark" or "light"
    elseif bg then
      -- Only background set: derive variant from background
      variant = bg == "light" and "latte" or "mocha"
    else
      -- Neither set: defaults
      variant = "mocha"
      bg = "dark"
    end

    vim.o.background = bg
    require("catppuccin").setup({
      flavour = variant,
      transparent_background = opts.transparency,
    })
    require("catppuccin").compile()
    vim.cmd("colorscheme catppuccin-" .. variant)
  end,
}
