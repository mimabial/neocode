-- Onedark Theme Definition
return {
  icon = "",
  variants = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },
  setup = function(opts)
    local variant = opts.variant
    local bg = opts.background

    -- Map variants to their background type (all except "light" are dark)
    local dark_variants = { dark = true, darker = true, cool = true, deep = true, warm = true, warmer = true }

    if variant and bg then
      -- Both set: background wins if conflict
      local variant_is_dark = dark_variants[variant]
      if (variant_is_dark and bg == "light") or (not variant_is_dark and bg == "dark") then
        variant = bg == "light" and "light" or "dark"
      end
    elseif variant then
      -- Only variant set: derive background from variant
      bg = dark_variants[variant] and "dark" or "light"
    elseif bg then
      -- Only background set: derive variant from background
      variant = bg == "light" and "light" or "dark"
    else
      -- Neither set: defaults
      variant = "dark"
      bg = "dark"
    end

    require("onedark").setup({
      style = variant,
      transparent = opts.transparency,
    })

    vim.o.background = bg
    vim.cmd("colorscheme onedark")
    vim.g.colors_name = "onedark-" .. variant
  end,
}
