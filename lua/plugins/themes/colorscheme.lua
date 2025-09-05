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
        ["ashen"] = {
          icon = "",
          variants = {},
          apply_variant = function() return false end,
          set_transparency = function(enable)
            pcall(require("ashen").setup, { transparent = enable })
            return true
          end,
        },
        ["catppuccin"] = {
          icon = "",
          variants = { "latte", "frappe", "macchiato", "mocha" },
          apply_variant = function(variant)
            pcall(require("catppuccin").setup, { flavour = variant })
            pcall(require("catppuccin").compile)
            pcall(vim.cmd, "colorscheme catppuccin-" .. variant)
            return true
          end,
          set_transparency = function(enable)
            pcall(require("catppuccin").setup, { transparent_background = enable })
            return true
          end,
        },
        ["decay"] = {
          icon = "",
          variants = { "default", "dark", "light", "decayce" },
          apply_variant = function(variant)
            if variant == "decayce" then
              pcall(vim.cmd, "colorscheme decayce")
            else
              pcall(vim.cmd, "colorscheme decay-" .. variant)
            end
            return true
          end,
          set_transparency = function(enable)
            pcall(require("decay").setup, { transparent = enable })
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
        ["monokai-pro"] = {
          icon = "",
          variants = { "pro", "classic", "machine", "octagon", "ristretto", "spectrum" },
          apply_variant = function(variant)
            local filter = variant or "pro"
            local success = pcall(require("monokai-pro").setup, {
              filter = filter,
              transparent_background = false,
              terminal_colors = true,
              devicons = true,
            })
            return success
          end,
          set_transparency = function(enable)
            -- Get current settings to preserve filter
            local current_settings = load_settings()
            local current_filter = current_settings.variant or "pro"
            local success = pcall(require("monokai-pro").setup, {
              filter = current_filter,
              transparent_background = enable,
              terminal_colors = true,
              devicons = true,
            })
            return success
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
        ["nordic"] = {
          icon = "",
          variants = {},
          apply_variant = function() return false end,
          set_transparency = function(enable)
            -- pcall(require("nordic").setup, { transparent_bg = enable })
            -- return true
            return false
          end,
        },
        ["onedark"] = {
          icon = "",
          variants = { "dark", "darker", "cool", "deep", "warm", "warmer" },
          apply_variant = function(variant)
            pcall(require("onedark").setup, { style = variant })
            return true
          end,
          set_transparency = function(enable)
            pcall(require("onedark").setup, { transparent = enable })
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
        ["tokyonight"] = {
          icon = "",
          variants = { "night", "storm", "day", "moon" },
          apply_variant = function(variant)
            vim.g.tokyonight_style = variant
            pcall(require("tokyonight").setup, { style = variant })
            pcall(vim.cmd, "colorscheme tokyonight-" .. variant)
            return true
          end,
          set_transparency = function(enable)
            pcall(require("tokyonight").setup, { transparent = enable })
            return true
          end,
        },
      }

      -- Function to detect current system theme from theme.conf
      local function detect_system_theme()
        local theme_paths = {
          os.getenv("HOME") .. "/.config/hypr/themes/theme.conf",
          os.getenv("HOME") .. "/.config/hypr/theme.conf",
          os.getenv("HOME") .. "/.config/hypr/hyprland.conf",
        }

        for _, path in ipairs(theme_paths) do
          if vim.fn.filereadable(path) == 1 then
            local content = table.concat(vim.fn.readfile(path), "\n")

            -- Look for NVIM_SCHEME and NVIM_VARIANT variables
            local nvim_scheme = content:match("%$NVIM_SCHEME%s*=%s*([%w%-_]+)")
            local nvim_variant = content:match("%$NVIM_VARIANT%s*=%s*([%w%-_]+)")

            if nvim_scheme then
              -- Clean up the values
              nvim_scheme = nvim_scheme:gsub("%s+", "")
              nvim_variant = nvim_variant and nvim_variant:gsub("%s+", "") or nil

              return nvim_scheme, nvim_variant
            end
          end
        end

        -- Check environment variables as final fallback
        local env_scheme = os.getenv("NVIM_SCHEME") or os.getenv("NVIM_THEME")
        local env_variant = os.getenv("NVIM_VARIANT")

        if env_scheme then
          return env_scheme, env_variant
        end

        return nil, nil
      end

      -- Function to apply detected theme with variant support
      local function apply_system_theme()
        local detected_scheme, detected_variant = detect_system_theme()

        if not detected_scheme then
          return false
        end

        -- Validate theme exists in our themes table
        if not themes[detected_scheme] then
          vim.notify("Scheme '" .. detected_scheme .. "' not available, using fallback", vim.log.levels.WARN)
          return false
        end

        -- Validate variant if specified
        if detected_variant then
          local theme_info = themes[detected_scheme]
          if theme_info.variants and #theme_info.variants > 0 then
            if not vim.tbl_contains(theme_info.variants, detected_variant) then
              vim.notify(
                "Variant '" .. detected_variant .. "' not available for " .. detected_scheme .. ", using default",
                vim.log.levels.WARN)
              detected_variant = nil
            end
          else
            vim.notify("Scheme '" .. detected_scheme .. "' doesn't support variants, ignoring variant",
              vim.log.levels.WARN)
            detected_variant = nil
          end
        end

        -- Apply the theme
        local settings = load_settings()
        apply_theme(detected_scheme, detected_variant, settings.transparency)

        local variant_text = detected_variant and (" - " .. detected_variant) or ""
        vim.notify("🎨 Applied system theme: " .. detected_scheme .. variant_text, vim.log.levels.INFO)
        return true
      end

      -- Function to set up file watcher for theme.conf changes
      local function setup_system_theme_watcher()
        local theme_file = os.getenv("HOME") .. "/.config/hypr/themes/theme.conf"

        if vim.fn.filereadable(theme_file) == 1 then
          -- Use Neovim's file watcher if available (nvim 0.10+)
          if vim.uv and vim.uv.fs_event_start then
            local handle = vim.uv.new_fs_event()
            vim.uv.fs_event_start(handle, theme_file, {}, function(err, filename, events)
              if not err and events.change then
                vim.schedule(function()
                  vim.defer_fn(function()
                    apply_system_theme()
                  end, 500) -- Small delay to avoid rapid-fire changes
                end)
              end
            end)
          end
        end
      end

      local function apply_theme(name, variant, transparency)
        local theme = themes[name]
        if not theme then
          vim.notify("Theme '" .. name .. "' not found, using kanagawa", vim.log.levels.WARN)
          name = "kanagawa"
          theme = themes[name]
        end

        if variant and theme.variants and vim.tbl_contains(theme.variants, variant) then
          if name == "catppuccin" then
            theme.apply_variant(variant)
          elseif name == "decay" then
            theme.apply_variant(variant)
          elseif name == "monokai-pro" then
            theme.apply_variant(variant)
            vim.cmd("colorscheme " .. name)
          else
            theme.apply_variant(variant)
            vim.cmd("colorscheme " .. name)
          end
        else
          if name == "monokai-pro" then
            local success = pcall(require("monokai-pro").setup, {
              filter = "pro",
              transparent_background = transparency or false,
              terminal_colors = true,
              devicons = true,
            })
            if success then
              vim.cmd("colorscheme " .. name)
            end
          elseif name == "decay" then
            pcall(require("decay").setup, {
              style = "default",
              transparent = transparency or false,
              nvim_tree = { contrast = true },
            })
          else
            vim.cmd("colorscheme " .. name)
          end
        end

        -- Apply transparency after colorscheme
        if theme.set_transparency then
          theme.set_transparency(transparency)
          -- For monokai-pro, reapply colorscheme after transparency change
          if name == "monokai-pro" then
            pcall(vim.cmd, "colorscheme " .. name)
          end
        end

        -- Save settings for persistence
        local settings = { theme = name, variant = variant, transparency = transparency }
        save_settings(settings)
      end

      local function cycle_theme()
        local current = vim.g.colors_name or "kanagawa"

        local theme_name = current
        if current:match("^catppuccin%-") then
          theme_name = "catppuccin"
        elseif current:match("^tokyonight") then
          theme_name = "tokyonight"
        elseif current:match("^decay") then
          theme_name = "decay"
        end

        local names = vim.tbl_keys(themes)
        table.sort(names)

        local idx = 1
        for i, name in ipairs(names) do
          if name == theme_name then
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
        elseif current:match("^tokyonight") then
          theme_name = "tokyonight"
        elseif current:match("^decay") then
          theme_name = "decay"
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
        vim.notify(icon .. "Changed " .. theme_name .. " variant to " .. next_variant, vim.log.levels.INFO)
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

      vim.api.nvim_create_user_command("SystemSync", function()
        if not apply_system_theme() then
          vim.notify("No system theme detected or theme not available", vim.log.levels.WARN)
        end
      end, { desc = "Sync colorscheme with system theme" })

      vim.api.nvim_create_user_command("SystemDetect", function()
        local scheme, variant = detect_system_theme()
        if scheme then
          local available = themes[scheme] and "✓ Available" or "⚠ Not available"
          local variant_text = variant and (" + " .. variant) or ""
          vim.notify("System theme: " .. scheme .. variant_text .. " (" .. available .. ")", vim.log.levels.INFO)

          -- Show available variants if scheme exists
          if themes[scheme] and themes[scheme].variants and #themes[scheme].variants > 0 then
            vim.notify("Available variants: " .. table.concat(themes[scheme].variants, ", "), vim.log.levels.INFO)
          end
        else
          vim.notify("No NVIM_SCHEME found in system config", vim.log.levels.WARN)
        end
      end, { desc = "Detect current system theme" })

      vim.api.nvim_create_user_command("SystemSetTheme", function(opts)
        local args = vim.split(opts.args, "%s+")
        local scheme = args[1]
        local variant = args[2]

        if not scheme or scheme == "" then
          vim.notify("Usage: SystemSetTheme <scheme> [variant]", vim.log.levels.ERROR)
          return
        end

        if not themes[scheme] then
          vim.notify("Scheme '" .. scheme .. "' not available", vim.log.levels.ERROR)
          return
        end

        -- Validate variant if provided
        if variant then
          local theme_info = themes[scheme]
          if not theme_info.variants or #theme_info.variants == 0 then
            vim.notify("Scheme '" .. scheme .. "' doesn't support variants", vim.log.levels.ERROR)
            return
          elseif not vim.tbl_contains(theme_info.variants, variant) then
            vim.notify("Variant '" .. variant .. "' not available for " .. scheme, vim.log.levels.ERROR)
            vim.notify("Available variants: " .. table.concat(theme_info.variants, ", "), vim.log.levels.INFO)
            return
          end
        end

        -- Update theme.conf file
        local theme_file = os.getenv("HOME") .. "/.config/hypr/themes/theme.conf"
        if vim.fn.filereadable(theme_file) == 1 then
          local content = vim.fn.readfile(theme_file)
          local updated_scheme = false
          local updated_variant = false

          -- Update or add NVIM_SCHEME
          for i, line in ipairs(content) do
            if line:match("^%$NVIM_SCHEME") then
              content[i] = "$NVIM_SCHEME = " .. scheme
              updated_scheme = true
            elseif line:match("^%$NVIM_VARIANT") then
              if variant then
                content[i] = "$NVIM_VARIANT = " .. variant
              else
                -- Remove variant line if no variant specified
                table.remove(content, i)
              end
              updated_variant = true
            end
          end

          -- Add NVIM_SCHEME if not found
          if not updated_scheme then
            table.insert(content, 1, "$NVIM_SCHEME = " .. scheme)
          end

          -- Add NVIM_VARIANT if variant specified and not found
          if variant and not updated_variant then
            -- Find NVIM_SCHEME line and insert NVIM_VARIANT after it
            for i, line in ipairs(content) do
              if line:match("^%$NVIM_SCHEME") then
                table.insert(content, i + 1, "$NVIM_VARIANT = " .. variant)
                break
              end
            end
          end

          vim.fn.writefile(content, theme_file)

          -- Apply the theme
          local settings = load_settings()
          apply_theme(scheme, variant, settings.transparency)

          local variant_text = variant and (" with variant " .. variant) or ""
          vim.notify("Set system theme to: " .. scheme .. variant_text, vim.log.levels.INFO)
        else
          vim.notify("theme.conf not found at " .. theme_file, vim.log.levels.ERROR)
        end
      end, {
        nargs = "+",
        complete = function(arg_lead, cmd_line, cursor_pos)
          local args = vim.split(cmd_line, "%s+")
          if #args <= 2 then
            -- Complete scheme names
            return vim.tbl_keys(themes)
          elseif #args == 3 then
            -- Complete variant names for the specified scheme
            local scheme = args[2]
            if themes[scheme] and themes[scheme].variants then
              return themes[scheme].variants
            end
          end
          return {}
        end,
        desc = "Set NVIM_SCHEME and NVIM_VARIANT in system config"
      })

      vim.api.nvim_create_user_command("SystemListThemes", function()
        local available_themes = {}

        for name, theme in pairs(themes) do
          local variants_text = ""
          if theme.variants and #theme.variants > 0 then
            variants_text = " (variants: " .. table.concat(theme.variants, ", ") .. ")"
          end
          table.insert(available_themes, theme.icon .. " " .. name .. variants_text)
        end

        table.sort(available_themes)

        vim.notify("Available themes for system integration:\n" .. table.concat(available_themes, "\n"),
          vim.log.levels.INFO, {
            title = "System Themes",
            timeout = 10000 -- Show longer for reading
          })

        -- Also show usage examples
        vim.defer_fn(function()
          vim.notify("Usage examples:\n" ..
            ":SystemSetTheme kanagawa wave\n" ..
            ":SystemSetTheme catppuccin mocha\n" ..
            ":SystemSetTheme nord\n" ..
            ":SystemSetTheme tokyonight storm",
            vim.log.levels.INFO, { title = "Usage Examples" })
        end, 2000)
      end, { desc = "List available themes for system integration" })

      -- Auto-apply system theme on startup and setup watcher
      vim.defer_fn(function()
        if not apply_system_theme() then
          -- Apply initial theme if system detection fails
          local settings = load_settings()
          apply_theme(settings.theme, settings.variant, settings.transparency)
        end

        -- Setup file watcher for automatic theme changes
        setup_system_theme_watcher()
      end, 500)

      -- Apply initial theme
      local settings = load_settings()
      apply_theme(settings.theme, settings.variant, settings.transparency)
    end,
  },

  -- Additional themes (lazy loaded)
  {
    "ficcdaf/ashen.nvim",
    lazy = true,
    priority = 950,
    config = function()
      require("ashen").setup({
        transparent = false,
        italic_comments = true,
      })
      _G.get_ashen_colors = function()
        -- Fallback colors since ashen might not export colors
        return {
          bg = "#0f0f0f",
          bg1 = "#1a1a1a",
          fg = "#c5c5c5",
          red = "#ff6b6b",
          green = "#51cf66",
          yellow = "#ffd43b",
          blue = "#339af0",
          purple = "#845ef7",
          aqua = "#22b8cf",
          orange = "#ff922b",
          gray = "#868e96",
          border = "#343a40",
          popup_bg = "#0f0f0f",
          selection_bg = "#343a40",
          selection_fg = "#c5c5c5",
          copilot = "#6CC644",
          codeium = "#09B6A2",
        }
      end
    end,
  },
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
    "decaycs/decay.nvim",
    name = "decay",
    lazy = true,
    priority = 950,
    config = function()
      require("decay").setup({
        style = "default",
        transparent = false,
        nvim_tree = { contrast = true },
      })
      _G.get_decay_colors = function()
        -- Fallback colors since decay might not export colors API
        return {
          bg = "#101419",
          bg1 = "#171B20",
          fg = "#b6beca",
          red = "#e05f65",
          green = "#78dba9",
          yellow = "#f1cf8a",
          blue = "#70a5eb",
          purple = "#c68aee",
          aqua = "#74bee9",
          orange = "#f8965e",
          gray = "#485263",
          border = "#1c252c",
          popup_bg = "#101419",
          selection_bg = "#1c252c",
          selection_fg = "#b6beca",
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
    "loctvl842/monokai-pro.nvim",
    lazy = true,
    priority = 950,
    config = function()
      -- Basic setup - will be overridden by theme management
      require("monokai-pro").setup({
        transparent_background = false,
        terminal_colors = true,
        devicons = true,
        filter = "pro",
      })

      -- Color function with static fallback colors
      _G.get_monokai_pro_colors = function()
        -- Fallback to standard colors since monokai-pro API is unclear
        return {
          bg = "#2D2A2E",
          bg1 = "#403E41",
          fg = "#FCFCFA",
          red = "#FF6188",
          green = "#A9DC76",
          yellow = "#FFD866",
          blue = "#78DCE8",
          purple = "#AB9DF2",
          aqua = "#78DCE8",
          orange = "#FC9867",
          gray = "#727072",
          border = "#5B595C",
          popup_bg = "#2D2A2E",
          selection_bg = "#403E41",
          selection_fg = "#FCFCFA",
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
    "AlexvZyl/nordic.nvim",
    lazy = true,
    priority = 950,
    config = function()
      require("nordic").setup({
        bold_keywords = false,
        italic_comments = true,
        -- transparent_bg = false,
        bright_border = false,
        reduced_blue = true,
        swap_backgrounds = false,
      })
      _G.get_nordic_colors = function()
        local colors = require("nordic.colors")
        return {
          bg = colors.black0,
          bg1 = colors.gray0,
          fg = colors.white0,
          red = colors.red.base,
          green = colors.green.base,
          yellow = colors.yellow.base,
          blue = colors.blue1,
          purple = colors.magenta.base,
          aqua = colors.cyan.base,
          orange = colors.orange.base,
          gray = colors.gray4,
          border = colors.gray2,
          popup_bg = colors.black0,
          selection_bg = colors.gray2,
          selection_fg = colors.white0,
          copilot = "#6CC644",
          codeium = "#09B6A2",
        }
      end
    end,
  },
  {
    "navarasu/onedark.nvim",
    lazy = true,
    priority = 950,
    config = function()
      require("onedark").setup({
        style = "dark",
        transparent = false,
        term_colors = true,
        ending_tildes = false,
        cmp_itemkind_reverse = false,
        code_style = {
          comments = "italic",
          keywords = "none",
          functions = "none",
          strings = "none",
          variables = "none",
        },
      })
      _G.get_onedark_colors = function()
        local colors = require("onedark.colors")
        return {
          bg = colors.bg0,
          bg1 = colors.bg1,
          fg = colors.fg,
          red = colors.red,
          green = colors.green,
          yellow = colors.yellow,
          blue = colors.blue,
          purple = colors.purple,
          aqua = colors.cyan,
          orange = colors.orange,
          gray = colors.grey,
          border = colors.bg3,
          popup_bg = colors.bg0,
          selection_bg = colors.bg3,
          selection_fg = colors.fg,
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
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 950,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        terminal_colors = true,
        styles = { comments = { italic = true }, keywords = { italic = true } },
        sidebars = { "qf", "help" },
        day_brightness = 0.3,
      })
      _G.get_tokyonight_colors = function()
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
          aqua = colors.cyan,
          orange = colors.orange,
          gray = colors.fg_gutter,
          border = colors.border,
          popup_bg = colors.bg_popup,
          selection_bg = colors.bg_visual,
          selection_fg = colors.fg,
          copilot = "#6CC644",
          codeium = "#09B6A2",
        }
      end
    end,
  },
}
