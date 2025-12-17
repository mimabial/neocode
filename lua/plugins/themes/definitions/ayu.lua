-- Ayu Theme Definition
return {
  icon = "",
  variants = { "dark", "light", "mirage" },
  setup = function(opts)
    local variant = opts.variant
    local bg = opts.background

    -- Map variants to their background type
    local dark_variants = { dark = true, mirage = true }

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

    local ayu_config = {
      mirage = variant == "mirage",
      terminal = true,
    }

    -- Handle transparency via overrides
    if opts.transparency then
      ayu_config.overrides = {
        Normal = { bg = "None" },
        NormalFloat = { bg = "None" },
        ColorColumn = { bg = "None" },
        SignColumn = { bg = "None" },
        Folded = { bg = "None" },
        FoldColumn = { bg = "None" },
        CursorLine = { bg = "None" },
        CursorColumn = { bg = "None" },
        VertSplit = { bg = "None" },
      }
    end

    require("ayu").setup(ayu_config)

    vim.o.background = bg
    vim.cmd("colorscheme ayu-" .. variant)
  end,
}
