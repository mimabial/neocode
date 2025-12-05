-- Theme Name Definition
-- Copy this template to create new theme definitions
-- Filename should match the theme name (e.g., tokyonight.lua)

return {
  -- Icon for theme (optional)
  icon = "",

  -- List of variants (empty table if no variants)
  variants = { "variant1", "variant2" },

  -- Setup function called when theme is applied
  -- @param variant string|nil - Selected variant (if any)
  -- @param transparency boolean - Whether to enable transparency
  setup = function(variant, transparency)
    -- Example: Configure the theme plugin
    require("theme-plugin-name").setup({
      -- Theme-specific configuration
      transparent = transparency,
      -- Add other config options...
    })

    -- Apply the colorscheme
    vim.cmd("colorscheme theme-name")
  end,
}
