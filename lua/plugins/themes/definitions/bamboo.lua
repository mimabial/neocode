-- Bamboo Theme Definition
return {
  icon = "",
  variants = { "vulgaris", "multiplex", "light" },
  setup = function(opts)
    local variant = opts.variant
    local bg = opts.background

    -- Map variants to their background type
    local dark_variants = { vulgaris = true, multiplex = true }

    if variant and bg then
      -- Both set: background wins if conflict
      local variant_is_dark = dark_variants[variant]
      if (variant_is_dark and bg == "light") or (not variant_is_dark and bg == "dark") then
        variant = bg == "light" and "light" or "vulgaris"
      end
    elseif variant then
      -- Only variant set: derive background from variant
      bg = dark_variants[variant] and "dark" or "light"
    elseif bg then
      -- Only background set: derive variant from background
      variant = bg == "light" and "light" or "vulgaris"
    else
      -- Neither set: defaults
      variant = "vulgaris"
      bg = "dark"
    end

    vim.o.background = bg
    require("bamboo").setup({
      style = variant,
      transparent = opts.transparency,
    })
    require("bamboo").load()
  end,
}
