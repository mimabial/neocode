-- lua/plugins/colorscheme.lua
-- Enhanced theme switching with persistent storage and consistent UI integration

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
      vim.g.gruvbox_material_ui_contrast = "high"
      vim.g.gruvbox_material_float_style = "dim"

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
          fg = "#d4be98",
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
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },
      sidebars = { "qf", "help", "terminal", "packer", "NvimTree", "Trouble", "oil" },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = true,
      lualine_bold = true,
      on_colors = function(colors)
        colors.border = "#565f89"
      end,
      on_highlights = function(highlights, colors)
        highlights.FloatBorder = { fg = colors.border }
      end,
    },
  },
  {
    "sainnhe/everforest",
    lazy = true,
    priority = 950,
    config = function()
      vim.g.everforest_background = "medium"
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_ui_contrast = "high"
      vim.g.everforest_diagnostic_text_highlight = 1
      vim.g.everforest_diagnostic_line_highlight = 1
      vim.g.everforest_diagnostic_virtual_text = "colored"
      vim.g.everforest_sign_column_background = "none"
      vim.g.everforest_float_style = "dim"

      -- Export colors for other plugins to use
      _G.get_everforest_colors = function()
        return {
          bg = "#2d353b",
          bg1 = "#343f44",
          red = "#e67e80",
          orange = "#e69875",
          yellow = "#dbbc7f",
          green = "#a7c080",
          aqua = "#83c092",
          blue = "#7fbbb3",
          purple = "#d699b6",
          gray = "#859289",
          border = "#4f5b58",
          fg = "#d3c6aa",
        }
      end
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 950,
    opts = {
      compile = true,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,
      dimInactive = true,
      terminalColors = true,
      theme = "wave",
      background = {
        dark = "wave",
        light = "lotus",
      },
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
              float = {
                bg = "none",
                bg_border = "none",
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)

      -- Export colors for other plugins to use
      _G.get_kanagawa_colors = function()
        local colors = require("kanagawa.colors").setup()
        local palette = colors.palette

        return {
          bg = palette.sumiInk1,
          bg1 = palette.sumiInk2,
          red = palette.autumnRed,
          orange = palette.surimiOrange,
          yellow = palette.carpYellow,
          green = palette.springGreen,
          aqua = palette.waveAqua1,
          blue = palette.crystalBlue,
          purple = palette.oniViolet,
          gray = palette.fujiGray,
          border = palette.sumiInk4,
          fg = palette.fujiWhite,
        }
      end
    end,
  },
  {
    "shaunsingh/nord.nvim",
    lazy = true,
    priority = 950,
    config = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = true
      vim.g.nord_disable_background = false
      vim.g.nord_cursorline_transparent = false
      vim.g.nord_enable_sidebar_background = true
      vim.g.nord_italic = true
      vim.g.nord_uniform_diff_background = true
      vim.g.nord_bold = true
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    priority = 950,
    opts = {
      variant = "main",
      dark_variant = "main",
      bold_vert_split = false,
      dim_nc_background = false,
      disable_background = false,
      disable_float_background = false,
      disable_italics = false,
      highlight_groups = {
        FloatBorder = { fg = "highlight_high" },
        TelescopeBorder = { fg = "highlight_high" },
      },
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 950,
    opts = {
      flavour = "mocha",
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      color_overrides = {},
      custom_highlights = {},
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        notify = true,
        mini = true,
        which_key = true,
        mason = true,
        treesitter = true,
        dap = {
          enabled = true,
          enable_ui = true,
        },
        indent_blankline = {
          enabled = true,
          colored_indent_levels = false,
        },
      },
    },
  },

  -- Theme setup and switching functionality
  config = function()
    -- Persistence file for theme settings
    local theme_cache_file = vim.fn.stdpath("cache") .. "/theme_settings.json"
    local utils = require("config.utils")

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

    -- Load persisted theme settings
    local function load_theme_settings()
      local settings = { theme = "gruvbox-material", variant = nil, transparency = false }

      -- Try to read from cache file
      local file = io.open(theme_cache_file, "r")
      if file then
        local content = file:read("*all")
        file:close()

        -- Parse JSON safely
        local ok, parsed = pcall(vim.fn.json_decode, content)
        if ok and type(parsed) == "table" then
          settings = parsed
        end
      end

      return settings
    end

    -- Save theme settings to cache file
    local function save_theme_settings(settings)
      local file = io.open(theme_cache_file, "w")
      if file then
        local ok, json = pcall(vim.fn.json_encode, settings)
        if ok then
          file:write(json)
          file:close()
          return true
        else
          file:close()
        end
      end
      return false
    end

    -- Apply theme with error handling and UI refresh
    local function apply_theme(theme_name, variant, transparency)
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

      -- Set transparency if specified
      if transparency ~= nil then
        -- Handle transparency for each theme
        if theme_name == "gruvbox-material" then
          vim.g.gruvbox_material_transparent_background = transparency and 1 or 0
        elseif theme_name == "tokyonight" then
          pcall(function()
            require("tokyonight").setup({ transparent = transparency })
          end)
        elseif theme_name == "everforest" then
          vim.g.everforest_transparent_background = transparency and 1 or 0
        elseif theme_name == "kanagawa" then
          pcall(function()
            require("kanagawa").setup({ transparent = transparency })
          end)
        elseif theme_name == "catppuccin" then
          pcall(function()
            require("catppuccin").setup({ transparent_background = transparency })
          end)
        elseif theme_name == "rose-pine" then
          pcall(function()
            require("rose-pine").setup({ disable_background = transparency })
          end)
        elseif theme_name == "nord" then
          vim.g.nord_disable_background = transparency
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

      -- Save settings to persist between sessions
      save_theme_settings({
        theme = theme_name,
        variant = variant or theme.current_variant,
        transparency = transparency or false,
      })

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

      -- Preserve current transparency setting
      local settings = load_theme_settings()
      apply_theme(next_theme, nil, settings.transparency)
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

      -- Load current settings
      local settings = load_theme_settings()
      apply_theme(theme_name, variant, settings.transparency)
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

      -- Load current settings and preserve transparency
      local settings = load_theme_settings()
      apply_theme(current, variant, settings.transparency)
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
      -- Load current settings
      local settings = load_theme_settings()
      -- Toggle transparency
      settings.transparency = not settings.transparency

      -- Apply current theme with new transparency setting
      apply_theme(settings.theme, settings.variant, settings.transparency)

      vim.notify(
        "Transparency " .. (settings.transparency and "enabled" or "disabled") .. " for " .. settings.theme,
        vim.log.levels.INFO
      )
    end, { desc = "Toggle background transparency" })

    -- Initial theme setup based on persisted settings
    vim.defer_fn(function()
      local settings = load_theme_settings()
      if settings.theme then
        apply_theme(settings.theme, settings.variant, settings.transparency)
      else
        vim.cmd("colorscheme gruvbox-material")
      end
    end, 10)
  end,
}
