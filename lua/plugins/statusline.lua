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
    local utils = require("utils.core")

    -- Check if transparency is enabled
    local function is_transparency_enabled()
      local cache_dir = vim.fn.stdpath("cache")
      local settings_file = cache_dir .. "/theme_settings.json"

      if vim.fn.filereadable(settings_file) == 0 then
        return false
      end

      local content = vim.fn.readfile(settings_file)
      if #content == 0 then
        return false
      end

      local ok, parsed = pcall(vim.fn.json_decode, table.concat(content, ""))
      return ok and parsed and parsed.transparency or false
    end

    -- Get dynamic colors from current theme
    local function get_theme_colors()
      -- Try to get colors from global theme functions
      if _G.get_ui_colors then
        return _G.get_ui_colors()
      end

      -- Fallback to extracting colors from highlight groups
      local function get_hl_color(group, attr, fallback)
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
        local val = ok and hl[attr]
        if not val then
          return fallback
        end
        if type(val) == "number" then
          return string.format("#%06x", val)
        end
        return tostring(val)
      end

      -- Extract theme colors dynamically
      local base_bg = get_hl_color("Normal", "bg", "#282828")
      return {
        bg = is_transparency_enabled() and "NONE" or base_bg,
        fg = get_hl_color("Normal", "fg", "#d4be98"),
        yellow = get_hl_color("DiagnosticWarn", "fg", "#d8a657"),
        green = get_hl_color("DiagnosticOk", "fg", "#89b482"),
        blue = get_hl_color("Function", "fg", "#7daea3"),
        aqua = get_hl_color("Type", "fg", "#7daea3"),
        purple = get_hl_color("Keyword", "fg", "#d3869b"),
        red = get_hl_color("DiagnosticError", "fg", "#ea6962"),
        orange = get_hl_color("Number", "fg", "#e78a4e"),
        gray = get_hl_color("Comment", "fg", "#928374"),
      }
    end

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
      stack = {
        goth = "goth",
        nextjs = "nextjs",
        [""] = "",
      },
      file = {
        modified = "●",
        readonly = "",
        unnamed = "[No Name]",
        newfile = "[New]",
      },
      ai = {
        copilot = "",
        codeium = "󰚩",
        tabnine = "󰏚",
      },
    }

    -- Get current theme colors
    local colors = get_theme_colors()

    -- Mode color mapping using dynamic colors
    local mode_color = {
      n = colors.green,
      i = colors.blue,
      v = colors.purple,
      [""] = colors.purple,
      V = colors.purple,
      c = colors.orange,
      no = colors.red,
      s = colors.yellow,
      S = colors.yellow,
      ic = colors.blue,
      R = colors.red,
      Rv = colors.red,
      cv = colors.orange,
      ce = colors.orange,
      r = colors.red,
      rm = colors.red,
      ["r?"] = colors.red,
      ["!"] = colors.red,
      t = colors.green,
    }

    -- Root directory function
    local function root_dir()
      return {
        function()
          local cwd = vim.fn.getcwd()
          local home = os.getenv("HOME") or ""
          local disp = cwd:sub(1, #home) == home and "~" .. cwd:sub(#home + 1) or cwd
          return "󰉋 " .. vim.fn.fnamemodify(disp, ":t")
        end,
        color = function()
          return { fg = utils.get_hl_color("Directory", "fg", colors.blue), bold = true }
        end,
        cond = function()
          return not vim.b.no_root_dir
        end,
      }
    end

    -- Pretty file path
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

    -- Stack badge
    local function stack_badge()
      return {
        function()
          return icons.stack[vim.g.current_stack] or ""
        end,
        color = function()
          if vim.g.current_stack == "goth" then
            return { fg = colors.green, bold = true }
          elseif vim.g.current_stack == "nextjs" then
            return { fg = colors.blue, bold = true }
          elseif vim.g.current_stack == "goth+nextjs" then
            return { fg = colors.orange, bold = true }
          else
            return { fg = colors.gray, bold = true }
          end
        end,
        cond = function()
          return true
        end,
      }
    end

    -- Enhanced LSP indicator with icons
    local function lsp_status()
      return {
        function()
          local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
          if #buf_clients == 0 then
            return "󰅠 no lsp"
          end

          local lsp_names = {}
          for _, client in ipairs(buf_clients) do
            if not vim.tbl_contains({ "copilot", "null-ls", "conform" }, client.name) then
              table.insert(lsp_names, client.name)
            end
          end

          local names_str = table.concat(lsp_names, ", ")
          if #names_str > 30 then
            names_str = string.sub(names_str, 1, 27) .. "..."
          end

          return " " .. names_str
        end,
        color = { fg = colors.green, gui = "bold" },
      }
    end

    -- AI assistant indicators (fixed)
    local function ai_indicators()
      return {
        function()
          local active_provider = vim.g.ai_provider_active
          if not active_provider then
            return ""
          end

          local icon = icons.ai[active_provider] or ""
          return icon
        end,
        color = function()
          local active_provider = vim.g.ai_provider_active
          if active_provider == "copilot" then
            return { fg = "#6CC644" }
          elseif active_provider == "codeium" then
            return { fg = "#09B6A2" }
          elseif active_provider == "tabnine" then
            return { fg = "#CA42F0" }
          else
            return { fg = colors.purple }
          end
        end,
        cond = function()
          return vim.g.ai_provider_active ~= nil
        end,
      }
    end

    -- File size
    local function file_size()
      local function format_size(size)
        local units = { "B", "K", "M", "G" }
        local idx = 1
        while size > 1024 and idx < #units do
          size = size / 1024
          idx = idx + 1
        end
        return string.format("%.1f%s", size, units[idx])
      end

      return function()
        local f = vim.fn.expand("%:p")
        if f == "" or vim.bo.buftype ~= "" then
          return ""
        end
        local size = vim.fn.getfsize(f)
        if size <= 0 then
          return ""
        end
        return format_size(size)
      end
    end

    -- Search count
    local function search_count()
      return function()
        local hlslens_ok, hlslens = pcall(require, "hlslens")
        if hlslens_ok and not vim.g.hlslens_disabled then
          if hlslens.exportData then
            local data = hlslens.exportData()
            if data and data.total_count > 0 then
              return string.format(" %d/%d", data.nearest_index or 1, data.total_count)
            end
          end
        end

        local sc = vim.fn.searchcount({ maxcount = 999, timeout = 500 })
        if vim.v.hlsearch == 1 and sc.total > 0 then
          return string.format(" %d/%d", sc.current, sc.total)
        end
        return ""
      end
    end

    -- File encoding
    local function file_encoding()
      return {
        "encoding",
        fmt = string.upper,
        color = { fg = colors.green },
        cond = function()
          return vim.bo.fileencoding ~= "utf-8"
        end,
      }
    end

    -- File format
    local function file_format()
      return {
        "fileformat",
        symbols = {
          unix = " ",
          dos = " ",
          mac = " ",
        },
        color = { fg = colors.green },
        cond = function()
          return vim.bo.fileformat ~= "unix"
        end,
      }
    end

    -- Progress
    local function progress()
      return {
        "progress",
        color = { fg = colors.fg, gui = "bold" },
      }
    end

    -- Location
    local function location()
      return {
        "location",
        color = { fg = colors.fg, gui = "bold" },
      }
    end

    -- Return the lualine configuration
    return {
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        theme = "auto",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = {
          statusline = { "starter", "neo-tree", "oil", "Trouble", "lazy", "NvimTree" },
          winbar = { "starter", "neo-tree", "oil", "Trouble", "lazy", "NvimTree" },
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
            color = { fg = colors.orange, gui = "bold" },
            padding = { right = 1 },
          },
        },
        lualine_c = {
          root_dir(),
          pretty_path(),
          stack_badge(),
        },
        lualine_x = {
          ai_indicators(),
          lsp_status(),
          file_size(),
          search_count(),
          { "filetype", icon_only = true },
          file_encoding(),
          file_format(),
        },
        lualine_y = { progress() },
        lualine_z = { location() },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { pretty_path() },
        lualine_x = { location() },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
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

    -- Add reload on colorscheme change and AI provider changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.defer_fn(function()
          require("lualine").refresh()
        end, 50)
      end,
    })

    -- Refresh on AI provider changes
    vim.api.nvim_create_autocmd("User", {
      pattern = "AIProviderChanged",
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
