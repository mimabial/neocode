return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
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
      kinds = {
        Array = " ",
        Boolean = " ",
        Class = " ",
        Color = " ",
        Constant = " ",
        Constructor = " ",
        Enum = " ",
        EnumMember = " ",
        Event = " ",
        Field = " ",
        File = " ",
        Folder = " ",
        Function = " ",
        Interface = " ",
        Key = " ",
        Keyword = " ",
        Method = " ",
        Module = " ",
        Namespace = " ",
        Null = "ﳠ ",
        Number = " ",
        Object = " ",
        Operator = " ",
        Package = " ",
        Property = " ",
        Reference = " ",
        Snippet = " ",
        String = " ",
        Struct = " ",
        Text = " ",
        TypeParameter = " ",
        Unit = " ",
        Value = " ",
        Variable = " ",
      },
    }

    vim.o.laststatus = vim.g.lualine_laststatus

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

    -- Stack badge
    local function stack_badge()
      local current_stack = vim.g.current_stack or ""
      if current_stack == "goth" then
        return "󰟓 GOTH"
      elseif current_stack == "nextjs" then
        return "󰟔 NEXT"
      end
      return ""
    end
    
    -- LSP status component
    local function lsp_server()
      local buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
      if #buf_clients == 0 then
        return ""
      end
      
      local buf_client_names = {}
      for _, client in pairs(buf_clients) do
        table.insert(buf_client_names, client.name)
      end
      
      return " " .. table.concat(buf_client_names, ", ")
    end

    local opts = {
      options = {
        theme = "gruvbox-material",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "neo-tree", "lazy" } },
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' }, 
      },
      sections = {
        lualine_a = { 
          { "mode", separator = { left = '', right = '' }, right_padding = 2 } 
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
          }
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
          -- noice command status
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
          -- noice mode status
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
          -- dap status
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
              return { fg = get_highlight_color("Special") }
            end,
          },
          { lsp_server, icon = " LSP:", color = { fg = "#7daea3" } },
          { "encoding" },
          { "fileformat", icons_enabled = true },
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
            separator = { left = '', right = '' },
            left_padding = 2
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
      extensions = { "neo-tree", "lazy", "trouble", "toggleterm", "quickfix" },
    }

    -- Add trouble.nvim integration if available
    if package.loaded["trouble"] then
      local trouble = require("trouble")
      local has_trouble_symbols = trouble.statusline ~= nil

      if has_trouble_symbols then
        local symbols = trouble.statusline({
          mode = "symbols",
          groups = {},
          title = false,
          filter = { range = true },
          format = "{kind_icon}{symbol.name:Normal}",
          hl_group = "lualine_c_normal",
        })

        if symbols and symbols.get and symbols.has then
          table.insert(opts.sections.lualine_c, {
            symbols.get,
            cond = function()
              return vim.b.trouble_lualine ~= false and symbols.has()
            end,
          })
        end
      end
    end

    return opts
  end,
}
