-- Kanagawa Theme Definition
return {
  icon = "",
  variants = { "wave", "dragon", "lotus" },
  setup = function(opts)
    local variant = opts.variant
    local bg = opts.background

    -- Map variants to their background type
    local dark_variants = { wave = true, dragon = true }

    if variant and bg then
      -- Both set: background wins if conflict
      local variant_is_dark = dark_variants[variant]
      if (variant_is_dark and bg == "light") or (not variant_is_dark and bg == "dark") then
        variant = bg == "light" and "lotus" or "wave"
      end
    elseif variant then
      -- Only variant set: derive background from variant
      bg = dark_variants[variant] and "dark" or "light"
    elseif bg then
      -- Only background set: derive variant from background
      variant = bg == "light" and "lotus" or "wave"
    else
      -- Neither set: defaults
      variant = "wave"
      bg = "dark"
    end

    -- Always call setup with explicit theme to force variant
    require("kanagawa").setup({
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = opts.transparency,
      dimInactive = false,
      terminalColors = true,
      theme = variant,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
    })

    vim.o.background = bg
    vim.cmd("colorscheme kanagawa")

    -- Set colors_name with variant suffix so theme_manager can detect it
    vim.g.colors_name = "kanagawa-" .. variant
  end,
}
