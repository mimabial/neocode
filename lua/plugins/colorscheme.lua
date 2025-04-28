return {
  {
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
      
      -- Better Colors for UI
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
          
          -- Improve the color for UI elements
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
          
          -- Status line improvements
          vim.api.nvim_set_hl(0, "StatusLine", { bg = "#3c3836", fg = "#d4be98" })
          vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "#32302f", fg = "#a89984" })
          
          -- Floating windows
          vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#7c6f64" })
          vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#282828" })
          
          -- WhichKey improvements
          vim.api.nvim_set_hl(0, "WhichKey", { fg = "#d8a657", bold = true })
          vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = "#ea6962" })
          vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = "#928374" })
          vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = "#89b482" })
          
          -- Treesitter context for code blocks
          vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#32302f" })
          vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = "#a89984", bg = "#32302f" })
        end,
      })
      
      -- Handle filetype detection for GOTH stack
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
          vim.cmd([[
            syntax match htmlArg contained "\<hx-[a-zA-Z\-]\+\>" 
            highlight link htmlArg @attribute.htmx
          ]])
        end,
      })
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 900, -- Load before other plugins but after gruvbox-material
    opts = {
      style = "storm", -- Options: storm, moon, night, day
      light_style = "day",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },
      sidebars = { "qf", "help", "terminal", "packer", "neo-tree" },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = false,
      
      -- Custom overrides
      on_colors = function(colors)
        -- Add specific color overrides for GOTH stack
        colors.comment = "#9ca0a4"  -- Brighter comments
        colors.fg_gutter = "#4a5057" -- Brighter line numbers
      end,
      
      on_highlights = function(highlights, colors)
        -- Improve UI elements
        highlights.LineNr = { fg = colors.fg_gutter }
        highlights.CursorLineNr = { fg = colors.orange }
        
        -- Enhance terminal colors
        highlights.TermCursor = { fg = colors.bg, bg = colors.green }
        
        -- HTMX Specific highlights
        highlights["@attribute.htmx"] = { fg = colors.green, italic = true, bold = true }
        highlights["@tag.attribute.htmx"] = { fg = colors.green, italic = true, bold = true }
        
        -- Go specific highlights
        highlights["@type.go"] = { fg = colors.blue }
        highlights["@function.go"] = { fg = colors.cyan }
        
        -- React/NextJS specific
        highlights["@tag.jsx"] = { fg = colors.red }
        highlights["@tag.tsx"] = { fg = colors.red }
        highlights["@constructor.jsx"] = { fg = colors.blue }
        highlights["@constructor.tsx"] = { fg = colors.blue }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      
      -- Add a command to switch between themes
      vim.api.nvim_create_user_command("ColorSchemeToggle", function()
        local current = vim.g.colors_name
        if current == "gruvbox-material" then
          vim.cmd("colorscheme tokyonight")
          vim.notify("Switched to TokyoNight theme", vim.log.levels.INFO)
        else
          vim.cmd("colorscheme gruvbox-material")
          vim.notify("Switched to Gruvbox Material theme", vim.log.levels.INFO)
        end
      end, { desc = "Toggle between Gruvbox Material and TokyoNight" })
      
      -- Create a command to toggle background transparency
      vim.api.nvim_create_user_command("ToggleTransparency", function()
        local current = vim.g.colors_name
        
        if current == "gruvbox-material" then
          -- For gruvbox-material
          if vim.g.gruvbox_material_transparent_background == 1 then
            vim.g.gruvbox_material_transparent_background = 0
            vim.notify("Transparency disabled for Gruvbox Material", vim.log.levels.INFO)
          else
            vim.g.gruvbox_material_transparent_background = 1
            vim.notify("Transparency enabled for Gruvbox Material", vim.log.levels.INFO)
          end
          vim.cmd("colorscheme gruvbox-material")
        else
          -- For tokyonight
          local tokyonight = require("tokyonight")
          local config = tokyonight.options
          
          config.transparent = not config.transparent
          tokyonight.setup(config)
          
          vim.cmd("colorscheme tokyonight")
          vim.notify("Transparency " .. (config.transparent and "enabled" or "disabled") .. " for TokyoNight", vim.log.levels.INFO)
        end
      end, { desc = "Toggle background transparency" })
      
      -- Add a keymap for transparency toggle
      vim.keymap.set("n", "<leader>uT", "<cmd>ToggleTransparency<cr>", { desc = "Toggle Transparency" })
    end,
  },
}
