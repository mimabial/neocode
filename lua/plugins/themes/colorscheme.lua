return {
  -- Primary theme - Kanagawa
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
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
          setup = function(variant, transparency)
            require("ashen").setup({ transparent = transparency })
            vim.cmd("colorscheme ashen")
          end,
        },
        ["ayu"] = {
          icon = "",
          variants = { "dark", "light", "mirage" },
          setup = function(variant, transparency)
            local ayu_config = {
              mirage = variant == "mirage",
              terminal = true,
            }

            -- Handle transparency via overrides
            if transparency then
              ayu_config.overrides = {
                Normal = { bg = "None" },
                NormalFloat = { bg = "None" },
                ColorColumn = { bg = "None" },
                SignColumn = { bg = "None" },
                Folded = { bg = "None" },
                FoldColumn = { bg = "None" },
                CursorLine = { bg = "None" },
                CursorColumn = { bg = "None" },
                VertSplit = { bg = "None" },
              }
            end

            require("ayu").setup(ayu_config)

            -- Set background and apply colorscheme
            if variant == "light" then
              vim.o.background = "light"
              vim.cmd("colorscheme ayu-light")
            elseif variant == "mirage" then
              vim.o.background = "dark"
              vim.cmd("colorscheme ayu-mirage")
            else
              vim.o.background = "dark"
              vim.cmd("colorscheme ayu-dark")
            end
          end,
        },
        ["bamboo"] = {
          icon = "",
          variants = { "vulgaris", "multiplex", "light" },
          setup = function(variant, transparency)
            require("bamboo").setup({
              style = variant,
              transparent = transparency,
            })
            require("bamboo").load()
          end,
        },
        ["bauhaus"] = {
          icon = "",
          variants = { "default", "bauhaus", "bluesky" },
          setup = function(variant, transparency)
            require("bauhaus").setup({
              variant = variant,
              transparent = transparency,
            })
            vim.cmd("colorscheme bauhaus")
          end,
        },
        ["catppuccin"] = {
          icon = "",
          variants = { "latte", "frappe", "macchiato", "mocha" },
          setup = function(variant, transparency)
            require("catppuccin").setup({
              flavour = variant,
              transparent_background = transparency,
            })
            require("catppuccin").compile()
            vim.cmd("colorscheme catppuccin" .. (variant and "-" .. variant or ""))
          end,
        },
        ["darkvoid"] = {
          icon = "",
          variants = { "glow" },
          setup = function(variant, transparency)
            require("darkvoid").setup({
              transparent = transparency,
              glow = (variant == "glow"),
              colors = {
                bg = "262626",
              },
              plugins = {
                gitsigns = true,
                nvim_cmp = true,
                treesitter = true,
                nvimtree = true,
                telescope = true,
                lualine = true,
                bufferline = true,
                oil = true,
                whichkey = true,
                nvim_notify = true,
              },
            })
            vim.cmd("colorscheme darkvoid")
          end,
        },
        ["decay"] = {
          icon = "",
          variants = { "default", "dark", "light", "decayce" },
          setup = function(variant, transparency)
            if variant == "light" then
              vim.o.background = "light"
            else
              vim.o.background = "dark"
            end

            require("decay").setup({
              style = variant ~= "light" and variant or "default",
              transparent = transparency,
            })

            if variant == "decayce" then
              vim.cmd("colorscheme decayce")
              vim.g.colors_name = "decayce"
            else
              vim.cmd("colorscheme decay" .. (variant and "-" .. variant or ""))
              vim.g.colors_name = "decay" .. (variant and "-" .. variant or "")
            end
          end,
        },
        ["everforest"] = {
          icon = "",
          variants = { "soft", "medium", "hard" },
          setup = function(variant, transparency)
            vim.o.background = "dark"
            if variant then vim.g.everforest_background = variant end
            if transparency then vim.g.everforest_transparent_background = 1 end
            vim.cmd("colorscheme everforest")
          end,
        },
        ["gruvbox-material"] = {
          icon = "",
          variants = { "hard", "medium", "soft" },
          setup = function(variant, transparency)
            vim.o.background = "dark"
            if variant then vim.g.gruvbox_material_background = variant end
            vim.g.gruvbox_material_transparent_background = 0

            vim.cmd("colorscheme gruvbox-material")
          end,
        },
        ["kanagawa"] = {
          icon = "",
          variants = { "wave", "dragon", "lotus" },
          setup = function(variant, transparency)
            require("kanagawa").setup({
              theme = variant and variant or "wave",
              transparent = transparency,
            })
            vim.cmd("colorscheme kanagawa" .. "-" .. (variant and variant or "wave"))
          end,
        },
        ["monokai-pro"] = {
          icon = "",
          variants = { "pro", "classic", "machine", "octagon", "ristretto", "spectrum" },
          setup = function(variant, transparency)
            require("monokai-pro").setup({
              filter = variant,
              transparent_background = transparency,
            })
            vim.cmd("colorscheme monokai-pro")
          end,
        },
        ["nord"] = {
          icon = "",
          variants = {},
          setup = function(variant, transparency)
            if transparency then vim.g.nord_disable_background = true end
            vim.cmd("colorscheme nord")
          end,
        },
        ["onedark"] = {
          icon = "",
          variants = { "dark", "darker", "cool", "deep", "warm", "warmer" },
          setup = function(variant, transparency)
            require("onedark").setup({
              style = variant,
              transparent = transparency,
            })
            vim.cmd("colorscheme onedark")
          end,
        },
        ["oxocarbon"] = {
          icon = "",
          variants = { "dark", "light" },
          setup = function(variant, transparency)
            vim.opt.background = variant
            if transparency then
              vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
              vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
              vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
            else
              vim.api.nvim_set_hl(0, "Normal", {})
              vim.api.nvim_set_hl(0, "NormalFloat", {})
              vim.api.nvim_set_hl(0, "NormalNC", {})
            end
            vim.cmd("colorscheme oxocarbon")
          end,
        },
        ["rose-pine"] = {
          icon = "",
          variants = { "main", "moon", "dawn" },
          setup = function(variant, transparency)
            require("rose-pine").setup({
              variant = variant,
              disable_background = transparency,
            })
            vim.cmd("colorscheme rose-pine")
          end,
        },
        ["solarized-osaka"] = {
          icon = "",
          variants = {},
          setup = function(variant, transparency)
            require("solarized-osaka").setup({ transparent = transparency })
            vim.cmd("colorscheme solarized-osaka")
          end,
        },
        ["tokyonight"] = {
          icon = "",
          variants = { "night", "storm", "day", "moon" },
          setup = function(variant, transparency)
            require("tokyonight").setup({
              style = variant,
              transparent = transparency,
            })
            vim.cmd("colorscheme tokyonight" .. (variant and "-" .. variant or ""))
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

        if variant and theme.variants and #theme.variants > 0 then
          if not vim.tbl_contains(theme.variants, variant) then
            vim.notify("Variant '" .. variant .. "' not available for " .. name .. ", using default",
              vim.log.levels.WARN)
            variant = nil
          end
        end

        if theme.setup then
          theme.setup(variant, transparency or false)
        end

        save_settings({ theme = name, variant = variant, transparency = transparency })
      end

      local function detect_system_theme()
        local theme_paths = {
          os.getenv("HOME") .. "/.config/hypr/themes/theme.conf",
          os.getenv("HOME") .. "/.config/hypr/theme.conf",
          os.getenv("HOME") .. "/.config/hypr/hyprland.conf",
        }

        for _, path in ipairs(theme_paths) do
          if vim.fn.filereadable(path) == 1 then
            local content = table.concat(vim.fn.readfile(path), "\n")
            local nvim_scheme = content:match("%$NVIM_SCHEME%s*=%s*([%w%-_]+)")
            local nvim_variant = content:match("%$NVIM_VARIANT%s*=%s*([%w%-_]+)")
            local nvim_transparency = content:match("%$NVIM_TRANSPARENCY%s*=%s*([%w%-_]+)")

            if nvim_scheme then
              -- Clean up the values
              nvim_scheme = nvim_scheme:gsub("%s+", "")
              nvim_variant = nvim_variant and nvim_variant:gsub("%s+", "") or nil

              -- Parse transparency (true/false/1/0)
              local transparency = nil
              if nvim_transparency then
                nvim_transparency = nvim_transparency:gsub("%s+", ""):lower()
                transparency = nvim_transparency == "true" or nvim_transparency == "1"
              end

              return nvim_scheme, nvim_variant, transparency
            end
          end
        end

        -- Check environment variables as final fallback
        local env_scheme = os.getenv("NVIM_SCHEME") or os.getenv("NVIM_THEME")
        local env_variant = os.getenv("NVIM_VARIANT")
        local env_transparency = os.getenv("NVIM_TRANSPARENCY")

        local transparency = nil
        if env_transparency then
          env_transparency = env_transparency:lower()
          transparency = env_transparency == "true" or env_transparency == "1"
        end

        if env_scheme then
          return env_scheme, env_variant, transparency
        end

        return nil, nil, nil
      end

      local function apply_system_theme()
        local detected_scheme, detected_variant, detected_transparency = detect_system_theme()
        if not detected_scheme or not themes[detected_scheme] then
          return false
        end

        local settings = load_settings()
        local current_scheme = vim.g.colors_name or "kanagawa"

        if current_scheme:match("^catppuccin%-") then
          current_scheme = "catppuccin"
        elseif current_scheme:match("^decay") then
          current_scheme = "decay"
        elseif current_scheme:match("^tokyonight") then
          current_scheme = "tokyonight"
        end

        local theme_changed = current_scheme ~= detected_scheme
        local variant_changed = detected_variant ~= settings.variant
        local transparency_changed = detected_transparency ~= nil and detected_transparency ~= settings.transparency

        if not theme_changed and not variant_changed and not transparency_changed then
          return true
        end

        local final_transparency = detected_transparency ~= nil and detected_transparency or settings.transparency
        apply_theme(detected_scheme, detected_variant, final_transparency)

        local variant_text = detected_variant and ("-" .. detected_variant) or ""
        local transparency_text = detected_transparency ~= nil and
            (", transparency " .. (detected_transparency and "on" or "off")) or ""
        vim.notify("Applied system theme: " .. detected_scheme .. variant_text .. transparency_text, vim.log.levels.INFO)
        return true
      end

      local function setup_system_theme_watcher()
        local theme_file = os.getenv("HOME") .. "/.config/hypr/themes/theme.conf"
        if vim.fn.filereadable(theme_file) == 1 and vim.uv and vim.uv.fs_event_start then
          local handle = vim.uv.new_fs_event()
          vim.uv.fs_event_start(handle, theme_file, {}, function(err, filename, events)
            if not err and events.change then
              vim.schedule(function()
                apply_system_theme()
              end)
            end
          end)
        end
      end

      local function cycle_theme()
        local current = vim.g.colors_name or "kanagawa"
        local theme_name = current
        if current:match("^catppuccin%-") then
          theme_name = "catppuccin"
        elseif current:match("^decay") then
          theme_name = "decay"
        elseif current:match("^tokyonight") then
          theme_name = "tokyonight"
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
        elseif current:match("^decay") then
          theme_name = "decay"
        elseif current:match("^kanagawa%-") then
          theme_name = "kanagawa"
        elseif current:match("^tokyonight") then
          theme_name = "tokyonight"
        end

        local theme = themes[theme_name]
        if not theme or not theme.variants or #theme.variants == 0 then
          vim.notify("Current theme doesn't have variants", vim.log.levels.WARN)
          return
        end

        local settings = load_settings()
        local current_variant = settings.variant or theme.variants[1]

        if theme_name == "decay" then
          if current == "decayce" then
            current_variant = "decayce"
          elseif current:match("^decay%-(.+)$") then
            current_variant = current:match("^decay%-(.+)$")
          end
        elseif theme_name == "kanagawa" then
          if current:match("^kanagawa%-(.+)$") then
            current_variant = current:match("^kanagawa%-(.+)$")
          end
        end

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

        -- Update system config if theme.conf exists
        local theme_file = os.getenv("HOME") .. "/.config/hypr/themes/theme.conf"
        if vim.fn.filereadable(theme_file) == 1 then
          local content = vim.fn.readfile(theme_file)
          local updated = false

          -- Update or add NVIM_TRANSPARENCY
          for i, line in ipairs(content) do
            if line:match("^%$NVIM_TRANSPARENCY") then
              content[i] = "$NVIM_TRANSPARENCY = " .. (settings.transparency and "true" or "false")
              updated = true
              break
            end
          end

          -- Add NVIM_TRANSPARENCY if not found
          if not updated then
            -- Find NVIM_SCHEME line and insert NVIM_TRANSPARENCY after it
            for i, line in ipairs(content) do
              if line:match("^%$NVIM_SCHEME") then
                table.insert(content, i + (line:match("^%$NVIM_VARIANT") and 2 or 1),
                  "$NVIM_TRANSPARENCY = " .. (settings.transparency and "true" or "false"))
                break
              end
            end
          end

          pcall(vim.fn.writefile, content, theme_file)
        end

        vim.notify("Transparency " .. (settings.transparency and "enabled" or "disabled"), vim.log.levels.INFO)
      end

      vim.api.nvim_create_user_command("CycleColorScheme", cycle_theme, { desc = "Cycle through color schemes" })
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
        vim.notify(icon .. "Switched to " .. theme_name .. (variant and ("-" .. variant) or ""), vim.log.levels.INFO)
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
  { "ficcdaf/ashen.nvim",               lazy = true, priority = 950 },
  { "Shatur/neovim-ayu",                lazy = true, priority = 950 },
  { "ribru17/bamboo.nvim",              lazy = true, priority = 950 },
  { "catppuccin/nvim",                  lazy = true, priority = 950 },
  { "mimabial/bauhaus.nvim",            lazy = true, priority = 950 },
  { "aliqyan-21/darkvoid.nvim",         lazy = true, priority = 950 },
  { "decaycs/decay.nvim",               lazy = true, priority = 950 },
  { "sainnhe/everforest",               lazy = true, priority = 950 },
  { "sainnhe/gruvbox-material",         lazy = true, priority = 950 },
  { "loctvl842/monokai-pro.nvim",       lazy = true, priority = 950 },
  { "shaunsingh/nord.nvim",             lazy = true, priority = 950 },
  { "navarasu/onedark.nvim",            lazy = true, priority = 950 },
  { "nyoom-engineering/oxocarbon.nvim", lazy = true, priority = 950 },
  { "rose-pine/neovim",                 lazy = true, priority = 950 },
  { "craftzdog/solarized-osaka.nvim",   lazy = true, priority = 950 },
  { "folke/tokyonight.nvim",            lazy = true, priority = 950 },
}
