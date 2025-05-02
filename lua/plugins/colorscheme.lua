return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      -- Configure gruvbox-material
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_foreground = "material"
      vim.g.gruvbox_material_ui_contrast = "high"
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_transparent_background = 0
      vim.g.gruvbox_material_sign_column_background = "none"
      vim.g.gruvbox_material_diagnostic_text_highlight = 1
      vim.g.gruvbox_material_diagnostic_line_highlight = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
      vim.g.gruvbox_material_current_word = "bold"
      vim.g.gruvbox_material_disable_italic_comment = 0

      vim.g.gruvbox_material_colors_override = {
        bg0 = { "#282828", "235" },
        bg1 = { "#32302f", "236" },
        bg2 = { "#32302f", "236" },
        bg3 = { "#45403d", "237" },
        bg4 = { "#45403d", "237" },
        bg5 = { "#5a524c", "239" },
        bg_visual = { "#503946", "52" },
        bg_red = { "#4e3e43", "52" },
        bg_green = { "#404d44", "22" },
        bg_blue = { "#394f5a", "17" },
        bg_yellow = { "#4a4940", "136" },
      }

      -- Apply colorscheme and export palette
      vim.cmd("colorscheme gruvbox-material")
      _G.get_gruvbox_colors = function()
        return {
          bg = "#282828",
          bg1 = "#32302f",
          bg2 = "#32302f",
          bg3 = "#45403d",
          bg4 = "#45403d",
          bg5 = "#5a524c",
          red = "#ea6962",
          orange = "#e78a4e",
          yellow = "#d8a657",
          green = "#89b482",
          aqua = "#7daea3",
          blue = "#7daea3",
          purple = "#d3869b",
          grey = "#928374",
          grey_dim = "#7c6f64",
        }
      end

      -- Highlight overrides table
      local hl_overrides = {
        LineNr = { fg = "#a89984" },
        Visual = { bg = "#504945", bold = true },
        MatchParen = { fg = "#fabd2f", bg = "#504945", bold = true },
        Comment = { fg = "#928374", italic = true },
        FloatBorder = { fg = "#7c6f64" },
        NormalFloat = { bg = "#282828" },
        WhichKey = { fg = "#d8a657", bold = true },
        WhichKeyGroup = { fg = "#ea6962" },
        WhichKeySeparator = { fg = "#928374" },
        WhichKeyDesc = { fg = "#89b482" },
        TreesitterContext = { bg = "#32302f" },
        TreesitterContextLineNumber = { fg = "#a89984", bg = "#32302f" },
        TelescopePromptBorder = { fg = "#a89984" },
        TelescopeResultsBorder = { fg = "#a89984" },
        TelescopePreviewBorder = { fg = "#a89984" },
        TelescopeSelection = { bg = "#3c3836", fg = "#d8a657" },
        TelescopeMatching = { fg = "#89b482", bold = true },
        NeoTreeDirectoryName = { fg = "#a89984", bold = true },
        NeoTreeDirectoryIcon = { fg = "#7daea3" },
        htmlTag = { fg = "#7daea3", bold = true },
        htmlEndTag = { fg = "#7daea3", bold = true },
        htmlArg = { fg = "#d8a657", italic = true },
        htmlTagName = { fg = "#ea6962" },
        ["@attribute.htmx"] = { fg = "#89b482", italic = true, bold = true },
        ["@tag.attribute.htmx"] = { fg = "#89b482", italic = true, bold = true },
        ["@type.go"] = { fg = "#89b482" },
        ["@function.go"] = { fg = "#7daea3" },
        ["@variable.go"] = { fg = "#d3869b" },
        ["@tag.jsx"] = { fg = "#ea6962" },
        ["@tag.tsx"] = { fg = "#ea6962" },
        ["@constructor.jsx"] = { fg = "#7daea3" },
        ["@constructor.tsx"] = { fg = "#7daea3" },
        StatusLine = { bg = "#3c3836", fg = "#d4be98" },
        StatusLineNC = { bg = "#32302f", fg = "#a89984" },
      }

      local function update_highlights()
        for group, opts in pairs(hl_overrides) do
          vim.api.nvim_set_hl(0, group, opts)
        end
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "gruvbox-material",
        callback = update_highlights,
      })
      update_highlights()

      -- Filetype detection for .templ
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.templ",
        callback = function()
          vim.bo.filetype = "templ"
        end,
      })

      -- HTMX attribute syntax
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "html", "templ" },
        callback = function()
          vim.cmd([[syntax match htmlArg contained "\<hx-[a-zA-Z\-]\+\>" ]])
          vim.cmd([[highlight link htmlArg @attribute.htmx]])
        end,
      })
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 900,
    opts = {
      style = "storm",
      light_style = "day",
      transparent = false,
      terminal_colors = true,
      styles = { comments = { italic = true }, keywords = { italic = true } },
      sidebars = { "qf", "help", "terminal", "packer", "neo-tree", "trouble" },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = false,
      on_colors = function(colors)
        colors.comment = "#9ca0a4"
        colors.fg_gutter = "#4a5057"
      end,
      on_highlights = function(highlights, colors)
        -- UI and syntax overrides
        local override = {
          LineNr = { fg = colors.fg_gutter },
          CursorLineNr = { fg = colors.orange },
          TermCursor = { fg = colors.bg, bg = colors.green },
          ["@attribute.htmx"] = { fg = colors.green, italic = true, bold = true },
          ["@tag.attribute.htmx"] = { fg = colors.green, italic = true, bold = true },
          ["@type.go"] = { fg = colors.blue },
          ["@function.go"] = { fg = colors.cyan },
          ["@tag.jsx"] = { fg = colors.red },
          ["@tag.tsx"] = { fg = colors.red },
          ["@constructor.jsx"] = { fg = colors.blue },
          ["@constructor.tsx"] = { fg = colors.blue },
          NeoTreeDirectoryName = { fg = colors.fg_dark, bold = true },
          NeoTreeDirectoryIcon = { fg = colors.blue },
          NeoTreeNormal = { bg = colors.bg_dark },
          NeoTreeIndentMarker = { fg = colors.fg_gutter },
          TelescopePromptBorder = { fg = colors.blue },
          TelescopeResultsBorder = { fg = colors.blue },
          TelescopePreviewBorder = { fg = colors.blue },
          TelescopeSelection = { bg = colors.bg_highlight, fg = colors.fg },
          TelescopeMatching = { fg = colors.cyan, bold = true },
        }
        for group, opts in pairs(override) do
          highlights[group] = opts
        end
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
    end,
  },

  {
    "nvim-lua/plenary.nvim",
    lazy = true,
    priority = 100,
    config = function()
      -- Theme toggle commands
      vim.api.nvim_create_user_command("ColorSchemeToggle", function()
        local current = vim.g.colors_name
        if current == "gruvbox-material" then
          vim.cmd("colorscheme tokyonight")
          vim.notify("Switched to TokyoNight theme", vim.log.levels.INFO)
        else
          vim.cmd("colorscheme gruvbox-material")
          vim.notify("Switched to Gruvbox Material theme", vim.log.levels.INFO)
        end
      end, { desc = "Toggle between Gruvbox Material and TokyoNight" })

      vim.api.nvim_create_user_command("ToggleTransparency", function()
        if vim.g.colors_name == "gruvbox-material" then
          vim.g.gruvbox_material_transparent_background = vim.g.gruvbox_material_transparent_background == 1 and 0 or 1
          vim.cmd("colorscheme gruvbox-material")
          vim.notify(
            "Transparency "
              .. (vim.g.gruvbox_material_transparent_background == 1 and "enabled" or "disabled")
              .. " for Gruvbox Material",
            vim.log.levels.INFO
          )
        else
          local tn = require("tokyonight")
          tn.setup(vim.tbl_extend("force", tn.options, { transparent = not tn.options.transparent }))
          vim.cmd("colorscheme tokyonight")
          vim.notify(
            "Transparency "
              .. (require("tokyonight").options.transparent and "enabled" or "disabled")
              .. " for TokyoNight",
            vim.log.levels.INFO
          )
        end
      end, { desc = "Toggle background transparency" })

      -- Keymaps
      vim.keymap.set("n", "<leader>ut", "<cmd>ColorSchemeToggle<cr>", { desc = "Toggle Colorscheme" })
      vim.keymap.set("n", "<leader>uT", "<cmd>ToggleTransparency<cr>", { desc = "Toggle Transparency" })
    end,
  },
}
