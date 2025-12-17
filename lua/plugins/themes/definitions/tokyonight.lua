-- Tokyonight Theme Definition
return {
  icon = "",
  variants = { "night", "storm", "day", "moon" },
  setup = function(opts)
    local variant = opts.variant
    local bg = opts.background

    -- Map variants to their background type
    local dark_variants = { night = true, storm = true, moon = true }

    if variant and bg then
      -- Both set: background wins if conflict
      local variant_is_dark = dark_variants[variant]
      if (variant_is_dark and bg == "light") or (not variant_is_dark and bg == "dark") then
        variant = bg == "light" and "day" or "night"
      end
    elseif variant then
      -- Only variant set: derive background from variant
      bg = dark_variants[variant] and "dark" or "light"
    elseif bg then
      -- Only background set: derive variant from background
      variant = bg == "light" and "day" or "night"
    else
      -- Neither set: defaults
      variant = "night"
      bg = "dark"
    end

    vim.o.background = bg
    require("tokyonight").setup({
      style = variant,
      transparent = opts.transparency,
    })
    vim.cmd("colorscheme tokyonight-" .. variant)
  end,
}
