return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  priority = 75, -- After icons (100) and Git (60)
  dependencies = {
    {
      "nvim-tree/nvim-web-devicons",
      priority = 100,
    },
    {
      "lewis6991/gitsigns.nvim",
      priority = 60,
    },
  },
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = " "
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    -- Define icons for different parts of the statusline
    local icons = {
      diagnostics = {
        Error = " ",
        Warn = " ",
        Info = " ",
        Hint = " ",
      },
      git = {
        added = "+",
        modified = "~",
        removed = "-",
      },
      diff = {
        add = " ",
        modified = " ",
        remove = " ",
      },
      stack = {
        goth = "󰟓",
        nextjs = "󰟔",
      },
    }

    -- Function to get project root directory
    local function root_dir()
      return {
        function()
          local root = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
          if vim.fn.strwidth(root) > 40 then
            root = vim.fn.pathshorten(root)
          end
          return "󰉋 " .. root
        end,
        cond = function()
          return not vim.b.no_root_dir
        end,
      }
    end

    -- Function to get pretty file path
    local function pretty_path()
      return {
        function()
          local path = vim.fn.expand("%:p")
          if path == "" then
            return ""
          end
          local filename = vim.fn.expand("%:t")
          local relative_path = vim.fn.fnamemodify(path, ":~:.:h")
          if relative_path == "." then
            return filename
          end
          return relative_path .. "/" .. filename
        end,
      }
    end

    -- Function to get color for specific highlight groups
    local function get_highlight_color(name)
      local hl = vim.api.nvim_get_hl(0, { name = name })
      return hl and hl.fg and string.format("#%06x", hl.fg) or "NONE"
    end

    -- Stack badge component
    local function stack_badge()
      local current_stack = vim.g.current_stack or ""
      if current_stack == "goth" then
        return icons.stack.goth .. " GOTH"
      elseif current_stack == "nextjs" then
        return icons.stack.nextjs .. " NEXT"
      end
      return ""
    end

    -- LSP status component
    local function lsp_server()
      local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
      if #buf_clients == 0 then
        return ""
      end

      -- Filter out clients like copilot that don't need to be displayed
      local client_names = {}
      for _, client in pairs(buf_clients) do
        if client.name ~= "copilot" and client.name ~= "null-ls" then
          table.insert(client_names, client.name)
        end
      end

      return next(client_names) and " " .. table.concat(client_names, ", ") or ""
    end

    -- File size function
    local function file_size()
      local function format_file_size(size)
        local units = { "B", "K", "M", "G" }
        local unit_index = 1
        while size > 1024 and unit_index < #units do
          size = size / 1024
          unit_index = unit_index + 1
        end
        return string.format("%.1f%s", size, units[unit_index])
      end

      local file = vim.fn.expand("%:p")
      if string.len(file) == 0 or vim.bo.buftype ~= "" then
        return ""
      end
      local size = vim.fn.getfsize(file)
      if size <= 0 then
        return ""
      end
      return format_file_size(size)
    end

    -- Search count for statusline
    local function search_count()
      if not package.loaded["hlslens"] or vim.g.hlslens_disabled then
        return ""
      end

      local lens = require("hlslens").get_lens_info_fpath()
      if not lens or lens.total_matches == 0 then
        return ""
      end

      return string.format("[%d/%d]", lens.nearest_idx, lens.total_matches)
    end

    return {
      options = {
        theme = "gruvbox-material",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = {
          statusline = { "dashboard", "alpha", "starter", "neo-tree", "lazy", "oil" },
          winbar = { "dashboard", "alpha", "starter", "neo-tree", "lazy", "oil" },
        },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        refresh = {
          statusline = 500,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = {
          { "mode", separator = { left = "", right = "" }, right_padding = 2 },
        },
        lualine_b = {
          { "branch", icon = "" },
          {
            "diff",
            symbols = {
              added = icons.diff.add,
              modified = icons.diff.modified,
              removed = icons.diff.remove,
            },
            diff_color = {
              added = { fg = get_highlight_color("GitSignsAdd") },
              modified = { fg = get_highlight_color("GitSignsChange") },
              removed = { fg = get_highlight_color("GitSignsDelete") },
            },
          },
        },
        lualine_c = {
          root_dir(),
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
            colored = true,
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          pretty_path(),
          { stack_badge, color = { fg = "#a89984", gui = "bold" } },
        },
        lualine_x = {
          -- Noice command and mode status
          {
            function()
              return require("noice").api.status.command.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.command.has()
            end,
            color = function()
              return { fg = get_highlight_color("Statement") }
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
              return { fg = get_highlight_color("Constant") }
            end,
          },
          -- DAP status
          {
            function()
              return "  " .. require("dap").status()
            end,
            cond = function()
              return package.loaded["dap"] and require("dap").status() ~= ""
            end,
            color = function()
              return { fg = get_highlight_color("Debug") }
            end,
          },
          -- Lazy updates
          {
            function()
              local lazy_status = require("lazy.status")
              return lazy_status.has_updates() and lazy_status.updates() or ""
            end,
            cond = function()
              return package.loaded["lazy.status"] and require("lazy.status").has_updates()
            end,
            color = function()
              return { fg = get_highlight_color("Special") }
            end,
          },
          -- LSP server
          { lsp_server, icon = " LSP:", color = { fg = "#7daea3" } },
          -- Search count
          { search_count, icon = "󰍉" },
          -- File size
          { file_size },
          -- Encoding & Format
          {
            "encoding",
            cond = function()
              return vim.bo.fileencoding ~= "utf-8"
            end,
          },
          {
            "fileformat",
            icons_enabled = true,
            symbols = {
              unix = "LF",
              dos = "CRLF",
              mac = "CR",
            },
            cond = function()
              return vim.bo.fileformat ~= "unix"
            end,
          },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          {
            function()
              return " " .. os.date("%H:%M")
            end,
            separator = { left = "", right = "" },
            left_padding = 2,
          },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { "neo-tree", "lazy", "trouble", "toggleterm", "quickfix", "oil" },
    }
  end,
  config = function(_, opts)
    require("lualine").setup(opts)

    -- Set up special filetype handlers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "neo-tree", "alpha", "dashboard", "starter", "lazy", "mason", "oil" },
      callback = function()
        vim.opt_local.statusline = nil
      end,
    })

    -- Make sure lualine reloads when colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        -- Try to apply colorscheme specifically
        local theme = vim.g.colors_name
        if theme == "gruvbox-material" or theme == "tokyonight" then
          require("lualine").setup({
            options = {
              theme = theme,
              -- Keep other options the same
              globalstatus = vim.o.laststatus == 3,
              disabled_filetypes = opts.options.disabled_filetypes,
              component_separators = opts.options.component_separators,
              section_separators = opts.options.section_separators,
            },
          })
        else
          -- Reload with auto theme
          require("lualine").setup(opts)
        end
      end,
    })
  end,
}
