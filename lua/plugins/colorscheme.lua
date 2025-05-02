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

  -- Tokyo Night (Also available)
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 900,
    opts = {
      style = "storm", -- Options: 'storm', 'moon', 'night', 'day'
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
    },
  },

  -- Commands and keymaps
  config = function()
    -- Theme toggle commands
    vim.api.nvim_create_user_command("ColorSchemeToggle", function()
      local themes = { "gruvbox-material", "everforest", "kanagawa", "tokyonight" }
      local current = vim.g.colors_name or "gruvbox-material"

      -- Find current theme index
      local current_idx = 1
      for i, theme in ipairs(themes) do
        if current == theme then
          current_idx = i
          break
        end
      end

      -- Get next theme
      local next_idx = current_idx % #themes + 1
      local next_theme = themes[next_idx]

      -- Apply theme
      vim.cmd("colorscheme " .. next_theme)
      vim.notify("Switched to " .. next_theme .. " theme", vim.log.levels.INFO)
    end, { desc = "Toggle between color schemes" })

    -- Transparency toggle command
    vim.api.nvim_create_user_command("ToggleTransparency", function()
      local current = vim.g.colors_name or "gruvbox-material"

      if current == "gruvbox-material" then
        vim.g.gruvbox_material_transparent_background = vim.g.gruvbox_material_transparent_background == 1 and 0 or 1
        vim.cmd("colorscheme gruvbox-material")
        vim.notify(
          "Transparency " .. (vim.g.gruvbox_material_transparent_background == 1 and "enabled" or "disabled"),
          vim.log.levels.INFO
        )
      elseif current == "everforest" then
        vim.g.everforest_transparent_background = vim.g.everforest_transparent_background == 1 and 0 or 1
        vim.cmd("colorscheme everforest")
        vim.notify(
          "Transparency " .. (vim.g.everforest_transparent_background == 1 and "enabled" or "disabled"),
          vim.log.levels.INFO
        )
      elseif current == "kanagawa" then
        -- For kanagawa, we need to toggle the option and re-setup
        local kanagawa = require("kanagawa")
        local config = kanagawa.config
        config.transparent = not config.transparent
        kanagawa.setup(config)
        vim.cmd("colorscheme kanagawa")
        vim.notify("Transparency " .. (config.transparent and "enabled" or "disabled"), vim.log.levels.INFO)
      elseif current == "tokyonight" then
        local tn = require("tokyonight")
        tn.setup(vim.tbl_extend("force", tn.options, { transparent = not tn.options.transparent }))
        vim.cmd("colorscheme tokyonight")
        vim.notify(
          "Transparency " .. (require("tokyonight").options.transparent and "enabled" or "disabled"),
          vim.log.levels.INFO
        )
      end
    end, { desc = "Toggle background transparency" })

    -- Set default colorscheme if not already set
    if not vim.g.colors_name then
      vim.cmd("colorscheme gruvbox-material")
    end

    -- Keymaps
    vim.keymap.set("n", "<leader>ut", "<cmd>ColorSchemeToggle<cr>", { desc = "Toggle Colorscheme" })
    vim.keymap.set("n", "<leader>uT", "<cmd>ToggleTransparency<cr>", { desc = "Toggle Transparency" })
  end,
}
