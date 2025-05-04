-- lua/plugins/colorscheme.lua
-- Enhanced theme switching with additional themes and improved UI integration

return {
  -- Primary theme - Gruvbox Material
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_sign_column_background = "none"

      -- Export colors for other plugins to use
      _G.get_gruvbox_colors = function()
        return {
          bg = "#282828",
          bg1 = "#32302f",
          red = "#ea6962",
          orange = "#e78a4e",
          yellow = "#d8a657",
          green = "#89b482",
          aqua = "#7daea3",
          blue = "#7daea3",
          purple = "#d3869b",
          grey = "#928374",
        }
      end
    end,
  },

  -- Additional themes with consistent configuration
  { "folke/tokyonight.nvim", lazy = true, priority = 950 },
  { "sainnhe/everforest", lazy = true, priority = 950 },
  { "rebelot/kanagawa.nvim", lazy = true, priority = 950 },
  { "shaunsingh/nord.nvim", lazy = true, priority = 950 },
  { "rose-pine/neovim", name = "rose-pine", lazy = true, priority = 950 },
  { "catppuccin/nvim", name = "catppuccin", lazy = true, priority = 950 },

  -- Theme setup and switching functionality
  config = function()
    -- Define all supported themes
    local themes = {
      ["gruvbox-material"] = {
        icon = "󰈰 ",
        color_fn = _G.get_gruvbox_colors,
      },
      ["tokyonight"] = {
        icon = "󱣱 ",
        variants = { "storm", "moon", "night", "day" },
        current_variant = "storm",
        color_fn = function()
          local colors = require("tokyonight.colors").setup()
          return {
            bg = colors.bg,
            bg1 = colors.bg_dark,
            red = colors.red,
            orange = colors.orange,
            yellow = colors.yellow,
            green = colors.green,
            aqua = colors.teal,
            blue = colors.blue,
            purple = colors.purple,
            grey = colors.comment,
          }
        end,
      },
      ["everforest"] = {
        icon = "󰪶 ",
        config = function()
          vim.g.everforest_background = "medium"
          vim.g.everforest_enable_italic = 1
        end,
      },
      ["kanagawa"] = {
        icon = "󰖭 ",
        variants = { "wave", "dragon", "lotus" },
        current_variant = "wave",
      },
      ["nord"] = {
        icon = "󰔿 ",
      },
      ["rose-pine"] = {
        icon = "󰔎 ",
        variants = { "main", "moon", "dawn" },
        current_variant = "main",
      },
      ["catppuccin"] = {
        icon = "󰄛 ",
        variants = { "mocha", "macchiato", "frappe", "latte" },
        current_variant = "mocha",
      },
    }

    -- Apply theme with error handling
    local function apply_theme(theme_name, variant)
      local theme = themes[theme_name]
      if not theme then
        vim.notify(string.format("Theme '%s' not found", theme_name), vim.log.levels.ERROR)
        return false
      end

      -- Pre-theme setup if available
      if theme.config and type(theme.config) == "function" then
        pcall(theme.config)
      end

      -- Set variant if applicable
      if variant and theme.variants and vim.tbl_contains(theme.variants, variant) then
        -- Store the current variant
        theme.current_variant = variant

        -- Apply variant-specific settings per theme
        if theme_name == "tokyonight" then
          vim.g.tokyonight_style = variant
        elseif theme_name == "catppuccin" then
          require("catppuccin").setup({ flavour = variant })
        elseif theme_name == "rose-pine" then
          require("rose-pine").setup({ variant = variant })
        elseif theme_name == "kanagawa" then
          vim.g.kanagawa_style = variant
        end
      end

      -- Apply the theme
      local ok = pcall(vim.cmd, "colorscheme " .. theme_name)
      if not ok then
        vim.notify(string.format("Failed to apply theme '%s'", theme_name), vim.log.levels.ERROR)
        -- Fallback to gruvbox-material
        pcall(vim.cmd, "colorscheme gruvbox-material")
        return false
      end

      -- Update UI elements
      pcall(function()
        -- Refresh statusline if lualine is available
        if package.loaded["lualine"] then
          require("lualine").refresh()
        end

        -- Refresh bufferline if available
        if package.loaded["bufferline"] then
          require("bufferline").setup()
        end
      end)

      local icon = theme.icon or "󱥸 " -- Default icon
      vim.notify(icon .. "Switched to " .. theme_name .. (variant and (" - " .. variant) or ""), vim.log.levels.INFO)

      return true
    end

    -- Next theme cycling function
    local function cycle_theme()
      local current = vim.g.colors_name or "gruvbox-material"
      local theme_names = vim.tbl_keys(themes)
      table.sort(theme_names)

      -- Find current index
      local current_idx = 1
      for i, name in ipairs(theme_names) do
        if current == name then
          current_idx = i
          break
        end
      end

      -- Get next theme
      local next_idx = current_idx % #theme_names + 1
      local next_theme = theme_names[next_idx]

      apply_theme(next_theme)
    end

    -- Create commands for theme switching
    vim.api.nvim_create_user_command("ColorSchemeToggle", function()
      cycle_theme()
    end, { desc = "Toggle between color schemes" })

    vim.api.nvim_create_user_command("ColorScheme", function(opts)
      local args = opts.args
      if args == "" then
        vim.notify("Available themes: " .. table.concat(vim.tbl_keys(themes), ", "), vim.log.levels.INFO)
        return
      end

      -- Parse theme name and variant
      local theme_name, variant = args:match("([%w-]+)%s*(.*)$")
      if variant == "" then
        variant = nil
      end

      apply_theme(theme_name, variant)
    end, {
      nargs = "?",
      desc = "Set colorscheme",
      complete = function()
        return vim.tbl_keys(themes)
      end,
    })

    -- Add variant switching command
    vim.api.nvim_create_user_command("ColorSchemeVariant", function(opts)
      local current = vim.g.colors_name or "gruvbox-material"
      local theme = themes[current]

      if not theme or not theme.variants then
        vim.notify("Current theme doesn't have variants", vim.log.levels.WARN)
        return
      end

      local variant = opts.args
      if variant == "" then
        vim.notify(
          "Available variants for " .. current .. ": " .. table.concat(theme.variants, ", "),
          vim.log.levels.INFO
        )
        return
      end

      apply_theme(current, variant)
    end, {
      nargs = "?",
      desc = "Set colorscheme variant",
      complete = function()
        local current = vim.g.colors_name or "gruvbox-material"
        local theme = themes[current]
        return theme and theme.variants or {}
      end,
    })

    -- Theme transparency toggle
    vim.api.nvim_create_user_command("ToggleTransparency", function()
      local current = vim.g.colors_name or "gruvbox-material"

      if current == "gruvbox-material" then
        vim.g.gruvbox_material_transparent_background = vim.g.gruvbox_material_transparent_background == 1 and 0 or 1
      elseif current == "tokyonight" then
        vim.g.tokyonight_transparent = not vim.g.tokyonight_transparent
      elseif current == "everforest" then
        vim.g.everforest_transparent_background = vim.g.everforest_transparent_background == 1 and 0 or 1
      elseif current == "catppuccin" then
        -- Toggle for Catppuccin
        local current_transparent = require("catppuccin").options
          and require("catppuccin").options.transparent_background
        require("catppuccin").setup({ transparent_background = not current_transparent })
      end

      -- Reapply colorscheme to take effect
      pcall(vim.cmd, "colorscheme " .. current)

      vim.notify(
        "Transparency " .. (vim.g.gruvbox_material_transparent_background == 1 and "enabled" or "disabled"),
        vim.log.levels.INFO
      )
    end, { desc = "Toggle background transparency" })

    -- Set initial theme if not already set
    if not vim.g.colors_name then
      vim.cmd("colorscheme gruvbox-material")
    end
  end,
}
