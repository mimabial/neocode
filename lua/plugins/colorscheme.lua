return {
  "sainnhe/gruvbox-material",
  lazy = false,
  priority = 1000, -- Load before other plugins
  config = function()
    -- Configure gruvbox-material
    vim.g.gruvbox_material_background = "medium" -- Options: 'hard', 'medium', 'soft'
    vim.g.gruvbox_material_better_performance = 1
    vim.g.gruvbox_material_foreground = "original" -- Options: 'material', 'mix', 'original'
    vim.g.gruvbox_material_ui_contrast = "high" -- Options: 'low', 'high'
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_enable_bold = 1
    vim.g.gruvbox_material_transparent_background = 0 -- Set to 1 if you want transparent background
    vim.g.gruvbox_material_sign_column_background = "none"
    vim.g.gruvbox_material_diagnostic_text_highlight = 1
    vim.g.gruvbox_material_diagnostic_line_highlight = 1
    vim.g.gruvbox_material_diagnostic_virtual_text = "colored"

    -- Apply colorscheme
    vim.cmd("colorscheme gruvbox-material")
  end,
}
