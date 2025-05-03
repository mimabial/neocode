-- lua/plugins/mini-bufremove.lua
-- Smart buffer removal with safety features
return {
  {
    "echasnovski/mini.bufremove",
    -- Lazy load on key events
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      {
        "<leader>bD",
        function()
          require("mini.bufremove").delete(0, true)
        end,
        desc = "Delete Buffer (Force)",
      },
    },
    -- Safe minimal config
    opts = {},
  },

  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "echasnovski/mini.bufremove",
    },
    keys = {
      { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
      { "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
      { "<leader>bP", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle pin" },
      { "<leader>bC", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Close non-pinned buffers" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers to the right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffers to the left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineNext<cr>", desc = "Next buffer" },
      { "<A-1>", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Go to buffer 1" },
      { "<A-2>", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Go to buffer 2" },
      { "<A-3>", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Go to buffer 3" },
      { "<A-4>", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Go to buffer 4" },
      { "<A-5>", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Go to buffer 5" },
      { "<A-6>", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "Go to buffer 6" },
      { "<A-7>", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "Go to buffer 7" },
      { "<A-8>", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "Go to buffer 8" },
      { "<A-9>", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "Go to buffer 9" },
    },
    opts = function()
      -- Define icons for bufferline elements
      local icons = {
        error = " ",
        warning = " ",
        info = " ",
        hint = " ",
        diagnostic = "󰅲 ",
        terminal = "",
        modified = "●",
        directory = "󰉋 ",
        close = "󰅖",
        left_trunc_marker = "",
        right_trunc_marker = "",
        group_close = "",
        pinned = "車",
      }

      -- Get color palette based on current theme
      local function get_theme_colors()
        local colorscheme = vim.g.colors_name or "gruvbox-material"

        if colorscheme == "gruvbox-material" and _G.get_gruvbox_colors then
          return _G.get_gruvbox_colors()
        elseif colorscheme == "everforest" and _G.get_everforest_colors then
          return _G.get_everforest_colors()
        elseif colorscheme == "kanagawa" and _G.get_kanagawa_colors then
          return _G.get_kanagawa_colors()
        else
          -- Fallback colors
          return {
            bg = "#282828",
            bg1 = "#32302f",
            red = "#ea6962",
            green = "#a9b665",
            yellow = "#d8a657",
            blue = "#7daea3",
            magenta = "#d3869b",
            cyan = "#89b482",
            fg = "#d4be98",
            grey = "#928374",
          }
        end
      end

      -- Determine stack icon based on detected stack
      local function get_stack_icon()
        local stack = vim.g.current_stack or ""
        if stack == "goth" then
          return "󰟓 "
        elseif stack == "nextjs" then
          return " "
        elseif stack == "goth+nextjs" then
          return "󰡄 "
        else
          return ""
        end
      end

      -- Safe diagnostic count retrieval with error handling
      local function get_diagnostics_count(buf, severity)
        local ok, count = pcall(function()
          return #vim.diagnostic.get(buf, { severity = severity })
        end)
        return ok and count or 0
      end

      -- Check if a buffer is a real file
      local function is_file(bufnr)
        local ft = vim.bo[bufnr].filetype
        local excluded = {
          "oil",
          "neo-tree",
          "dashboard",
          "alpha",
          "starter",
          "dapui_scopes",
          "dapui_breakpoints",
          "dapui_watches",
          "dapui_stacks",
          "TelescopePrompt",
          "lazy",
          "mason",
          "qf",
          "terminal",
          "help",
        }
        if vim.tbl_contains(excluded, ft) then
          return false
        end
        return true
      end

      return {
        options = {
          close_command = function(n)
            local bd = require("mini.bufremove").delete
            if vim.bo[n].modified then
              local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname(n)), "&Yes\n&No\n&Cancel")
              if choice == 1 then -- Yes
                vim.cmd("buffer " .. n)
                vim.cmd.write()
                bd(n)
              elseif choice == 2 then -- No
                bd(n, true) -- Force delete
              end
            else
              bd(n)
            end
          end,
          right_mouse_command = function(n)
            require("mini.bufremove").delete(n, false)
          end,
          mode = "buffers",
          sort_by = "insert_after_current",
          always_show_bufferline = false,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = " "
            for severity, icon in pairs({
              error = icons.error,
              warning = icons.warning,
              info = icons.info,
              hint = icons.hint,
            }) do
              local n = diagnostics_dict[severity]
              if n and n > 0 then
                s = s .. icon .. n .. " "
              end
            end
            return s
          end,
          -- Configure offsets for file explorer and special filetypes
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              highlight = "Directory",
              separator = true,
              text_align = "left",
            },
            {
              filetype = "oil",
              text = "Directory",
              highlight = "Directory",
              separator = true,
              text_align = "left",
            },
          },
          separator_style = "thin",
          indicator = {
            icon = "▎",
            style = "icon",
          },
          -- Add stack indicator to the left of the bufferline
          custom_areas = {
            left = function()
              local stack_icon = get_stack_icon()
              if stack_icon ~= "" then
                return {
                  { text = stack_icon, guifg = get_theme_colors().green, guibg = get_theme_colors().bg },
                }
              end
              return {}
            end,
          },
          hover = {
            enabled = true,
            delay = 150,
            reveal = { "close" },
          },
        },
        highlights = (function()
          local colors = get_theme_colors()
          local hl = require("bufferline.highlights")
          local fill_bg = colors.bg
          local bg = colors.bg1
          local modified_bg = colors.bg1
          local selected_bg = colors.blue
          local visible_bg = colors.bg1
          local diagnostic_bg = colors.bg1
          local error_fg = colors.red
          local warning_fg = colors.yellow
          local info_fg = colors.blue
          local hint_fg = colors.green

          return {
            fill = { bg = fill_bg },
            background = { bg = bg },
            buffer_visible = { bg = visible_bg },
            buffer_selected = { bg = selected_bg, fg = colors.bg, bold = true },
            close_button = { bg = bg },
            close_button_visible = { bg = visible_bg },
            close_button_selected = { bg = selected_bg },
            diagnostic = { bg = diagnostic_bg },
            diagnostic_visible = { bg = visible_bg },
            diagnostic_selected = { bg = selected_bg },
            error = { bg = bg, fg = error_fg },
            error_visible = { bg = visible_bg, fg = error_fg },
            error_selected = { bg = selected_bg, fg = error_fg },
            error_diagnostic = { bg = diagnostic_bg, fg = error_fg },
            error_diagnostic_visible = { bg = visible_bg, fg = error_fg },
            error_diagnostic_selected = { bg = selected_bg, fg = error_fg },
            warning = { bg = bg, fg = warning_fg },
            warning_visible = { bg = visible_bg, fg = warning_fg },
            warning_selected = { bg = selected_bg, fg = warning_fg },
            warning_diagnostic = { bg = diagnostic_bg, fg = warning_fg },
            warning_diagnostic_visible = { bg = visible_bg, fg = warning_fg },
            warning_diagnostic_selected = { bg = selected_bg, fg = warning_fg },
            info = { bg = bg, fg = info_fg },
            info_visible = { bg = visible_bg, fg = info_fg },
            info_selected = { bg = selected_bg, fg = info_fg },
            info_diagnostic = { bg = diagnostic_bg, fg = info_fg },
            info_diagnostic_visible = { bg = visible_bg, fg = info_fg },
            info_diagnostic_selected = { bg = selected_bg, fg = info_fg },
            hint = { bg = bg, fg = hint_fg },
            hint_visible = { bg = visible_bg, fg = hint_fg },
            hint_selected = { bg = selected_bg, fg = hint_fg },
            hint_diagnostic = { bg = diagnostic_bg, fg = hint_fg },
            hint_diagnostic_visible = { bg = visible_bg, fg = hint_fg },
            hint_diagnostic_selected = { bg = selected_bg, fg = hint_fg },
            modified = { bg = modified_bg, fg = colors.orange },
            modified_visible = { bg = visible_bg, fg = colors.orange },
            modified_selected = { bg = selected_bg, fg = colors.yellow },
            duplicate = { bg = bg, fg = colors.grey, italic = true },
            duplicate_visible = { bg = visible_bg, fg = colors.grey, italic = true },
            duplicate_selected = { bg = selected_bg, fg = colors.fg, italic = true },
            separator = { bg = fill_bg, fg = fill_bg },
            separator_visible = { bg = visible_bg, fg = visible_bg },
            separator_selected = { bg = selected_bg, fg = selected_bg },
            indicator_selected = { bg = selected_bg, fg = selected_bg },
            pick = { bg = bg, fg = colors.green, bold = true },
            pick_visible = { bg = visible_bg, fg = colors.green, bold = true },
            pick_selected = { bg = selected_bg, fg = colors.green, bold = true },
          }
        end)(),
      }
    end,
    config = function(_, opts)
      -- Safe loading of bufferline
      local ok, bufferline = pcall(require, "bufferline")
      if not ok then
        vim.notify("Failed to load bufferline.nvim", vim.log.levels.ERROR)
        return
      end

      -- Setup bufferline with provided options
      bufferline.setup(opts)

      -- Update bufferline colors on colorscheme change
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Force a refresh of bufferline highlights after colorscheme change
          local ok, bufferline = pcall(require, "bufferline")
          if ok then
            bufferline.setup(opts)
          end
        end,
      })

      -- Hide bufferline for certain filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "^help$",
          "^startify$",
          "^dashboard$",
          "^packer$",
          "^neogitstatus$",
          "^NvimTree$",
          "^Trouble$",
          "^alpha$",
          "^lir$",
          "^neo-tree$",
          "^Outline$",
          "^oil$",
        },
        callback = function()
          vim.cmd("set showtabline=0")
        end,
      })

      -- Create user command to toggle bufferline
      vim.api.nvim_create_user_command("BufferLineToggle", function()
        if vim.o.showtabline == 0 then
          vim.o.showtabline = 2
          vim.notify("Bufferline enabled", vim.log.levels.INFO)
        else
          vim.o.showtabline = 0
          vim.notify("Bufferline disabled", vim.log.levels.INFO)
        end
      end, { desc = "Toggle bufferline visibility" })

      -- Add keymap to toggle bufferline
      vim.keymap.set("n", "<leader>bt", "<cmd>BufferLineToggle<cr>", { desc = "Toggle bufferline" })
    end,
  },
}
