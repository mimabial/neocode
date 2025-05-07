-- lua/plugins/colorscheme.lua
-- Consolidated theme management with unified color system

return {
  -- Primary theme - Gruvbox Material
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      -- Core theme manager
      local theme = {
        -- Current settings
        settings_file = vim.fn.stdpath("cache") .. "/theme_settings.json",
        current = {
          name = "gruvbox-material",
          variant = "medium",
          transparency = false,
        },

        -- Theme registry with implementation details
        registry = {
          ["gruvbox-material"] = {
            icon = "󰎄 ",
            variants = { "soft", "medium", "hard" },
            setup = function(variant, transparency)
              vim.g.gruvbox_material_background = variant or "medium"
              vim.g.gruvbox_material_transparent_background = transparency and 1 or 0
              vim.g.gruvbox_material_better_performance = 1
              vim.g.gruvbox_material_enable_italic = 1
              vim.g.gruvbox_material_enable_bold = 1
              vim.g.gruvbox_material_sign_column_background = "none"
              vim.g.gruvbox_material_ui_contrast = "high"
              vim.g.gruvbox_material_float_style = "dim"
            end,
            colors = function()
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
                selection_bg = "#45403d",
                selection_fg = "#d4be98",
              }
            end,
          },

          ["tokyonight"] = {
            icon = " ",
            variants = { "storm", "moon", "night", "day" },
            setup = function(variant, transparency)
              pcall(require, "tokyonight")
              pcall(require("tokyonight").setup, {
                style = variant or "storm",
                transparent = transparency or false,
                styles = { comments = { italic = true }, keywords = { italic = true } },
              })
            end,
            colors = function()
              if not package.loaded["tokyonight.colors"] then
                return {}
              end
              local colors = require("tokyonight.colors").setup()
              return {
                bg = colors.bg,
                bg1 = colors.bg_dark,
                fg = colors.fg,
                red = colors.red,
                green = colors.green,
                yellow = colors.yellow,
                blue = colors.blue,
                purple = colors.purple,
                aqua = colors.teal,
                orange = colors.orange,
                gray = colors.comment,
                border = colors.border,
                selection_bg = colors.bg_highlight,
                selection_fg = colors.fg,
              }
            end,
          },

          ["everforest"] = {
            icon = "󱢗 ",
            variants = { "soft", "medium", "hard" },
            setup = function(variant, transparency)
              vim.g.everforest_background = variant or "medium"
              vim.g.everforest_transparent_background = transparency and 1 or 0
              vim.g.everforest_better_performance = 1
              vim.g.everforest_enable_italic = 1
            end,
            colors = function()
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
                selection_bg = "#3a454a",
                selection_fg = "#d3c6aa",
              }
            end,
          },

          ["kanagawa"] = {
            icon = "󰞍 ",
            variants = { "wave", "dragon", "lotus" },
            setup = function(variant, transparency)
              pcall(require, "kanagawa")
              pcall(require("kanagawa").setup, {
                theme = variant or "wave",
                transparent = transparency or false,
                background = { dark = variant or "wave" },
                commentStyle = { italic = true },
                keywordStyle = { italic = true },
              })
            end,
            colors = function()
              if not package.loaded["kanagawa.colors"] then
                return {}
              end
              local colors = require("kanagawa.colors").setup()
              local p = colors.palette
              return {
                bg = p.sumiInk1,
                bg1 = p.sumiInk2,
                red = p.autumnRed,
                orange = p.surimiOrange,
                yellow = p.carpYellow,
                green = p.springGreen,
                aqua = p.waveAqua1,
                blue = p.crystalBlue,
                purple = p.oniViolet,
                gray = p.fujiGray,
                border = p.sumiInk4,
                fg = p.fujiWhite,
                selection_bg = p.waveBlue1,
                selection_fg = p.fujiWhite,
              }
            end,
          },

          ["nord"] = {
            icon = " ",
            variants = {},
            setup = function(_, transparency)
              vim.g.nord_contrast = true
              vim.g.nord_borders = true
              vim.g.nord_disable_background = transparency or false
              vim.g.nord_italic = true
            end,
            colors = function()
              return {
                bg = "#2e3440",
                bg1 = "#3b4252",
                red = "#bf616a",
                orange = "#d08770",
                yellow = "#ebcb8b",
                green = "#a3be8c",
                aqua = "#88c0d0",
                blue = "#81a1c1",
                purple = "#b48ead",
                gray = "#4c566a",
                border = "#434c5e",
                fg = "#eceff4",
                selection_bg = "#3b4252",
                selection_fg = "#eceff4",
              }
            end,
          },

          ["rose-pine"] = {
            icon = "󱎂 ",
            variants = { "main", "moon", "dawn" },
            setup = function(variant, transparency)
              pcall(require, "rose-pine")
              pcall(require("rose-pine").setup, {
                variant = variant or "main",
                disable_background = transparency or false,
                disable_italics = false,
              })
            end,
            colors = function()
              if not package.loaded["rose-pine.palette"] then
                return {}
              end
              local p = require("rose-pine.palette")
              return {
                bg = p.base,
                bg1 = p.surface,
                fg = p.text,
                red = p.love,
                green = p.pine,
                yellow = p.gold,
                blue = p.foam,
                purple = p.iris,
                aqua = p.foam,
                orange = p.rose,
                gray = p.muted,
                border = p.highlight_low,
                selection_bg = p.highlight_med,
                selection_fg = p.text,
              }
            end,
          },

          ["catppuccin"] = {
            icon = "󰄛 ",
            variants = { "mocha", "macchiato", "frappe", "latte" },
            setup = function(variant, transparency)
              pcall(require, "catppuccin")
              local ok, cat = pcall(require, "catppuccin")
              if ok then
                cat.setup({
                  flavour = variant or "mocha",
                  transparent_background = transparency or false,
                  styles = { comments = { "italic" }, keywords = { "italic" } },
                })
              end
            end,
            colors = function()
              if not package.loaded["catppuccin.palettes"] then
                return {}
              end
              local flavor = require("catppuccin").options.flavour or "mocha"
              local p = require("catppuccin.palettes").get_palette(flavor)
              return {
                bg = p.base,
                bg1 = p.mantle,
                fg = p.text,
                red = p.red,
                green = p.green,
                yellow = p.yellow,
                blue = p.blue,
                purple = p.mauve,
                aqua = p.teal,
                orange = p.peach,
                gray = p.overlay0,
                border = p.surface0,
                selection_bg = p.surface1,
                selection_fg = p.text,
              }
            end,
          },
        },

        -- File operations
        load = function(self)
          if vim.fn.filereadable(self.settings_file) == 0 then
            return self.current
          end

          local content = vim.fn.readfile(self.settings_file)
          if #content == 0 then
            return self.current
          end

          local ok, parsed = pcall(vim.fn.json_decode, table.concat(content, ""))
          if not ok or type(parsed) ~= "table" then
            return self.current
          end

          return {
            name = parsed.name or self.current.name,
            variant = parsed.variant or self.current.variant,
            transparency = parsed.transparency or self.current.transparency,
          }
        end,

        save = function(self)
          vim.fn.mkdir(vim.fn.fnamemodify(self.settings_file, ":h"), "p")

          local ok, json = pcall(vim.fn.json_encode, self.current)
          if not ok then
            vim.notify("Failed to encode theme settings", vim.log.levels.ERROR)
            return false
          end

          pcall(vim.fn.writefile, { json }, self.settings_file)
          return true
        end,

        -- Theme operations
        apply = function(self, name, variant, transparency)
          name = name or self.current.name

          -- Validate theme exists
          if not self.registry[name] then
            vim.notify("Theme '" .. name .. "' not found, using gruvbox-material", vim.log.levels.WARN)
            name = "gruvbox-material"
          end

          local theme_info = self.registry[name]

          -- Set properties
          self.current.name = name
          if variant and (not theme_info.variants or vim.tbl_contains(theme_info.variants, variant)) then
            self.current.variant = variant
          end
          if transparency ~= nil then
            self.current.transparency = transparency
          end

          -- Run theme-specific setup with error handling
          local setup_ok, setup_err = pcall(theme_info.setup, self.current.variant, self.current.transparency)
          if not setup_ok then
            vim.notify("Error in theme setup: " .. tostring(setup_err), vim.log.levels.WARN)
          end

          -- Apply colorscheme with enhanced error handling
          local success, err = pcall(vim.cmd, "colorscheme " .. name)
          if not success then
            vim.notify("Failed to load colorscheme " .. name .. ": " .. tostring(err), vim.log.levels.ERROR)
            -- Try loading default colorscheme as fallback
            pcall(vim.cmd, "colorscheme default")
            return false
          end

          -- Persist settings
          self:save()
          return true
        end,

        -- Gets colors from current theme
        colors = function(self)
          local name = vim.g.colors_name or self.current.name

          -- If theme exists in registry, use its color function
          if self.registry[name] and self.registry[name].colors then
            local colors = self.registry[name].colors()
            -- Add special colors if they don't exist
            colors.copilot = colors.copilot or "#6CC644"
            colors.codeium = colors.codeium or "#09B6A2"
            return colors
          end

          -- Fallback: extract from highlight groups
          local function get_hl(group, attr, fallback)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
            local val = ok and hl[attr]
            if not val then
              return fallback
            end
            if type(val) == "number" then
              return string.format("#%06x", val)
            end
            return tostring(val)
          end

          return {
            bg = get_hl("Normal", "bg", "#282828"),
            bg1 = get_hl("CursorLine", "bg", "#32302f"),
            fg = get_hl("Normal", "fg", "#d4be98"),
            red = get_hl("DiagnosticError", "fg", "#ea6962"),
            green = get_hl("DiagnosticOk", "fg", "#89b482"),
            yellow = get_hl("DiagnosticWarn", "fg", "#d8a657"),
            blue = get_hl("Function", "fg", "#7daea3"),
            purple = get_hl("Keyword", "fg", "#d3869b"),
            aqua = get_hl("Type", "fg", "#7daea3"),
            orange = get_hl("Number", "fg", "#e78a4e"),
            gray = get_hl("Comment", "fg", "#928374"),
            border = get_hl("FloatBorder", "fg", "#45403d"),
            popup_bg = get_hl("Pmenu", "bg", "#282828"),
            selection_bg = get_hl("PmenuSel", "bg", "#45403d"),
            selection_fg = get_hl("PmenuSel", "fg", "#d4be98"),
            copilot = "#6CC644",
            codeium = "#09B6A2",
          }
        end,

        -- Commands
        cycle_theme = function(self)
          local current = vim.g.colors_name or self.current.name
          local names = vim.tbl_keys(self.registry)
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

          -- Apply theme
          self:apply(next_theme)

          -- Show notification
          local theme_info = self.registry[next_theme]
          local icon = theme_info and theme_info.icon or ""
          vim.notify(icon .. "Switched to " .. next_theme, vim.log.levels.INFO)
        end,

        cycle_variant = function(self)
          local current = vim.g.colors_name or self.current.name
          local theme_info = self.registry[current]

          if not theme_info or not theme_info.variants or #theme_info.variants == 0 then
            vim.notify("Current theme doesn't have variants", vim.log.levels.WARN)
            return
          end

          -- Find next variant in cycle
          local current_variant = self.current.variant or theme_info.variants[1]
          local idx = 1
          for i, variant in ipairs(theme_info.variants) do
            if variant == current_variant then
              idx = i
              break
            end
          end

          local next_idx = idx % #theme_info.variants + 1
          local next_variant = theme_info.variants[next_idx]

          -- Apply next variant
          self:apply(current, next_variant)

          -- Show notification
          local icon = theme_info and theme_info.icon or ""
          vim.notify(icon .. "Changed " .. current .. " variant to " .. next_variant, vim.log.levels.INFO)
        end,

        toggle_transparency = function(self)
          self:apply(nil, nil, not self.current.transparency)

          vim.notify("Transparency " .. (self.current.transparency and "enabled" or "disabled"), vim.log.levels.INFO)
        end,
      }

      -- Setup global functions
      _G.get_ui_colors = function()
        return theme:colors()
      end

      -- Create commands
      vim.api.nvim_create_user_command("CycleColorScheme", function()
        theme:cycle_theme()
      end, { desc = "Cycle through color schemes" })

      vim.api.nvim_create_user_command("ColorScheme", function(opts)
        local args = opts.args
        if args == "" then
          -- List available themes
          local available = {}
          for name, info in pairs(theme.registry) do
            local variant_info = info.variants
                and #info.variants > 0
                and (" (" .. table.concat(info.variants, ", ") .. ")")
              or ""
            table.insert(available, info.icon .. " " .. name .. variant_info)
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
        theme:apply(theme_name, variant)

        -- Show notification
        local info = theme.registry[theme_name]
        local icon = info and info.icon or ""
        vim.notify(icon .. "Switched to " .. theme_name .. (variant and (" - " .. variant) or ""), vim.log.levels.INFO)
      end, {
        nargs = "?",
        complete = function()
          return vim.tbl_keys(theme.registry)
        end,
        desc = "Set colorscheme",
      })

      vim.api.nvim_create_user_command("CycleColorVariant", function()
        theme:cycle_variant()
      end, { desc = "Cycle through color scheme variants" })

      vim.api.nvim_create_user_command("ColorVariant", function(opts)
        local current = vim.g.colors_name or theme.current.name
        local info = theme.registry[current]

        if not info or not info.variants or #info.variants == 0 then
          vim.notify("Current theme doesn't have variants", vim.log.levels.WARN)
          return
        end

        local variant = opts.args
        if variant == "" then
          vim.notify(
            "Available variants for " .. current .. ": " .. table.concat(info.variants, ", "),
            vim.log.levels.INFO
          )
          return
        end

        if not vim.tbl_contains(info.variants, variant) then
          vim.notify("Invalid variant: " .. variant, vim.log.levels.ERROR)
          return
        end

        -- Apply variant
        theme:apply(current, variant)

        vim.notify("Set " .. current .. " variant to " .. variant, vim.log.levels.INFO)
      end, {
        nargs = "?",
        complete = function()
          local current = vim.g.colors_name or theme.current.name
          local info = theme.registry[current]
          return info and info.variants or {}
        end,
        desc = "Set colorscheme variant",
      })

      vim.api.nvim_create_user_command("ToggleBackgroundTransparency", function()
        theme:toggle_transparency()
      end, { desc = "Toggle background transparency" })

      -- Load and apply saved settings
      theme.current = theme:load()
      vim.defer_fn(function()
        local ok, err = pcall(function()
          theme:apply()
        end)
        if not ok then
          vim.notify("Error applying theme: " .. tostring(err), vim.log.levels.ERROR)
          -- Fallback to simple theme setup
          vim.g.gruvbox_material_background = "medium"
          vim.g.gruvbox_material_better_performance = 1
          pcall(vim.cmd, "colorscheme gruvbox-material")
        end
      end, 100)
    end,
  },

  -- Additional themes (lazy-loaded)
  { "folke/tokyonight.nvim", lazy = true, priority = 950 },
  { "sainnhe/everforest", lazy = true, priority = 950 },
  { "rebelot/kanagawa.nvim", lazy = true, priority = 950 },
  { "shaunsingh/nord.nvim", lazy = true, priority = 950 },
  { "rose-pine/neovim", name = "rose-pine", lazy = true, priority = 950 },
  { "catppuccin/nvim", name = "catppuccin", lazy = true, priority = 950 },
}
