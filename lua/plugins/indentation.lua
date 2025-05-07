-- lua/plugins/indentation.lua
-- Enhanced integration of rainbow delimiters with indent blankline

return {
  -- Rainbow delimiters for matching pairs
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      -- Get colors from the unified theme system
      local colors = _G.get_ui_colors and _G.get_ui_colors()
        or {
          red = "#ea6962",
          yellow = "#d8a657",
          blue = "#7daea3",
          orange = "#e78a4e",
          green = "#89b482",
          purple = "#d3869b",
          aqua = "#7daea3",
        }

      -- Create a palette from the unified colors
      local palette = {
        colors.red,
        colors.yellow,
        colors.blue,
        colors.orange,
        colors.green,
        colors.purple,
        colors.aqua,
      }

      -- Set highlight groups
      for i, color in ipairs(palette) do
        local hl_group = "RainbowDelimiter" .. i
        vim.api.nvim_set_hl(0, hl_group, { fg = color })
      end

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
        callback = function()
          local theme_colors = _G.get_ui_colors and _G.get_ui_colors() or {}

          -- Create a proper ordered palette from the named colors
          local palette = {
            theme_colors.red or "#ea6962",
            theme_colors.yellow or "#d8a657",
            theme_colors.blue or "#7daea3",
            theme_colors.orange or "#e78a4e",
            theme_colors.green or "#89b482",
            theme_colors.purple or "#d3869b",
            theme_colors.aqua or "#7daea3",
          }

          -- Update highlight groups
          for i, color in ipairs(palette) do
            local hl_group = "RainbowDelimiter" .. i
            vim.api.nvim_set_hl(0, hl_group, { fg = color })
          end
        end,
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
      -- Local function to get highlight colors - this fixes the error
      local function get_highlight_value(name)
        local hl = vim.api.nvim_get_hl(0, { name = name })
        local fg = hl.fg
        return fg and string.format("#%06x", fg) or nil
      end

      -- Default indent character
      local indent_char = "│"

      return {
        indent = {
          char = indent_char,
          tab_char = indent_char,
          highlight = {
            "RainbowDelimiter1",
            "RainbowDelimiter2",
            "RainbowDelimiter3",
            "RainbowDelimiter4",
            "RainbowDelimiter5",
            "RainbowDelimiter6",
          },
          smart_indent_cap = true,
          priority = 100, -- lower than rainbow delimiters
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
          injected_languages = true,
          priority = 500, -- Higher than rainbow delimiters
          highlight = { "Function", "Label" },
          char = indent_char,
        },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
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
        local theme_colors = _G.get_ui_colors and _G.get_ui_colors() or {}

        -- Create a proper ordered palette from the named colors
        local palette = {
          theme_colors.red or "#ea6962",
          theme_colors.yellow or "#d8a657",
          theme_colors.blue or "#7daea3",
          theme_colors.orange or "#e78a4e",
          theme_colors.green or "#89b482",
          theme_colors.purple or "#d3869b",
          theme_colors.aqua or "#7daea3",
        }

        -- Set highlight groups
        for i, color in ipairs(palette) do
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

          -- Add safe check before using ipairs on palette
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
