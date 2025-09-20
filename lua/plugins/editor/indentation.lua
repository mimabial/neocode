return {
  -- Rainbow delimiters for matching pairs
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      local function get_rainbow_colors()
        if _G.get_ui_colors then
          local ok, colors = pcall(_G.get_ui_colors)
          if ok and colors then
            return {
              colors.red,
              colors.yellow,
              colors.blue,
              colors.orange,
              colors.green,
              colors.purple,
              colors.aqua or colors.blue,
            }
          end
        end

        local function get_hl_color(group, fallback)
          local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
          if ok and hl.fg then
            return string.format("#%06x", hl.fg)
          end
          return fallback
        end

        return {
          get_hl_color("DiagnosticError", "#cc241d"), -- Red
          get_hl_color("DiagnosticWarn", "#d79921"),  -- Yellow
          get_hl_color("Function", "#458588"),        -- Blue
          get_hl_color("Number", "#d65d0e"),          -- Orange
          get_hl_color("String", "#98971a"),          -- Green
          get_hl_color("Keyword", "#b16286"),         -- Purple
          get_hl_color("Type", "#689d6a"),            -- Aqua
        }
      end

      local function set_rainbow_colors()
        local palette = get_rainbow_colors()

        for i, color in ipairs(palette) do
          local hl_group = "RainbowDelimiter" .. i
          vim.api.nvim_set_hl(0, hl_group, { fg = color })
        end
      end

      -- Set initial colors
      set_rainbow_colors()

      -- Now setup rainbow delimiters with the highlights
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy.global,
          vim = rainbow_delimiters.strategy["local"],
          html = rainbow_delimiters.strategy.global,
          tsx = rainbow_delimiters.strategy.global,
          jsx = rainbow_delimiters.strategy.global,
          templ = rainbow_delimiters.strategy.global,
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-delimiters",
          html = "rainbow-tags",
          tsx = "rainbow-tags",
          jsx = "rainbow-tags",
          templ = "rainbow-tags",
          javascript = "rainbow-delimiters-react",
          typescript = "rainbow-delimiters-react",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
        highlight = {
          "RainbowDelimiter1",
          "RainbowDelimiter2",
          "RainbowDelimiter3",
          "RainbowDelimiter4",
          "RainbowDelimiter5",
          "RainbowDelimiter6",
          "RainbowDelimiter7",
        },
      }

      -- Update highlights on colorscheme change
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_rainbow_colors,
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPre",
    dependencies = { "HiPhish/rainbow-delimiters.nvim" },
    opts = function()
      -- Default indent character
      local indent_char = "│"

      return {
        indent = {
          char = indent_char,
          tab_char = indent_char,
          highlight = "Comment",
          smart_indent_cap = true,
          priority = 100, -- lower than rainbow delimiters
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = true,
          injected_languages = true,
          priority = 500, -- Higher than rainbow delimiters
          highlight = "IblScope",
          char = indent_char,
        },
        exclude = {
          filetypes = {
            "help",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
            "terminal",
            "TelescopePrompt",
            "TelescopeResults",
            "startup",
            "NvimTree",
            "packer",
            "oil",
          },
          buftypes = {
            "terminal",
            "nofile",
            "quickfix",
            "prompt",
          },
        },
      }
    end,
    config = function(_, opts)
      local ok, ibl = pcall(require, "ibl")
      if not ok then
        vim.notify("Failed to load indent-blankline.nvim", vim.log.levels.ERROR)
        return
      end

      -- Set up custom highlight using the hooks system
      local hooks = require("ibl.hooks")
      
      -- Create custom highlight group using the hooks system
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        -- Get colors from UI system if available
        local colors = _G.get_ui_colors and _G.get_ui_colors() or {}
        
        -- Fallback color extraction
        local function get_hl_color(group, attr, fallback)
          local hl_ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
          local val = hl_ok and hl[attr]
          if not val then return fallback end
          if type(val) == "number" then
            return string.format("#%06x", val)
          end
          return tostring(val)
        end
        
        local border_color = colors.border or get_hl_color("FloatBorder", "fg", "#45403d")
        
        -- Set the scope highlight to use a border-like color
        vim.api.nvim_set_hl(0, "IblScope", { fg = border_color })
      end)

      ibl.setup(opts)
    end,
  },
}
