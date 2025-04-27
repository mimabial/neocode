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
    
    -- Enhance colors for web development with HTMX and Go
    vim.g.gruvbox_material_better_performance = 1
    
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
        
        -- Enhance syntax highlighting for web development
        vim.api.nvim_set_hl(0, "htmlTag", { fg = "#7daea3", bold = true })
        vim.api.nvim_set_hl(0, "htmlEndTag", { fg = "#7daea3", bold = true })
        vim.api.nvim_set_hl(0, "htmlArg", { fg = "#d8a657", italic = true })
        vim.api.nvim_set_hl(0, "htmlTagName", { fg = "#ea6962" })
        
        -- HTMX specific highlights (for treesitter)
        vim.api.nvim_set_hl(0, "@attribute.htmx", { fg = "#89b482", italic = true, bold = true })
        vim.api.nvim_set_hl(0, "@tag.attribute.htmx", { fg = "#89b482", italic = true, bold = true })
        
        -- Go specific highlights
        vim.api.nvim_set_hl(0, "@type.go", { fg = "#89b482" })
        vim.api.nvim_set_hl(0, "@function.go", { fg = "#7daea3" })
        vim.api.nvim_set_hl(0, "@variable.go", { fg = "#d3869b" })
        
        -- NextJS/React specific highlights
        vim.api.nvim_set_hl(0, "@tag.jsx", { fg = "#ea6962" })
        vim.api.nvim_set_hl(0, "@tag.tsx", { fg = "#ea6962" })
        vim.api.nvim_set_hl(0, "@constructor.jsx", { fg = "#7daea3" })
        vim.api.nvim_set_hl(0, "@constructor.tsx", { fg = "#7daea3" })
      end,
    })
    
    -- Add custom filetype detection for .templ files (Go templates)
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = "*.templ",
      callback = function()
        vim.bo.filetype = "templ"
      end,
    })
    
    -- Add custom highlighting for HTMX attributes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "html", "templ" },
      callback = function()
        -- Match HTMX attributes for syntax highlighting
        vim.cmd([[
          syntax match htmlArg contained "\<hx-[a-zA-Z\-]\+\>" 
          highlight link htmlArg @attribute.htmx
        ]])
      end,
    })
  end,
}
