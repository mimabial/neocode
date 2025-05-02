-- lua/plugins/lualine.lua
-- Refactored lualine.nvim setup with cleaner utility integration
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  priority = 75,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
  },

  init = function()
    -- Preserve laststatus and hide until ready
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
  end,

  opts = function()
    local fn = vim.fn
    local utils = require("config.utils")
    local icons = {
      diagnostics = { Error = "", Warn = "", Info = "", Hint = "" },
      git = { added = "+", modified = "~", removed = "-" },
      stack = { goth = "󰟓 GOTH", nextjs = "󰟔 NEXT" },
    }

    local function root_dir()
      return {
        function()
          local cwd = vim.fn.getcwd()
          local disp = cwd:sub(1, #vim.env.HOME) == vim.env.HOME and "~" .. cwd:sub(#vim.env.HOME + 1) or cwd
          return "󰉋 " .. (disp:gsub(fn.pathshorten(disp)))
        end,
        cond = function()
          return not vim.b.no_root_dir
        end,
        color = { fg = utils.get_hl_color("Directory", "fg", "#abb2bf"), bold = true },
      }
    end

    local function pretty_path()
      return {
        function()
          local f = vim.fn.expand("%:p:~:.")
          return vim.fn.fnamemodify(f, ":~:.:%:h") == "." and vim.fn.expand("%:t") or f
        end,
        cond = function()
          return vim.fn.expand("%:t") ~= ""
        end,
      }
    end

    local function stack_badge()
      return {
        function()
          return icons.stack[vim.g.current_stack] or ""
        end,
        color = { fg = utils.get_hl_color("Identifier", "fg", "#d19a66"), bold = true },
      }
    end

    local function lsp_servers()
      return {
        function()
          local names = {}
          for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
            if c.name ~= "copilot" and c.name ~= "null-ls" then
              table.insert(names, c.name)
            end
          end
          return names[1] and table.concat(names, ", ") or ""
        end,
        icon = " ",
        cond = function()
          return #vim.lsp.get_clients({ bufnr = 0 }) > 0
        end,
      }
    end

    local function file_size()
      local f = vim.fn.expand("%:p")
      if f == "" or vim.bo.buftype ~= "" then
        return ""
      end
      local size = vim.fn.getfsize(f)
      if size <= 0 then
        return ""
      end
      local units = { "B", "K", "M", "G" }
      local idx = 1
      while size > 1024 and idx < #units do
        size = size / 1024
        idx = idx + 1
      end
      return string.format("%.1f%s", size, units[idx])
    end

    local function search_count()
      if not pcall(require, "hlslens") or vim.g.hlslens_disabled then
        return ""
      end
      local info = require("hlslens").get_lens_info_fpath()
      return info and info.total_matches > 0 and string.format("[%d/%d]", info.nearest_idx, info.total_matches) or ""
    end

    return {
      options = {
        theme = "gruvbox-material",
        globalstatus = vim.o.laststatus == 3,
        component_separators = "",
        section_separators = "",
        disabled_filetypes = { statusline = { "alpha", "dashboard", "neo-tree", "oil" } },
      },
      sections = {
        lualine_a = { { "mode", right_padding = 2 } },
        lualine_b = { { "branch" }, { "diff", symbols = icons.git } },
        lualine_c = { root_dir(), { "diagnostics", symbols = icons.diagnostics }, pretty_path(), stack_badge() },
        lualine_x = { lsp_servers(), file_size(), search_count() },
        lualine_y = { { "filename", path = 1 } },
        lualine_z = { { "location" }, { "%H:%M" } },
      },
      inactive_sections = {
        lualine_c = { "filename" },
        lualine_x = { "location" },
      },
      extensions = { "neo-tree", "lazy", "trouble", "toggleterm", "quickfix", "oil" },
    }
  end,

  config = function(_, opts)
    require("lualine").setup(opts)
    -- restore statusline on colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        require("lualine").refresh()
      end,
    })
  end,
}
