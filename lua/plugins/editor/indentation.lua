return {
  -- Rainbow delimiters for matching pairs
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      -- Define highlight groups immediately
      local colors = {
        ["catppuccin"] = {
          "#f38ba8", -- Red/Pink
          "#f9e2af", -- Yellow
          "#89b4fa", -- Blue
          "#fab387", -- Peach
          "#a6e3a1", -- Green
          "#cba6f7", -- Mauve
          "#94e2d5", -- Teal
        },
        ["everforest"] = {
          "#e67e80", -- Red
          "#dbbc7f", -- Yellow
          "#7fbbb3", -- Blue
          "#e69875", -- Orange
          "#a7c080", -- Green
          "#d699b6", -- Purple
          "#83c092", -- Aqua
        },
        ["gruvbox"] = {
          "#cc241d", -- Red
          "#d79921", -- Yellow
          "#458588", -- Blue
          "#d65d0e", -- Orange
          "#98971a", -- Green
          "#b16286", -- Purple
          "#689d6a", -- Aqua
        },
        ["kanagawa"] = {
          "#c34043", -- Red
          "#dca561", -- Yellow
          "#7e9cd8", -- Blue
          "#ffa066", -- Orange
          "#76946a", -- Green
          "#957fb8", -- Purple
          "#6a9589", -- Teal
        },
        ["nord"] = {
          "#bf616a", -- Red
          "#ebcb8b", -- Yellow
          "#81a1c1", -- Blue
          "#d08770", -- Orange
          "#a3be8c", -- Green
          "#b48ead", -- Purple
          "#88c0d0", -- Teal
        },
        ["rose-pine"] = {
          "#eb6f92", -- Red
          "#f6c177", -- Yellow
          "#9ccfd8", -- Blue
          "#ea9a97", -- Orange
          "#3e8fb0", -- Green
          "#c4a7e7", -- Purple
          "#31748f", -- Teal
        },
        ["solarized-osaka"] = {
          "#f7768e", -- Red
          "#e0af68", -- Yellow
          "#7aa2f7", -- Blue
          "#ff9e64", -- Orange
          "#9ece6a", -- Green
          "#bb9af7", -- Purple
          "#73daca", -- Aqua
        },
      }

      local function set_rainbow_colors()
        -- Select color palette based on current theme
        local colorscheme = vim.g.colors_name or "gruvbox"
        local palette = colors[colorscheme] or colors["gruvbox"]

        -- Directly set highlight groups - not just returning them
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
          lua = "rainbow-blocks",
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

  -- Enhanced indent guides
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
          show_start = true,
          show_end = true,
          injected_languages = true,
          priority = 500, -- Higher than rainbow delimiters
          highlight = {
            "RainbowDelimiter1",
            "RainbowDelimiter2",
            "RainbowDelimiter3",
            "RainbowDelimiter4",
            "RainbowDelimiter5",
            "RainbowDelimiter6",
            "RainbowDelimiter7",
          },
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
      -- Safe loading of ibl
      local ok, ibl = pcall(require, "ibl")
      if not ok then
        vim.notify("Failed to load indent-blankline.nvim", vim.log.levels.ERROR)
        return
      end

      -- Make sure rainbow delimiters highlights exist before configuring ibl
      local function ensure_rainbow_highlights()
        local colors = _G.get_ui_colors()

        -- Directly set highlight groups before ibl uses them
        for i, color in ipairs(colors) do
          local hl_group = "RainbowDelimiter" .. i
          vim.api.nvim_set_hl(0, hl_group, { fg = color })
        end
      end

      -- Call this before setting up ibl
      ensure_rainbow_highlights()

      -- Setup with options
      ibl.setup(opts)

      -- Handle colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Update scope highlights
          -- Define the get_highlight_value function within this callback too
          local function get_highlight_value(name)
            local hl = vim.api.nvim_get_hl(0, { name = name })
            local fg = hl.fg
            return fg and string.format("#%06x", fg) or nil
          end

          local scope_hl = get_highlight_value("Function") or get_highlight_value("Label")
          if scope_hl then
            vim.api.nvim_set_hl(0, "IblScope", { fg = scope_hl, bold = true })
          end

          -- Ensure rainbow highlights still exist
          ensure_rainbow_highlights()

          -- Reload ibl to apply highlight changes
          ibl.setup(opts)
        end,
      })

      -- Special configuration for Go files with slightly different indentation
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go", "templ" },
        callback = function()
          -- Load current config safely
          local config_ok, config = pcall(require, "ibl.config")
          if not config_ok then
            return
          end

          local buf_config = config.get_config(0)
          if buf_config then
            -- Adjust settings for Go/Templ files
            buf_config.indent.tab_char = "┊"
            -- Apply updated config safely
            pcall(ibl.setup_buffer, 0, buf_config)
          end
        end,
      })
    end,
  },
}
