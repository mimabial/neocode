-- lua/plugins/indent-rainbow.lua
-- Enhanced integration of rainbow delimiters with indent blankline

return {
  -- Rainbow delimiters for matching pairs
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      -- Define default global strategy
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy.global,
          vim = rainbow_delimiters.strategy["local"],
          html = rainbow_delimiters.strategy.global,
          tsx = rainbow_delimiters.strategy.global,
          jsx = rainbow_delimiters.strategy.global,
          templ = rainbow_delimiters.strategy.global,
        },
        -- Set query sources by filetype
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
        -- Set highlight priority
        priority = {
          [""] = 110,
          lua = 210,
        },
        -- Highlight groups ordered by rainbow level
        highlight = function()
          local colors = {
            ["gruvbox-material"] = {
              "#ea6962", -- Red
              "#d8a657", -- Yellow
              "#7daea3", -- Blue
              "#e78a4e", -- Orange
              "#89b482", -- Green
              "#d3869b", -- Purple
              "#a9b665", -- Light green
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
            ["kanagawa"] = {
              "#c34043", -- Red
              "#dca561", -- Yellow
              "#7e9cd8", -- Blue
              "#ffa066", -- Orange
              "#76946a", -- Green
              "#957fb8", -- Purple
              "#6a9589", -- Teal
            },
          }

          -- Select color palette based on current theme
          local colorscheme = vim.g.colors_name or "gruvbox-material"
          local palette = colors[colorscheme] or colors["gruvbox-material"]

          -- Assign the highlight groups based on current palette
          local result = {}
          for i, color in ipairs(palette) do
            table.insert(result, "RainbowDelimiter" .. i)
            vim.api.nvim_set_hl(0, "RainbowDelimiter" .. i, { fg = color })
          end
          return result
        end,
      }

      -- Update highlights on colorscheme change
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Refresh highlights based on new scheme
          if vim.g.rainbow_delimiters and vim.g.rainbow_delimiters.highlight then
            vim.g.rainbow_delimiters.highlight = vim.g.rainbow_delimiters.highlight()
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
      -- Try to detect theme colors for better integration
      local function get_highlight_value(name)
        local hl = vim.api.nvim_get_hl(0, { name = name })
        local fg = hl.fg or hl.foreground
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

      -- Setup with options
      ibl.setup(opts)

      -- Handle colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Update scope highlights
          local scope_hl = get_highlight_value("Function") or get_highlight_value("Label")
          if scope_hl then
            vim.api.nvim_set_hl(0, "IblScope", { fg = scope_hl, bold = true })
          end

          -- Reload ibl to apply highlight changes
          ibl.setup(opts)
        end,
      })

      -- Special configuration for Go files with slightly different indentation
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go", "templ" },
        callback = function()
          -- Load current config
          local config = require("ibl.config").get_config(0)
          -- Adjust settings for Go/Templ files
          config.indent.tab_char = "┊"
          -- Apply updated config
          ibl.setup_buffer(0, config)
        end,
      })
    end,
  },
}
