-- lua/plugins/colorscheme.lua
-- Enhanced theme switching with consistent UI integration

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
          gray = "#928374",
          border = "#665c54",
        }
      end
    end,
  },

  -- Additional themes with consistent configuration
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 950,
    opts = {
      style = "storm",
      transparent = false,
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
    },
  },
  { "sainnhe/everforest", lazy = true, priority = 950 },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 950,
    opts = {
      compile = true,
      theme = "wave",
    },
  },
  { "shaunsingh/nord.nvim", lazy = true, priority = 950 },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    priority = 950,
    opts = {
      variant = "main",
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 950,
    opts = {
      flavour = "mocha",
    },
  },

  -- Theme setup and switching functionality
  config = function()
    -- Define all supported themes with their metadata
    local themes = {
      ["gruvbox-material"] = {
        icon = "󰈰 ",
        variants = { "soft", "medium", "hard" },
        current_variant = "medium",
        setup = function(variant)
          if variant then
            vim.g.gruvbox_material_background = variant
          end
        end,
      },
      ["tokyonight"] = {
        icon = "󱣱 ",
        variants = { "storm", "moon", "night", "day" },
        current_variant = "storm",
        setup = function(variant)
          if variant then
            -- Use the new API format
            require("tokyonight").setup({ style = variant })
          end
        end,
      },
      ["everforest"] = {
        icon = "󰪶 ",
        variants = { "soft", "medium", "hard" },
        current_variant = "medium",
        setup = function(variant)
          if variant then
            vim.g.everforest_background = variant
          end
        end,
      },
      ["kanagawa"] = {
        icon = "󰖭 ",
        variants = { "wave", "dragon", "lotus" },
        current_variant = "wave",
        setup = function(variant)
          if variant then
            require("kanagawa").setup({ theme = variant })
          end
        end,
      },
      ["nord"] = {
        icon = "󰔿 ",
      },
      ["rose-pine"] = {
        icon = "󰔎 ",
        variants = { "main", "moon", "dawn" },
        current_variant = "main",
        setup = function(variant)
          if variant then
            require("rose-pine").setup({ variant = variant })
          end
        end,
      },
      ["catppuccin"] = {
        icon = "󰄛 ",
        variants = { "mocha", "macchiato", "frappe", "latte" },
        current_variant = "mocha",
        setup = function(variant)
          if variant then
            require("catppuccin").setup({ flavour = variant })
          end
        end,
      },
    }

    -- Apply theme with error handling and UI refresh
    local function apply_theme(theme_name, variant)
      local theme = themes[theme_name]
      if not theme then
        vim.notify(string.format("Theme '%s' not found", theme_name), vim.log.levels.ERROR)
        return false
      end

      -- Run theme-specific setup if available
      if theme.setup and variant then
        local ok, err = pcall(theme.setup, variant)
        if not ok then
          vim.notify(string.format("Failed to set variant for '%s': %s", theme_name, err), vim.log.levels.WARN)
        else
          -- Update current variant if successful
          if theme.variants and vim.tbl_contains(theme.variants, variant) then
            theme.current_variant = variant
          end
        end
      end

      -- Apply the theme
      local ok, err = pcall(vim.cmd, "colorscheme " .. theme_name)
      if not ok then
        vim.notify(string.format("Failed to apply theme '%s': %s", theme_name, err), vim.log.levels.ERROR)
        -- Fallback to gruvbox-material
        pcall(vim.cmd, "colorscheme gruvbox-material")
        return false
      end

      -- Force refresh of UI elements
      vim.defer_fn(function()
        -- Update UI component colors
        pcall(function()
          -- Refresh UI components that need updating with theme
          if package.loaded["lualine"] then
            require("lualine").refresh()
          end
          if package.loaded["bufferline"] then
            require("bufferline").setup()
          end
          -- Update additional components
          if _G.refresh_ui_colors and type(_G.refresh_ui_colors) == "function" then
            _G.refresh_ui_colors()
          end
        end)
      end, 10)

      local icon = theme.icon or "󱥸 " -- Default icon
      vim.notify(icon .. "Switched to " .. theme_name .. (variant and (" - " .. variant) or ""), vim.log.levels.INFO)

      return true
    end

    -- Cycle to next theme
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

    -- Create commands for theme switching with better error handling
    vim.api.nvim_create_user_command("ColorSchemeToggle", function()
      cycle_theme()
    end, { desc = "Toggle between color schemes" })

    vim.api.nvim_create_user_command("ColorScheme", function(opts)
      local args = opts.args
      if args == "" then
        local available = {}
        for name, theme in pairs(themes) do
          table.insert(
            available,
            theme.icon .. " " .. name .. (theme.variants and (" (" .. table.concat(theme.variants, ", ") .. ")") or "")
          )
        end
        vim.notify("Available themes:\n" .. table.concat(available, "\n"), vim.log.levels.INFO)
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

    -- Set up theme variant switching command
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

    -- Improved transparency toggle with better error handling
    vim.api.nvim_create_user_command("ToggleTransparency", function()
      local current = vim.g.colors_name or "gruvbox-material"
      local success = true

      -- Handle transparency for each theme
      if current == "gruvbox-material" then
        vim.g.gruvbox_material_transparent_background = vim.g.gruvbox_material_transparent_background == 1 and 0 or 1
      elseif current == "tokyonight" then
        pcall(function()
          local config = require("tokyonight").setup()
          config.transparent = not config.transparent
          require("tokyonight").setup(config)
        end)
      elseif current == "everforest" then
        vim.g.everforest_transparent_background = vim.g.everforest_transparent_background == 1 and 0 or 1
      elseif current == "kanagawa" then
        pcall(function()
          local config = require("kanagawa").config
          config.transparent = not config.transparent
          require("kanagawa").setup(config)
        end)
      elseif current == "catppuccin" then
        pcall(function()
          local catppuccin = require("catppuccin")
          local config = catppuccin.options or {}
          config.transparent_background = not (config.transparent_background or false)
          catppuccin.setup(config)
        end)
      elseif current == "rose-pine" then
        pcall(function()
          local config = require("rose-pine").config
          config.transparent = not config.transparent
          require("rose-pine").setup(config)
        end)
      else
        vim.notify("Transparency not supported for " .. current, vim.log.levels.WARN)
        success = false
      end

      -- Reapply colorscheme to take effect
      if success then
        pcall(vim.cmd, "colorscheme " .. current)
        vim.notify("Transparency toggled for " .. current, vim.log.levels.INFO)
      end
    end, { desc = "Toggle background transparency" })

    -- Set initial theme if not already set
    if not vim.g.colors_name then
      vim.cmd("colorscheme gruvbox-material")
    end
  end,
}
