-- Decay Theme Definition
return {
  icon = "",
  variants = { "default", "dark", "light", "decayce" },
  setup = function(opts)
    local variant = opts.variant
    local bg = opts.background

    -- Map variants to their background type
    local dark_variants = { default = true, dark = true, decayce = true }

    if variant and bg then
      -- Both set: background wins if conflict
      local variant_is_dark = dark_variants[variant]
      if (variant_is_dark and bg == "light") or (not variant_is_dark and bg == "dark") then
        variant = bg == "light" and "light" or "default"
      end
    elseif variant then
      -- Only variant set: derive background from variant
      bg = dark_variants[variant] and "dark" or "light"
    elseif bg then
      -- Only background set: derive variant from background
      variant = bg == "light" and "light" or "default"
    else
      -- Neither set: defaults
      variant = "default"
      bg = "dark"
    end

    vim.o.background = bg

    require("decay").setup({
      style = variant ~= "light" and variant or "default",
      transparent = opts.transparency,
    })

    if variant == "decayce" then
      vim.cmd("colorscheme decayce")
      vim.g.colors_name = "decayce"
    else
      vim.cmd("colorscheme decay-" .. variant)
      vim.g.colors_name = "decay-" .. variant
    end
  end,
}
