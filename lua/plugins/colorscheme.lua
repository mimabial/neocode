return {
  -- Primary theme - Kanagawa
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        theme = "wave",
        background = { dark = "wave", light = "lotus" },
        transparent = false,
        dimInactive = false,
        terminalColors = true,
        colors = { palette = {}, theme = { wave = {}, lotus = {}, dragon = {}, all = {} } },
        overrides = function(colors) return {} end,
      })

      -- Export colors for other plugins
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

      -- Theme management system
      local cache_dir = vim.fn.stdpath("cache")
      local settings_file = cache_dir .. "/theme_settings.json"

      local function load_settings()
        local ok, content = pcall(vim.fn.readfile, settings_file)
        if ok and content[1] then
          local success, data = pcall(vim.json.decode, content[1])
          if success then return data end
        end
        return { theme = "kanagawa", variant = nil, transparency = false }
      end

      local function save_settings(settings)
        vim.fn.mkdir(cache_dir, "p")
        local content = vim.json.encode(settings)
        vim.fn.writefile({ content }, settings_file)
      end

      -- Theme definitions
      local themes = {
        ["catppuccin"] = {
          icon = "",
          variants = { "latte", "frappe", "macchiato", "mocha" },
          apply_variant = function(variant)
            pcall(require("catppuccin").setup, { flavour = variant })
            return true
          end,
          set_transparency = function(enable)
            pcall(require("catppuccin").setup, { transparent_background = enable })
            return true
          end,
        },
        ["everforest"] = {
          icon = "",
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
          icon = "",
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
          icon = "",
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
          icon = "",
          variants = { "wave", "dragon", "lotus" },
          apply_variant = function(variant)
            pcall(require("kanagawa").setup, {
              theme = variant,
              background = { dark = variant, light = "lotus" },
            })
            return true
          end,
          set_transparency = function(enable)
            pcall(require("kanagawa").setup, { transparent = enable })
            return true
          end,
        },
        ["nord"] = {
          icon = "",
          variants = {},
          apply_variant = function() return false end,
          set_transparency = function(enable)
            vim.g.nord_disable_background = enable
            return true
          end,
        },
        ["rose-pine"] = {
          icon = "",
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
          icon = "",
          variants = { "dark", "light" },
          apply_variant = function(variant)
            vim.o.background = variant
            return true
          end,
          set_transparency = function() return false end,
        },
        ["solarized-osaka"] = {
          icon = "",
          variants = {},
          apply_variant = function() return false end,
          set_transparency = function(enable)
            pcall(require("solarized-osaka").setup, { transparent = enable })
            return true
          end,
        },
      }

      local function apply_theme(name, variant, transparency)
        local theme = themes[name]
        if not theme then
          vim.notify("Theme '" .. name .. "' not found, using kanagawa", vim.log.levels.WARN)
          name = "kanagawa"
          theme = themes[name]
        end

        -- Apply variant and transparency before colorscheme
        if variant and theme.variants and vim.tbl_contains(theme.variants, variant) then
          theme.apply_variant(variant)
        end
        if transparency ~= nil then
          theme.set_transparency(transparency)
        end

        -- Set colorscheme
        local success = pcall(vim.cmd, "colorscheme " .. name)
        if not success then
          vim.notify("Failed to load colorscheme " .. name, vim.log.levels.ERROR)
          return false
        end

        save_settings({ theme = name, variant = variant, transparency = transparency })
        return true
      end

      local function cycle_theme()
        local current = vim.g.colors_name or "kanagawa"
        local names = vim.tbl_keys(themes)
        table.sort(names)

        local idx = 1
        for i, name in ipairs(names) do
          if name == current then
            idx = i; break
          end
        end

        local next_theme = names[idx % #names + 1]
        local settings = load_settings()
        apply_theme(next_theme, nil, settings.transparency)

        local icon = themes[next_theme].icon or ""
        vim.notify(icon .. "Switched to " .. next_theme, vim.log.levels.INFO)
      end

      local function cycle_variant()
        local current = vim.g.colors_name or "kanagawa"

        -- Handle catppuccin compiled names
        local theme_name = current
        if current:match("^catppuccin%-") then
          theme_name = "catppuccin"
        end

        local theme = themes[theme_name]

        if not theme or not theme.variants or #theme.variants == 0 then
          vim.notify("Current theme doesn't have variants", vim.log.levels.WARN)
          return
        end

        local settings = load_settings()
        local current_variant = settings.variant or theme.variants[1]

        local next_idx = 1
        for i, variant in ipairs(theme.variants) do
          if variant == current_variant then
            next_idx = (i % #theme.variants) + 1
            break
          end
        end

        local next_variant = theme.variants[next_idx]
        apply_theme(theme_name, next_variant, settings.transparency)

        local icon = theme.icon or ""
        vim.notify(icon .. "Changed " .. current .. " variant to " .. next_variant, vim.log.levels.INFO)
      end

      local function toggle_transparency()
        local settings = load_settings()
        settings.transparency = not settings.transparency
        apply_theme(settings.theme, settings.variant, settings.transparency)
        vim.notify("Transparency " .. (settings.transparency and "enabled" or "disabled"), vim.log.levels.INFO)
      end

      -- Create user commands
      vim.api.nvim_create_user_command("CycleColorScheme", cycle_theme,
        { desc = "Cycle through color schemes" })

      vim.api.nvim_create_user_command("CycleColorVariant", cycle_variant,
        { desc = "Cycle through color scheme variants" })

      vim.api.nvim_create_user_command("ToggleBackgroundTransparency", toggle_transparency,
        { desc = "Toggle background transparency" })

      vim.api.nvim_create_user_command("ColorScheme", function(opts)
        local args = opts.args
        if args == "" then
          local available = {}
          for name, theme in pairs(themes) do
            local variant_info = theme.variants and #theme.variants > 0
                and (" (" .. table.concat(theme.variants, ", ") .. ")") or ""
            table.insert(available, theme.icon .. " " .. name .. variant_info)
          end
          vim.notify("Available themes:\n" .. table.concat(available, "\n"), vim.log.levels.INFO)
          return
        end

        local theme_name, variant = args:match("([%w-]+)%s*(.*)$")
        if variant == "" then variant = nil end

        local settings = load_settings()
        apply_theme(theme_name, variant, settings.transparency)

        local theme = themes[theme_name]
        local icon = theme and theme.icon or ""
        vim.notify(icon .. "Switched to " .. theme_name .. (variant and (" - " .. variant) or ""), vim.log.levels.INFO)
      end, {
        nargs = "?",
        complete = function() return vim.tbl_keys(themes) end,
        desc = "Set colorscheme",
      })

      vim.api.nvim_create_user_command("ColorVariant", function(opts)
        local current = vim.g.colors_name or "kanagawa"
        local theme = themes[current]

        if not theme or not theme.variants or #theme.variants == 0 then
          vim.notify("Current theme doesn't have variants", vim.log.levels.WARN)
          return
        end

        local variant = opts.args
        if variant == "" then
          vim.notify("Available variants for " .. current .. ": " .. table.concat(theme.variants, ", "),
            vim.log.levels.INFO)
          return
        end

        if not vim.tbl_contains(theme.variants, variant) then
          vim.notify("Invalid variant: " .. variant, vim.log.levels.ERROR)
          return
        end

        local settings = load_settings()
        apply_theme(current, variant, settings.transparency)
        vim.notify("Set " .. current .. " variant to " .. variant, vim.log.levels.INFO)
      end, {
        nargs = "?",
        complete = function()
          local current = vim.g.colors_name or "kanagawa"
          local theme = themes[current]
          return theme and theme.variants or {}
        end,
        desc = "Set colorscheme variant",
      })

      -- Apply initial theme
      local settings = load_settings()
      apply_theme(settings.theme, settings.variant, settings.transparency)
    end,
  },

  -- Additional themes (lazy loaded)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 950,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        term_colors = true,
        compile_enable = true,
        compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
        styles = { comments = { "italic" }, conditionals = { "italic" } },
        integrations = { cmp = true, gitsigns = true, nvimtree = true, telescope = true, treesitter = true, which_key = true },
      })
      _G.get_catppuccin_colors = function()
        local colors = require("catppuccin.palettes").get_palette()
        return {
          bg = colors.base,
          bg1 = colors.mantle,
          fg = colors.text,
          red = colors.red,
          green = colors.green,
          yellow = colors.yellow,
          blue = colors.blue,
          purple = colors.mauve,
          aqua = colors.teal,
          orange = colors.peach,
          gray = colors.surface1,
          border = colors.surface0,
          popup_bg = colors.base,
          selection_bg = colors.surface0,
          selection_fg = colors.text,
          copilot = "#6CC644",
          codeium = "#09B6A2",
        }
      end
    end,
  },
  {
    "sainnhe/everforest",
    lazy = true,
    priority = 950,
    config = function()
      vim.g.everforest_background = "medium"
      vim.g.everforest_better_performance = 1
      _G.get_everforest_colors = function()
        return {
          bg = "#2d353b",
          bg1 = "#343f44",
          fg = "#d3c6aa",
          red = "#e67e80",
          green = "#a7c080",
          yellow = "#dbbc7f",
          blue = "#7fbbb3",
          purple = "#d699b6",
          aqua = "#83c092",
          orange = "#e69875",
          gray = "#859289",
          border = "#4f5b58",
          popup_bg = "#2d353b",
          selection_bg = "#503946",
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
        italic = { strings = true, emphasis = true, comments = true, operators = false, folds = true },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,
        contrast =
        "",
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false
      })
      _G.get_gruvbox_colors = function()
        return {
          bg = "#282828",
          bg1 = "#3c3836",
          fg = "#ebdbb2",
          red = "#ea6962",
          green = "#a9b665",
          yellow = "#d8a657",
          blue = "#7daea3",
          purple = "#d3869b",
          aqua = "#89b482",
          orange = "#e78a4e",
          gray = "#928374",
          border = "#665c54",
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
    "sainnhe/gruvbox-material",
    lazy = true,
    priority = 950,
    config = function()
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_foreground = "material"
      vim.g.gruvbox_material_better_performance = 1
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
      _G.get_nord_colors = function()
        local ok, colors = pcall(require, "nord.colors")
        if not ok then return nil end
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
        variant = "main", disable_background = false, disable_italics = false,
      })
      _G.get_rose_pine_colors = function()
        local ok, palette = pcall(require, "rose-pine.palette")
        if not ok then return nil end
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
      require("solarized").setup({ variant = "autumn", transparent = { enabled = false } })
    end,
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = true,
    priority = 950,
    config = function()
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
