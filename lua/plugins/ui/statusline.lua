return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  priority = 75,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
  },

  init = function()
    -- Hide statusline until lualine is ready; remember the user's laststatus
    -- so we can restore it on LazyLoad.
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
  end,

  opts = function()
    local colors = require("config.ui").get_colors()
    local bar_bg = require("lib.theme_manager").bar_bg(colors.bg)

    local mode_color = {
      n = colors.green,
      i = colors.blue,
      v = colors.purple,
      c = colors.orange,
      no = colors.red,
      s = colors.yellow,
      t = colors.green,
    }

    local custom_theme = {
      normal = {
        a = { bg = bar_bg, fg = colors.green, gui = "bold" },
        b = { bg = bar_bg, fg = colors.fg },
        c = { bg = bar_bg, fg = colors.fg },
        x = { bg = bar_bg, fg = colors.fg },
        y = { bg = bar_bg, fg = colors.fg },
        z = { bg = bar_bg, fg = colors.fg },
      },
      insert = {
        a = { bg = bar_bg, fg = colors.blue, gui = "bold" },
        b = { bg = bar_bg, fg = colors.fg },
        c = { bg = bar_bg, fg = colors.fg },
        x = { bg = bar_bg, fg = colors.fg },
        y = { bg = bar_bg, fg = colors.fg },
        z = { bg = bar_bg, fg = colors.fg },
      },
      visual = {
        a = { bg = bar_bg, fg = colors.purple, gui = "bold" },
        b = { bg = bar_bg, fg = colors.fg },
        c = { bg = bar_bg, fg = colors.fg },
        x = { bg = bar_bg, fg = colors.fg },
        y = { bg = bar_bg, fg = colors.fg },
        z = { bg = bar_bg, fg = colors.fg },
      },
      command = {
        a = { bg = bar_bg, fg = colors.orange, gui = "bold" },
        b = { bg = bar_bg, fg = colors.fg },
        c = { bg = bar_bg, fg = colors.fg },
        x = { bg = bar_bg, fg = colors.fg },
        y = { bg = bar_bg, fg = colors.fg },
        z = { bg = bar_bg, fg = colors.fg },
      },
      terminal = {
        a = { bg = bar_bg, fg = colors.green, gui = "bold" },
        b = { bg = bar_bg, fg = colors.fg },
        c = { bg = bar_bg, fg = colors.fg },
        x = { bg = bar_bg, fg = colors.fg },
        y = { bg = bar_bg, fg = colors.fg },
        z = { bg = bar_bg, fg = colors.fg },
      },
      inactive = {
        a = { bg = bar_bg, fg = colors.gray },
        b = { bg = bar_bg, fg = colors.gray },
        c = { bg = bar_bg, fg = colors.gray },
        x = { bg = bar_bg, fg = colors.gray },
        y = { bg = bar_bg, fg = colors.gray },
        z = { bg = bar_bg, fg = colors.gray },
      },
    }

    local function root_dir()
      return {
        function()
          local cwd = vim.fn.getcwd()
          local home = os.getenv("HOME") or ""
          local disp = cwd:sub(1, #home) == home and "~" .. cwd:sub(#home + 1) or cwd
          return "" .. vim.fn.fnamemodify(disp, ":t")
        end,
        color = { fg = colors.yellow, bg = bar_bg },
        cond = function()
          return not vim.b.no_root_dir
        end,
      }
    end

    local function lsp_status()
      return {
        function()
          local lsp_names = {}
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
            if client.name ~= "conform" and client.name ~= "copilot" then
              table.insert(lsp_names, client.name)
            end
          end
          if #lsp_names == 0 then
            return "no lsp"
          end

          local names_str = table.concat(lsp_names, ", ")
          if #names_str > 30 then
            names_str = string.sub(names_str, 1, 27) .. "..."
          end

          return "" .. names_str
        end,
        color = { fg = colors.blue, bg = bar_bg },
      }
    end

    local function ai_indicators()
      return {
        function()
          local copilot = package.loaded["copilot.client"]
          if not copilot then
            return ""
          end
          local status = package.loaded["copilot.status"].data.status
          return copilot.get() and (status == "Normal" or status == "InProgress") and "copilot" or "copilot!"
        end,
        color = { fg = colors.purple, bg = bar_bg },
      }
    end

    local function disk_size_label()
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

    local function file_size()
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufFilePost", "FileChangedShellPost" }, {
        group = vim.api.nvim_create_augroup("StatuslineDiskSize", { clear = true }),
        callback = function(event)
          vim.b[event.buf].statusline_disk_size = nil
        end,
      })
      return {
        function()
          local label = vim.b.statusline_disk_size
          if label == nil then
            label = disk_size_label()
            vim.b.statusline_disk_size = label
          end
          return label
        end,
        color = { bg = bar_bg },
      }
    end

    local function file_encoding()
      return {
        "encoding",
        fmt = string.upper,
        color = { fg = colors.green, bg = bar_bg },
        cond = function()
          return vim.bo.fileencoding ~= "utf-8"
        end,
      }
    end

    local function file_format()
      return {
        "fileformat",
        symbols = {
          unix = "",
          dos = "",
          mac = "",
        },
        color = { fg = colors.green, bg = bar_bg },
        cond = function()
          return vim.bo.fileformat ~= "unix"
        end,
      }
    end

    local function file_name()
      return {
        function()
          return vim.fn.expand("%:t:r")
        end,
        color = { bg = bar_bg },
        cond = function()
          return vim.fn.expand("%:t") ~= ""
        end,
      }
    end

    return {
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        theme = custom_theme,
        disabled_filetypes = {
          statusline = { "lazy", "NvimTree", "oil", "spectre-panel", "Trouble" },
          winbar = { "lazy", "NvimTree", "oil", "spectre-panel", "Trouble" },
        },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            color = function()
              local m = vim.api.nvim_get_mode().mode
              return { fg = mode_color[m] or colors.blue, bg = bar_bg, gui = "bold" }
            end,
            padding = { left = 1, right = 1 },
          },
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function()
              return { fg = colors.fg, bg = bar_bg }
            end,
          },
        },
        lualine_b = {
          {
            "branch",
            icon = "",
            color = { fg = colors.orange, bg = bar_bg },
          },
        },
        lualine_c = {
          root_dir(),
          file_name(),
        },
        lualine_x = {
          {
            "filetype",
            colored = true,
            icons_enabled = false,
            color = { fg = colors.fg, bg = bar_bg },
          },
          lsp_status(),
        },
        lualine_y = {
          file_size(),
          file_encoding(),
          file_format(),
          {
            function()
              return require("noice").api.status.command.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.command.has()
            end,
            color = function()
              return { fg = colors.fg }
            end,
          },
          {
            function()
              return require("noice").api.status.mode.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.mode.has()
            end,
            color = function()
              return { fg = colors.fg }
            end,
          },
          {
            function()
              return "  " .. require("dap").status()
            end,
            cond = function()
              return package.loaded["dap"] and require("dap").status() ~= ""
            end,
            color = function()
              return { fg = colors.fg }
            end,
          },
        },
        lualine_z = {
          ai_indicators(),
          { "progress", color = { fg = colors.fg, bg = bar_bg } },
          { "location", color = { fg = colors.fg, bg = bar_bg } },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      extensions = {
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
    local function setup_as_only_theme_reloader(lualine_opts)
      require("lualine").setup(lualine_opts)
      vim.api.nvim_clear_autocmds({ group = "lualine", event = { "ColorScheme", "OptionSet" } })
    end

    setup_as_only_theme_reloader(opts)

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.schedule(function()
          setup_as_only_theme_reloader(require("plugins.ui.statusline").opts())
        end)
      end,
    })

    -- Restore the user's laststatus if lualine ever unloads.
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
