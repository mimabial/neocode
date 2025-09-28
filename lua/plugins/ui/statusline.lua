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
        error = "",
        warn = "",
        info = "",
        hint = "",
      },
      diff = {
        added = "",
        modified = "",
        removed = "",
      },
      file = {
        modified = "",
      },
      ai = {
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

    local custom_theme = {
      normal = {
        a = { bg = colors.bg, fg = colors.green, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
        x = { bg = colors.bg, fg = colors.fg },
        y = { bg = colors.bg, fg = colors.fg },
        z = { bg = colors.bg, fg = colors.fg },
      },
      insert = {
        a = { bg = colors.bg, fg = colors.blue, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
        x = { bg = colors.bg, fg = colors.fg },
        y = { bg = colors.bg, fg = colors.fg },
        z = { bg = colors.bg, fg = colors.fg },
      },
      visual = {
        a = { bg = colors.bg, fg = colors.purple, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
        x = { bg = colors.bg, fg = colors.fg },
        y = { bg = colors.bg, fg = colors.fg },
        z = { bg = colors.bg, fg = colors.fg },
      },
      command = {
        a = { bg = colors.bg, fg = colors.orange, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
        x = { bg = colors.bg, fg = colors.fg },
        y = { bg = colors.bg, fg = colors.fg },
        z = { bg = colors.bg, fg = colors.fg },
      },
      terminal = {
        a = { bg = colors.bg, fg = colors.green, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
        x = { bg = colors.bg, fg = colors.fg },
        y = { bg = colors.bg, fg = colors.fg },
        z = { bg = colors.bg, fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.bg, fg = colors.gray },
        b = { bg = colors.bg, fg = colors.gray },
        c = { bg = colors.bg, fg = colors.gray },
        x = { bg = colors.bg, fg = colors.gray },
        y = { bg = colors.bg, fg = colors.gray },
        z = { bg = colors.bg, fg = colors.gray },
      },
    }

    local function pretty_path()
      return {
        function()
          local path = vim.fn.expand("%:p:~:.")
          local filename = vim.fn.expand("%:t")
          -- local extension = vim.fn.expand("%:e")
          -- local icon = require("nvim-web-devicons").get_icon(filename, extension)
          -- if vim.fn.winwidth(0) > 90 then
          --   return (icon and icon .. " " or "") .. path
          -- else
          --   return (icon and icon .. " " or "") .. filename
          -- end
          if vim.fn.winwidth(0) > 90 then
            return path
          else
            return filename
          end
        end,
        color = { bg = colors.bg },
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
        color = { fg = colors.yellow, bg = colors.bg },
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

          return "" .. names_str
        end,
        color = { fg = colors.blue, bg = colors.bg },
      }
    end

    local function ai_indicators()
      return {
        function()
          -- Check if Codeium is loaded
          if package.loaded["codeium"] then
            return "codeuim" -- Windsurf icon
          end
          return ""
        end,
        color = { fg = colors.purple, bg = colors.bg }, -- Windsurf green
      }
    end

    local function file_size()
      return {
        function()
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
        end,
        color = { bg = colors.bg },
      }
    end

    local function file_encoding()
      return {
        "encoding",
        fmt = string.upper,
        color = { fg = colors.green, bg = colors.bg },
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
        color = { fg = colors.green, bg = colors.bg },
        cond = function()
          return vim.bo.fileformat ~= "unix"
        end,
      }
    end

    return {
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        theme = custom_theme,
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = {
          statusline = { "oil", "Trouble", "lazy", "NvimTree" },
          winbar = { "oil", "Trouble", "lazy", "NvimTree" },
        },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            color = function()
              local m = vim.api.nvim_get_mode().mode
              return { fg = mode_color[m] or colors.blue, bg = colors.bg, gui = "bold" }
            end,
            padding = { left = 1, right = 1 },
          },
          -- lazy updates
          {
            function()
              local lazy_status = require("lazy.status")
              return lazy_status.has_updates() and lazy_status.updates() or ""
            end,
            cond = function()
              return package.loaded["lazy.status"] and require("lazy.status").has_updates()
            end,
            color = function()
              return { fg = colors.fg, bg = colors.bg }
            end,
          },
        },
        lualine_b = {
          {
            "branch",
            icon = "",
            color = { fg = colors.orange, bg = colors.bg },
          },
          {
            "diff",
            symbols = {
              added = icons.diff.add,
              modified = icons.diff.modified,
              removed = icons.diff.remove,
            },
            diff_color = {
              added = { fg = colors.green, bg = colors.bg },
              modified = { fg = colors.orange, bg = colors.bg },
              removed = { fg = colors.red, bg = colors.bg },
            },
          },
        },
        lualine_c = {
          root_dir(),
          pretty_path(),
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.error,
              warn = icons.diagnostics.warn,
              info = icons.diagnostics.info,
              hint = icons.diagnostics.hint,
            },
            colored = true,
            color = { bg = colors.bg },
          },
        },
        lualine_x = {
          file_size(),
          file_encoding(),
          file_format(),
          -- noice command status
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
          -- noice mode status
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
          -- dap status
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
        lualine_y = {
          ai_indicators(),
          lsp_status(),

          { "progress", color = { fg = colors.fg, bg = colors.bg } }

        },
        lualine_z = {
          { "location", color = { fg = colors.fg, bg = colors.bg } }
        },
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
    require("lualine").setup(opts)

    local function rebuild_lualine()
      -- Rebuild the config with new colors
      local new_opts = require("plugins.ui.statusline").opts()
      require("lualine").setup(new_opts)
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.schedule(rebuild_lualine)
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
