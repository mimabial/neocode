-- lua/plugins/colorscheme.lua
-- Enhanced colorscheme configuration with Gruvbox Material, Everforest and Kanagawa

return {
  -- Gruvbox Material (Primary)
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      -- Base configuration
      vim.g.gruvbox_material_background = "medium" -- Options: 'hard', 'medium', 'soft'
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_foreground = "material" -- Options: 'material', 'mix', 'original'
      vim.g.gruvbox_material_ui_contrast = "high"
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_transparent_background = 0
      vim.g.gruvbox_material_sign_column_background = "none"
      vim.g.gruvbox_material_diagnostic_text_highlight = 1
      vim.g.gruvbox_material_diagnostic_line_highlight = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
      vim.g.gruvbox_material_current_word = "bold"
      vim.g.gruvbox_material_disable_italic_comment = 0

      -- Enhanced palette customizations for better contrast
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

      -- Create a function to export the palette for other plugins to use
      _G.get_gruvbox_colors = function()
        return {
          bg = "#282828",
          bg1 = "#32302f",
          bg2 = "#32302f",
          bg3 = "#45403d",
          bg4 = "#45403d",
          bg5 = "#5a524c",
          red = "#ea6962",
          orange = "#e78a4e",
          yellow = "#d8a657",
          green = "#89b482",
          aqua = "#7daea3",
          blue = "#7daea3",
          purple = "#d3869b",
          grey = "#928374",
          grey_dim = "#7c6f64",
        }
      end
    end,
  },

  -- Everforest theme
  {
    "sainnhe/everforest",
    lazy = true,
    priority = 900,
    config = function()
      vim.g.everforest_background = "medium"
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_diagnostic_text_highlight = 1
      vim.g.everforest_diagnostic_line_highlight = 1
      vim.g.everforest_diagnostic_virtual_text = "colored"
      vim.g.everforest_current_word = "bold"

      -- Add custom export function for colors
      _G.get_everforest_colors = function()
        return {
          bg = "#2b3339",
          bg1 = "#323c41",
          bg2 = "#323c41",
          bg3 = "#3a454a",
          bg4 = "#3a454a",
          bg5 = "#46525a",
          red = "#e67e80",
          orange = "#e69875",
          yellow = "#dbbc7f",
          green = "#a7c080",
          aqua = "#83c092",
          blue = "#7fbbb3",
          purple = "#d699b6",
          grey = "#859289",
          grey_dim = "#738686",
        }
      end
    end,
  },

  -- Kanagawa theme
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 900,
    opts = {
      compile = true,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,
      dimInactive = false,
      terminalColors = true,
      theme = "wave", -- wave, dragon, lotus
      background = {
        dark = "wave",
        light = "lotus",
      },
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
      overrides = function(colors)
        -- Export palette via global function
        _G.get_kanagawa_colors = function()
          return {
            bg = colors.sumiInk1,
            bg1 = colors.sumiInk2,
            bg2 = colors.sumiInk2,
            bg3 = colors.sumiInk3,
            bg4 = colors.sumiInk4,
            bg5 = colors.sumiInk5,
            red = colors.peachRed,
            orange = colors.surimiOrange,
            yellow = colors.carpYellow,
            green = colors.springGreen,
            aqua = colors.waveAqua1,
            blue = colors.crystalBlue,
            purple = colors.oniViolet,
            grey = colors.fujiGray,
            grey_dim = colors.oldWhite,
          }
        end

        return {
          -- Custom overrides for GOTH stack
          ["@attribute.htmx"] = { fg = colors.springGreen, italic = true, bold = true },
          ["@tag.attribute.htmx"] = { fg = colors.springGreen, italic = true, bold = true },
          ["@type.go"] = { fg = colors.carpYellow },
          ["@function.go"] = { fg = colors.crystalBlue },

          -- Custom overrides for Next.js stack
          ["@tag.tsx"] = { fg = colors.peachRed },
          ["@tag.delimiter.tsx"] = { fg = colors.surimiOrange },
          ["@constructor.tsx"] = { fg = colors.oniViolet },

          -- AI completions
          CmpItemKindCopilot = { fg = "#6CC644", bold = true },
          CmpItemKindCodeium = { fg = "#09B6A2", bold = true },
        }
      end,
    },
  },

  -- Commands and keymaps
  config = function()
    -- Theme toggle commands
    vim.api.nvim_create_user_command("ColorSchemeToggle", function()
      local themes = { "gruvbox-material", "everforest", "kanagawa" }
      -- Enhanced current theme detection with fallback
      local current = vim.g.colors_name
      if not current then
        current = "gruvbox-material"
        vim.notify("Current theme not detected, defaulting to gruvbox-material", vim.log.levels.WARN)
      end

      -- Find current theme index
      local current_idx = 1
      local ok, err = pcall(function()
        for i, theme in ipairs(themes) do
          if current == theme then
            current_idx = i
            return true
          end
        end
        return false
      end)

      if not ok then
        vim.notify("Error finding current theme: " .. tostring(err), vim.log.levels.WARN)
        current_idx = 1 -- Default to first theme
      end

      -- Check if the chosen theme module is available
      local next_theme_avail = {}
      for _, theme in ipairs(themes) do
        next_theme_avail[theme] = (theme == "gruvbox-material") or pcall(require, theme:gsub("-", "."))
      end

      -- Get next theme with fallback to a theme we know exists
      local next_idx = current_idx % #themes + 1
      local next_theme = themes[next_idx]

      -- Add icons for themes
      local theme_icons = {
        ["gruvbox-material"] = "󰈰 ",
        ["everforest"] = "󰪶 ",
        ["kanagawa"] = "󰖭 ",
      }

      -- Ensure we have a valid icon
      local theme_icon = theme_icons[next_theme] or "󰏘 "

      -- Apply theme with safety checks
      local applied_ok = pcall(vim.cmd, "colorscheme " .. next_theme)

      if not applied_ok then
        vim.notify("Failed to apply " .. next_theme .. " theme, falling back to gruvbox-material", vim.log.levels.WARN)

        -- Try to fall back to gruvbox-material
        if next_theme ~= "gruvbox-material" then
          pcall(vim.cmd, "colorscheme gruvbox-material")
          vim.notify("Fell back to gruvbox-material theme", vim.log.levels.INFO)
          theme_icon = theme_icons["gruvbox-material"]
          next_theme = "gruvbox-material"
        end
      end

      vim.notify(theme_icon .. "Switched to " .. next_theme .. " theme", vim.log.levels.INFO)
    end, { desc = "Toggle between color schemes (fail-safe)" })

    -- Add transparency toggle with similar safety features
    vim.api.nvim_create_user_command("ToggleTransparency", function()
      -- Determine current theme and toggle its transparency
      local current = vim.g.colors_name or "gruvbox-material"

      if current == "gruvbox-material" then
        vim.g.gruvbox_material_transparent_background = vim.g.gruvbox_material_transparent_background == 1 and 0 or 1
        pcall(vim.cmd, "colorscheme gruvbox-material") -- Reapply with pcall for safety
      elseif current == "everforest" then
        vim.g.everforest_transparent_background = vim.g.everforest_transparent_background == 1 and 0 or 1
        pcall(vim.cmd, "colorscheme everforest")
      elseif current == "kanagawa" then
        local ok, kanagawa = pcall(require, "kanagawa")
        if ok then
          local config = kanagawa.config
          config.transparent = not config.transparent
          kanagawa.setup(config)
          pcall(vim.cmd, "colorscheme kanagawa")
        end
      end

      -- Notify of transparency change
      local is_transparent = false
      if current == "gruvbox-material" then
        is_transparent = vim.g.gruvbox_material_transparent_background == 1
      elseif current == "everforest" then
        is_transparent = vim.g.everforest_transparent_background == 1
      elseif current == "kanagawa" then
        local ok, kanagawa = pcall(require, "kanagawa")
        if ok then
          is_transparent = kanagawa.config and kanagawa.config.transparent
        end
      end

      vim.notify(
        "󱙱 Transparency " .. (is_transparent and "enabled" or "disabled"),
        vim.log.levels.INFO,
        { title = "Theme Changed" }
      )
    end, { desc = "Toggle background transparency" })

    -- Set default colorscheme if not already set
    if not vim.g.colors_name then
      vim.cmd("colorscheme gruvbox-material")
    end

    -- Apply stack-specific highlighting enhancements
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        -- Get the current colorscheme and stack
        local colorscheme = vim.g.colors_name or "gruvbox-material"
        local stack = vim.g.current_stack or ""

        -- Get color palette based on current theme
        local colors
        if colorscheme == "gruvbox-material" and _G.get_gruvbox_colors then
          colors = _G.get_gruvbox_colors()
        elseif colorscheme == "everforest" and _G.get_everforest_colors then
          colors = _G.get_everforest_colors()
        elseif colorscheme == "kanagawa" and _G.get_kanagawa_colors then
          colors = _G.get_kanagawa_colors()
        else
          -- Default fallback palette
          colors = {
            red = "#f7768e",
            green = "#9ece6a",
            blue = "#7aa2f7",
            yellow = "#e0af68",
            purple = "#bb9af7",
            aqua = "#2ac3de",
            orange = "#ff9e64",
          }
        end

        -- Apply stack-specific highlighting
        if stack == "goth" or stack == "goth+nextjs" then
          -- GOTH stack highlighting
          vim.api.nvim_set_hl(0, "@type.go", { fg = colors.yellow, bold = true })
          vim.api.nvim_set_hl(0, "@function.go", { fg = colors.blue })
          vim.api.nvim_set_hl(0, "@attribute.htmx", { fg = colors.green, italic = true, bold = true })
          vim.api.nvim_set_hl(0, "@tag.attribute.htmx", { fg = colors.green, italic = true, bold = true })
        end

        if stack == "nextjs" or stack == "goth+nextjs" then
          -- Next.js stack highlighting
          vim.api.nvim_set_hl(0, "@tag.tsx", { fg = colors.red })
          vim.api.nvim_set_hl(0, "@tag.delimiter.tsx", { fg = colors.orange })
          vim.api.nvim_set_hl(0, "@constructor.tsx", { fg = colors.purple })
          vim.api.nvim_set_hl(0, "@type.typescript", { fg = colors.yellow, bold = true })
        end

        -- AI integration highlighting
        vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644", bold = true })
        vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#09B6A2", bold = true })
        vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = colors.grey or "#928374", italic = true })
        vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = colors.grey or "#928374", italic = true })
      end,
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>ut", "<cmd>ColorSchemeToggle<cr>", { desc = "Toggle Colorscheme" })
    vim.keymap.set("n", "<leader>uT", "<cmd>ToggleTransparency<cr>", { desc = "Toggle Transparency" })
  end,
}
