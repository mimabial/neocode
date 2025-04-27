return {
  "sainnhe/gruvbox-material",
  lazy = false,
  priority = 1000, -- Load before other plugins
  config = function()
    -- Configure gruvbox-material
    vim.g.gruvbox_material_background = "medium" -- Options: 'hard', 'medium', 'soft'
    vim.g.gruvbox_material_better_performance = 1
    vim.g.gruvbox_material_foreground = "material" -- Options: 'material', 'mix', 'original'
    vim.g.gruvbox_material_ui_contrast = "high" -- Options: 'low', 'high'
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_enable_bold = 1
    vim.g.gruvbox_material_transparent_background = 0 -- Set to 1 if you want transparent background
    vim.g.gruvbox_material_sign_column_background = "none"
    vim.g.gruvbox_material_diagnostic_text_highlight = 1
    vim.g.gruvbox_material_diagnostic_line_highlight = 1
    vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
    vim.g.gruvbox_material_current_word = "bold"
    vim.g.gruvbox_material_disable_italic_comment = 0
    
    -- Special highlight groups
    vim.g.gruvbox_material_colors_override = {
      bg0 = { "#282828", "235" },
      bg1 = { "#32302f", "236" },
      bg2 = { "#32302f", "236" },
      bg3 = { "#45403d", "237" },
      bg4 = { "#45403d", "237" },
      bg5 = { "#5a524c", "239" },
      bg_visual = { "#503946", "52" },
      bg_red = { "#4e3e43", "52" },
      bg_green = { "#404d44", "22" },
      bg_blue = { "#394f5a", "17" },
      bg_yellow = { "#4a4940", "136" },
    }
    
    -- Apply colorscheme
    vim.cmd("colorscheme gruvbox-material")
    
    -- Additional customization after colorscheme is loaded
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "gruvbox-material",
      callback = function()
        -- Make the line number more visible
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#a89984" })
        -- Enhance the visual selection
        vim.api.nvim_set_hl(0, "Visual", { bg = "#504945", bold = true })
        -- Better matching parentheses highlight
        vim.api.nvim_set_hl(0, "MatchParen", { fg = "#fabd2f", bg = "#504945", bold = true })
        -- Make comments more readable
        vim.api.nvim_set_hl(0, "Comment", { fg = "#928374", italic = true })
        -- Improve the color for Telescope
        vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#a89984" })
        vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#a89984" })
        vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#a89984" })
        -- Make folders in tree have better visibility
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = "#a89984", bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#a89984" })
      end,
    })
  end,
}
