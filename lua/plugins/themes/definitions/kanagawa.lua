return {
  icon = "",
  variants = { "wave", "dragon", "lotus" },
  setup = function(opts)
    local variant = opts.variant
    local bg = opts.background
    local dark_variants = { wave = true, dragon = true }

    if variant and bg then
      -- background wins if it conflicts with the variant's natural mode
      local variant_is_dark = dark_variants[variant]
      if (variant_is_dark and bg == "light") or (not variant_is_dark and bg == "dark") then
        variant = bg == "light" and "lotus" or "wave"
      end
    elseif variant then
      bg = dark_variants[variant] and "dark" or "light"
    elseif bg then
      variant = bg == "light" and "lotus" or "wave"
    else
      variant = "wave"
      bg = "dark"
    end

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

    -- Variant suffix lets theme_manager detect which variant is active.
    vim.g.colors_name = "kanagawa-" .. variant
  end,
}
