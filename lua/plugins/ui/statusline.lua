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
    local colors = _G.get_ui_colors()

    local icons = {
      diagnostics = {
        Error = " ",
        Warn = " ",
        Info = " ",
        Hint = " ",
      },
      git = {
        added = "",
        modified = "",
        removed = "",
      },
      file = {
        modified = "",
      },
      ai = {
        copilot = "",
        codeium = "󰚩",
      },
    }

    local mode_color = {
      n = colors.green,
      i = colors.blue,
      v = colors.purple,
      c = colors.orange,
      no = colors.red,
      s = colors.yellow,
      t = colors.green,
    }

    local function pretty_path()
      return {
        function()
          local path = vim.fn.expand("%:p:~:.")
          local filename = vim.fn.expand("%:t")
          local extension = vim.fn.expand("%:e")
          local icon = require("nvim-web-devicons").get_icon(filename, extension)

          if vim.fn.winwidth(0) > 90 then
            return (icon and icon .. " " or "") .. path
          else
            return (icon and icon .. " " or "") .. filename
          end
        end,
        cond = function()
          return vim.fn.expand("%:t") ~= ""
        end,
      }
    end

    local function root_dir()
      return {
        function()
          local cwd = vim.fn.getcwd()
          local home = os.getenv("HOME") or ""
          local disp = cwd:sub(1, #home) == home and "~" .. cwd:sub(#home + 1) or cwd
          return "" .. vim.fn.fnamemodify(disp, ":t")
        end,
        color = { fg = colors.green },
        cond = function()
          return not vim.b.no_root_dir
        end,
      }
    end

    local function lsp_status()
      return {
        function()
          local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
          if #buf_clients == 0 then
            return "no lsp"
          end

          local lsp_names = {}
          for _, client in ipairs(buf_clients) do
            if not vim.tbl_contains({ "null-ls", "conform" }, client.name) then
              table.insert(lsp_names, client.name)
            end
          end

          local names_str = table.concat(lsp_names, ", ")
          if #names_str > 30 then
            names_str = string.sub(names_str, 1, 27) .. "..."
          end

          return " " .. names_str
        end,
        color = { fg = colors.green },
      }
    end

    local function ai_indicators()
      return {
        function()
          -- Simple check if Codeium is loaded
          if package.loaded["codeium"] then
            return "󰚩 " -- Windsurf icon
          end
          return ""
        end,
        color = { fg = "#09B6A2" }, -- Windsurf green
      }
    end

    local function file_size()
      return function()
        local f = vim.fn.expand("%:p")
        if f == "" or vim.bo.buftype ~= "" then return "" end
        local size = vim.fn.getfsize(f)
        if size <= 0 then return "" end

        local units = { "B", "K", "M", "G" }
        local idx = 1
        while size > 1024 and idx < #units do
          size = size / 1024
          idx = idx + 1
        end
        return string.format("%.1f%s", size, units[idx])
      end
    end

    return {
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        theme = "auto",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = {
          statusline = { "neo-tree", "oil", "Trouble", "lazy", "NvimTree" },
          winbar = { "neo-tree", "oil", "Trouble", "lazy", "NvimTree" },
        },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            color = function()
              local m = vim.api.nvim_get_mode().mode
              return { bg = mode_color[m] or colors.blue, fg = colors.bg, gui = "bold" }
            end,
            padding = { left = 1, right = 1 },
          },
        },
        lualine_b = {
          {
            "branch",
            icon = "",
            color = { fg = colors.orange },
          },
          root_dir(),
        },
        lualine_c = {
          pretty_path(),
          file_size(),
        },
        lualine_x = {
          lsp_status(),
        },
        lualine_y = {
          ai_indicators(),
        },
        lualine_z = {
          { "location", color = { fg = colors.white, gui = "bold" } }
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { pretty_path() },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = {
        "neo-tree",
        "lazy",
        "trouble",
        "toggleterm",
        "quickfix",
        "oil",
        "nvim-dap-ui",
        "nvim-tree",
      },
    }
  end,

  config = function(_, opts)
    require("lualine").setup(opts)

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        require("lualine").refresh()
      end,
    })

    -- Set autocmd to restore user's laststatus when lualine unloads
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == "lualine.nvim" then
          vim.o.laststatus = vim.g.lualine_laststatus or 2
        end
      end,
    })
  end,
}
