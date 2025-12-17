-- Rose Pine Theme Definition
return {
  icon = "",
  variants = { "main", "moon", "dawn" },
  setup = function(opts)
    local variant = opts.variant
    local bg = opts.background

    -- Map variants to their background type (main/moon are dark, dawn is light)
    local dark_variants = { main = true, moon = true }

    if variant and bg then
      -- Both set: background wins if conflict
      local variant_is_dark = dark_variants[variant]
      if (variant_is_dark and bg == "light") or (not variant_is_dark and bg == "dark") then
        variant = bg == "light" and "dawn" or "main"
      end
    elseif variant then
      -- Only variant set: derive background from variant
      bg = dark_variants[variant] and "dark" or "light"
    elseif bg then
      -- Only background set: derive variant from background
      variant = bg == "light" and "dawn" or "main"
    else
      -- Neither set: defaults
      variant = "main"
      bg = "dark"
    end

    require("rose-pine").setup({
      variant = variant,
      disable_background = opts.transparency,
    })

    vim.cmd("colorscheme rose-pine")
    vim.o.background = bg
    vim.g.colors_name = "rose-pine-" .. variant
  end,
}
