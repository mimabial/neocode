-- lua/plugins/colorscheme.lua

return {
  -- Primary theme - Gruvbox Material
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      -- Basic setup
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_sign_column_background = "none"
      vim.g.gruvbox_material_ui_contrast = "high"
      vim.g.gruvbox_material_float_style = "dim"

      -- Export colors for other plugins
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
          popup_bg = "#282828",
          selection_bg = "#45403d",
          selection_fg = "#d4be98",
          copilot = "#6CC644",
          codeium = "#09B6A2",
        }
      end

      -- Theme management code
      local cache_dir = vim.fn.stdpath("cache")
      local settings_file = cache_dir .. "/theme_settings.json"

      -- Theme definitions with proper metadata
      local themes = {
        ["everforest"] = {
          icon = "󱢗 ",
          variants = { "soft", "medium", "hard" },
          apply_variant = function(variant)
            vim.g.everforest_background = variant
            return true
          end,
          set_transparency = function(enable)
            vim.g.everforest_transparent_background = enable and 1 or 0
            return true
          end,
        },
        ["gruvbox"] = {
          icon = " ",
          variants = { "dark", "light" },
          apply_variant = function(variant)
            vim.o.background = variant
            return true
          end,
          set_transparency = function(enable)
            pcall(require("gruvbox").setup, { transparent_mode = enable })
            return true
          end,
        },
        ["gruvbox-material"] = {
          icon = "󰎄 ",
          variants = { "soft", "medium", "hard" },
          apply_variant = function(variant)
            vim.g.gruvbox_material_background = variant
            return true
          end,
          set_transparency = function(enable)
            vim.g.gruvbox_material_transparent_background = enable and 1 or 0
            return true
          end,
        },
        ["kanagawa"] = {
          icon = "󰞍 ",
          variants = { "wave", "dragon", "lotus" },
          apply_variant = function(variant)
            pcall(require("kanagawa").setup, {
              theme = variant,
              background = {
                dark = variant,
                light = "lotus",
              },
            })
            return true
          end,
          set_transparency = function(enable)
            pcall(require("kanagawa").setup, { transparent = enable })
            return true
          end,
        },
        ["nord"] = {
          icon = " ",
          variants = {}, -- Nord doesn't have variants
          apply_variant = function()
            return false
          end,
          set_transparency = function(enable)
            vim.g.nord_disable_background = enable
            return true
          end,
        },
        ["rose-pine"] = {
          icon = "󱎂 ",
          variants = { "main", "moon", "dawn" },
          apply_variant = function(variant)
            pcall(require("rose-pine").setup, { variant = variant })
            return true
          end,
          set_transparency = function(enable)
            pcall(require("rose-pine").setup, { disable_background = enable })
            return true
          end,
        },
        ["solarized"] = {
          icon = " ",
          variants = { "dark", "light" },
          apply_variant = function(variant)
            vim.o.background = variant
            return true
          end,
          set_transparency = function(enable)
            vim.g.solarized_termtrans = enable and 1 or 0
            return true
          end,
        },
        ["solarized-osaka"] = {
          icon = " ",
          variants = {},
          apply_variant = function()
            return false
          end,
          set_transparency = function(enable)
            pcall(require("solarized-osaka").setup, { transparent = enable })
            return true
          end,
        },
      }

      -- Load theme settings
      local function load_settings()
        local default = { theme = "gruvbox-material", variant = "medium", transparency = false }

        -- Check if file exists and is readable
        if vim.fn.filereadable(settings_file) == 0 then
          return default
        end

        -- Read file content
        local content = vim.fn.readfile(settings_file)
        if #content == 0 then
          return default
        end

        -- Parse JSON safely
        local ok, parsed = pcall(vim.fn.json_decode, table.concat(content, ""))
        if not ok or type(parsed) ~= "table" then
          return default
        end

        return {
          theme = parsed.theme or default.theme,
          variant = parsed.variant or default.variant,
          transparency = parsed.transparency or default.transparency,
        }
      end

      -- Save theme settings
      local function save_settings(settings)
        -- Ensure cache directory exists
        vim.fn.mkdir(cache_dir, "p")

        -- Convert to JSON
        local ok, json = pcall(vim.fn.json_encode, settings)
        if not ok then
          vim.notify("Failed to encode theme settings", vim.log.levels.ERROR)
          return false
        end

        -- Write to file
        local success = pcall(vim.fn.writefile, { json }, settings_file)
        return success
      end

      -- Apply theme
      local function apply_theme(name, variant, transparency)
        -- Get theme info
        local theme = themes[name]
        if not theme then
          vim.notify("Theme '" .. name .. "' not found, using gruvbox-material", vim.log.levels.WARN)
          name = "gruvbox-material"
          theme = themes[name]
        end

        -- Apply variant (before colorscheme)
        if variant and theme.variants and vim.tbl_contains(theme.variants, variant) then
          theme.apply_variant(variant)
        end

        -- Apply transparency (before colorscheme)
        if transparency ~= nil then
          theme.set_transparency(transparency)
        end

        -- Set colorscheme
        local success = pcall(vim.cmd, "colorscheme " .. name)
        if not success then
          vim.notify("Failed to load colorscheme " .. name, vim.log.levels.ERROR)
          return false
        end

        -- Save settings
        save_settings({
          theme = name,
          variant = variant,
          transparency = transparency,
        })

        return true
      end

      -- Toggle through themes
      local function cycle_theme()
        local current = vim.g.colors_name or "gruvbox-material"
        local names = vim.tbl_keys(themes)
        table.sort(names)

        -- Find current index
        local idx = 1
        for i, name in ipairs(names) do
          if name == current then
            idx = i
            break
          end
        end

        -- Get next theme
        local next_idx = idx % #names + 1
        local next_theme = names[next_idx]
        local settings = load_settings()
        vim.notify(next_idx, next_theme)
        -- Apply theme
        apply_theme(next_theme, nil, settings.transparency)

        -- Show notification
        local theme = themes[next_theme]
        local icon = theme and theme.icon or ""
        vim.notify(icon .. "Switched to " .. next_theme, vim.log.levels.INFO)
      end

      -- Toggle transparency
      local function toggle_transparency()
        local settings = load_settings()
        settings.transparency = not settings.transparency

        -- Apply theme with new transparency
        apply_theme(settings.theme, settings.variant, settings.transparency)

        vim.notify("Transparency " .. (settings.transparency and "enabled" or "disabled"), vim.log.levels.INFO)
      end

      local function cycle_variant()
        local current = vim.g.colors_name or "gruvbox-material"
        local theme = themes[current]
        vim.notify("Current theme: " .. current, vim.log.levels.INFO)
        if not theme or not theme.variants or #theme.variants == 0 then
          vim.notify("Current theme doesn't have variants", vim.log.levels.WARN)
          return
        end

        -- Load current settings
        local settings = load_settings()
        local current_variant = settings.variant or theme.variants[1]

        -- Find next variant in cycle
        local next_idx = 1
        for i, variant in ipairs(theme.variants) do
          if variant == current_variant then
            next_idx = (i % #theme.variants) + 1
            break
          end
        end

        local next_variant = theme.variants[next_idx]
        apply_theme(current, next_variant, settings.transparency)
        vim.notify("Changed " .. current .. " variant to " .. next_variant, vim.log.levels.INFO)
      end

      -- Create commands
      vim.api.nvim_create_user_command("CycleColorScheme", function()
        cycle_theme()
      end, { desc = "Cycle through color schemes" })

      vim.api.nvim_create_user_command("ColorScheme", function(opts)
        local args = opts.args
        if args == "" then
          -- List available themes
          local available = {}
          for name, theme in pairs(themes) do
            local variant_info = theme.variants
                and #theme.variants > 0
                and (" (" .. table.concat(theme.variants, ", ") .. ")")
                or ""
            table.insert(available, theme.icon .. " " .. name .. variant_info)
          end
          vim.notify("Available themes:\n" .. table.concat(available, "\n"), vim.log.levels.INFO)
          return
        end

        -- Parse arguments
        local theme_name, variant = args:match("([%w-]+)%s*(.*)$")
        if variant == "" then
          variant = nil
        end

        -- Apply theme
        local settings = load_settings()
        apply_theme(theme_name, variant, settings.transparency)

        -- Show notification
        local theme = themes[theme_name]
        local icon = theme and theme.icon or ""
        vim.notify(icon .. "Switched to " .. theme_name .. (variant and (" - " .. variant) or ""), vim.log.levels.INFO)
      end, {
        nargs = "?",
        complete = function()
          return vim.tbl_keys(themes)
        end,
        desc = "Set colorscheme",
      })

      vim.api.nvim_create_user_command("CycleColorVariant", function()
        cycle_variant()
      end, { desc = "Cycle through color scheme variants" })

      vim.api.nvim_create_user_command("ColorVariant", function(opts)
        local current = vim.g.colors_name or "gruvbox-material"
        local theme = themes[current]

        if not theme or not theme.variants or #theme.variants == 0 then
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

        if not vim.tbl_contains(theme.variants, variant) then
          vim.notify("Invalid variant: " .. variant, vim.log.levels.ERROR)
          return
        end

        -- Apply variant
        local settings = load_settings()
        apply_theme(current, variant, settings.transparency)

        vim.notify("Set " .. current .. " variant to " .. variant, vim.log.levels.INFO)
      end, {
        nargs = "?",
        complete = function()
          local current = vim.g.colors_name or "gruvbox-material"
          local theme = themes[current]
          return theme and theme.variants or {}
        end,
        desc = "Set colorscheme variant",
      })

      vim.api.nvim_create_user_command("ToggleBackgroundTransparency", function()
        toggle_transparency()
      end, { desc = "Toggle background transparency" })

      -- Apply initial theme
      local settings = load_settings()
      apply_theme(settings.theme, settings.variant, settings.transparency)
    end,
  },

  -- Additional themes

  {
    "sainnhe/everforest",
    lazy = true,
    priority = 950,
    config = function()
      vim.g.everforest_background = "medium"
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1

      -- Export colors
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
          popup_bg = "#2d353b",
          selection_bg = "#414b50",
          selection_fg = "#d3c6aa",
          copilot = "#6CC644",
          codeium = "#09B6A2",
        }
      end
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
    priority = 950,
    config = function()
      require("gruvbox").setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,
        contrast = "", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })

      -- Export colors
      _G.get_gruvbox_colors = function()
        return {
          bg = "#282828",
          bg1 = "#32302f",
          red = "#cc241d",
          orange = "#d65d0e",
          yellow = "#d79921",
          green = "#98971a",
          aqua = "#689d6a",
          blue = "#458588",
          purple = "#b16286",
          gray = "#928374",
          border = "#665c54",
          fg = "#ebdbb2",
          popup_bg = "#282828",
          selection_bg = "#45403d",
          selection_fg = "#ebdbb2",
          copilot = "#6CC644",
          codeium = "#09B6A2",
        }
      end
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 950,
    config = function()
      require("kanagawa").setup({
        theme = "wave",
        transparent = false,
        commentStyle = { italic = true },
        keywordStyle = { italic = true },
      })

      -- Export colors
      _G.get_kanagawa_colors = function()
        local colors = require("kanagawa.colors").setup()
        local p = colors.palette

        return {
          bg = p.sumiInk1,
          bg1 = p.sumiInk2,
          fg = p.fujiWhite,
          red = p.autumnRed,
          green = p.springGreen,
          yellow = p.carpYellow,
          blue = p.crystalBlue,
          purple = p.oniViolet,
          aqua = p.waveAqua1,
          orange = p.surimiOrange,
          gray = p.fujiGray,
          border = p.sumiInk4,
          popup_bg = p.sumiInk1,
          selection_bg = p.sumiInk4,
          selection_fg = p.fujiWhite,
          copilot = "#6CC644",
          codeium = "#09B6A2",
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
      vim.g.nord_italic = true

      -- Export colors
      _G.get_nord_colors = function()
        local ok, colors = pcall(require, "nord.colors")
        if not ok then
          return nil
        end

        return {
          bg = colors.nord0,
          bg1 = colors.nord1,
          fg = colors.nord4,
          red = colors.nord11,
          green = colors.nord14,
          yellow = colors.nord13,
          blue = colors.nord9,
          purple = colors.nord15,
          aqua = colors.nord8,
          orange = colors.nord12,
          gray = colors.nord3,
          border = colors.nord3,
          popup_bg = colors.nord0,
          selection_bg = colors.nord2,
          selection_fg = colors.nord4,
          copilot = "#6CC644",
          codeium = "#09B6A2",
        }
      end
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    priority = 950,
    config = function()
      require("rose-pine").setup({
        variant = "main",
        disable_background = false,
        disable_italics = false,
      })

      -- Export colors
      _G.get_rose_pine_colors = function()
        local ok, palette = pcall(require, "rose-pine.palette")
        if not ok then
          return nil
        end

        return {
          bg = palette.base,
          bg1 = palette.surface,
          fg = palette.text,
          red = palette.love,
          green = palette.pine,
          yellow = palette.gold,
          blue = palette.foam,
          purple = palette.iris,
          aqua = palette.foam,
          orange = palette.rose,
          gray = palette.muted,
          border = palette.highlight_low,
          popup_bg = palette.base,
          selection_bg = palette.highlight_low,
          selection_fg = palette.text,
          copilot = "#6CC644",
          codeium = "#09B6A2",
        }
      end
    end,
  },
  {
    "maxmx03/solarized.nvim",
    lazy = true,
    priority = 950,
    config = function()
      require("solarized").setup({
        transparent = false,
        palette = "solarized",
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = { bold = false },
          variables = {},
        },
        enables = {
          editor = true,
          syntax = true,
          treesitter = true,
        },
      })

      _G.get_solarized_colors = function()
        local colors = require("solarized.colors")
        local palette = colors.get_colors()

        return {
          bg = palette.base03,
          bg1 = palette.base02,
          red = palette.red,
          orange = palette.orange,
          yellow = palette.yellow,
          green = palette.green,
          aqua = palette.cyan,
          blue = palette.blue,
          purple = palette.violet,
          gray = palette.base00,
          border = palette.base01,
          fg = palette.base0,
          popup_bg = palette.base03,
          selection_bg = palette.base02,
          selection_fg = palette.base0,
          copilot = "#6CC644",
          codeium = "#09B6A2",
        }
      end
    end,
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = true,
    priority = 950,
    config = function()
      require("solarized-osaka").setup({
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
        sidebars = { "qf", "help" },
        day_brightness = 0.3,
        hide_inactive_statusline = false,
        dim_inactive = false,
        lualine_bold = false,
      })

      _G.get_solarized_osaka_colors = function()
        return {
          bg = "#1a1b26",
          bg1 = "#24283b",
          red = "#f7768e",
          orange = "#ff9e64",
          yellow = "#e0af68",
          green = "#9ece6a",
          aqua = "#73daca",
          blue = "#7aa2f7",
          purple = "#bb9af7",
          gray = "#565f89",
          border = "#565f89",
          fg = "#c0caf5",
          popup_bg = "#1a1b26",
          selection_bg = "#24283b",
          selection_fg = "#c0caf5",
          copilot = "#6CC644",
          codeium = "#09B6A2",
        }
      end
    end,
  },
}
