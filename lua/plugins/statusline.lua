-- lua/plugins/lualine.lua
-- Refactored lualine.nvim setup with improved stack indicators and icons
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

    -- Gruvbox-compatible colors
    local colors = {
      bg = "#282828",
      fg = "#d4be98",
      yellow = "#d8a657",
      green = "#89b482",
      blue = "#7daea3",
      aqua = "#7daea3",
      purple = "#d3869b",
      red = "#ea6962",
      orange = "#e78a4e",
      gray = "#928374",
    }

    local icons = {
      diagnostics = {
        Error = " ",
        Warn = " ",
        Info = " ",
        Hint = "",
      },
      git = {
        added = " ",
        modified = " ",
        removed = " ",
      },
      stack = {
        goth = "󰟓 GO·TEMPL·HTMX",
        nextjs = " NEXT·TS·REACT",
        ["goth+nextjs"] = "󰡄 FULLSTACK",
        [""] = "󱍛  Stack",
      },
      mode = {
        ["n"] = "󰋜 ",
        ["no"] = "󰋜 ",
        ["v"] = "󰈈 ",
        ["V"] = " ",
        [""] = " ",
        ["s"] = " ",
        ["S"] = " ",
        [""] = " ",
        ["i"] = " ",
        ["ic"] = " ",
        ["R"] = "󰛔 ",
        ["Rv"] = "󰛔 ",
        ["c"] = " ",
        ["cv"] = " ",
        ["ce"] = " ",
        ["r"] = "󰛔 ",
        ["rm"] = "󰛔 ",
        ["r?"] = "󰛔 ",
        ["!"] = " ",
        ["t"] = " ",
      },
      file = {
        modified = "●",
        readonly = "",
        unnamed = "[No Name]",
        newfile = "[New]",
      },
    }

    -- Mode color mapping
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
      [""] = colors.yellow,
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

    -- Get current mode
    local function mode()
      local mode_text = vim.api.nvim_get_mode().mode
      return icons.mode[mode_text] or icons.mode["n"]
    end

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
          -- Always show stack indicator, with more graceful fallback
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
            return "󰅠 No LSP"
          end

          local lsp_names = {}
          -- Filter out copilot, conform, etc.
          for _, client in ipairs(buf_clients) do
            if not vim.tbl_contains({ "copilot", "null-ls", "conform" }, client.name) then
              table.insert(lsp_names, client.name)
            end
          end

          local names_str = table.concat(lsp_names, ", ")
          -- If the name string is too long, truncate it
          if #names_str > 30 then
            names_str = string.sub(names_str, 1, 27) .. "..."
          end

          return " " .. names_str
        end,
        color = { fg = colors.green, gui = "bold" },
        cond = function()
          return true
        end, -- Always show LSP status
      }
    end

    -- Active LSP servers
    local function lsp_servers()
      return {
        function()
          local names = {}
          for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
            if c.name ~= "copilot" and c.name ~= "conform" and c.name ~= "null-ls" then
              table.insert(names, c.name)
            end
          end
          return names[1] and table.concat(names, ", ") or ""
        end,
        icon = " ",
        color = { fg = colors.green },
        cond = function()
          return #vim.lsp.get_clients({ bufnr = 0 }) > 0
        end,
      }
    end

    -- AI assistant indicators
    local function ai_indicators()
      return {
        function()
          local indicators = {}
          -- Check both Copilot and Codeium status
          if vim.g.copilot_enabled ~= 0 then
            table.insert(indicators, " Copilot")
          end
          if vim.g.codeium_enabled then
            table.insert(indicators, "󰧑 Codeium")
          end

          return #indicators > 0 and table.concat(indicators, " ") or ""
        end,
        color = { fg = colors.purple },
        cond = function()
          return vim.g.copilot_enabled ~= 0 or vim.g.codeium_enabled
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
        -- Try hlslens if available
        local hlslens_ok, hlslens = pcall(require, "hlslens")
        if hlslens_ok and not vim.g.hlslens_disabled then
          -- Use hlslens' exportData function if it exists
          if hlslens.exportData then
            local data = hlslens.exportData()
            if data and data.total_count > 0 then
              return string.format(" %d/%d", data.nearest_index or 1, data.total_count)
            end
          end
        end

        -- Fall back to vanilla vim searchcount
        local sc = vim.fn.searchcount({ maxcount = 999, timeout = 500 })
        if vim.v.hlsearch == 1 and sc.total > 0 then
          return string.format(" %d/%d", sc.current, sc.total)
        end
        return ""
      end
    end

    -- Git branch
    local function git_branch()
      return {
        "branch",
        icon = "",
        color = { fg = colors.orange, gui = "bold" },
      }
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
          unix = " ", -- e712
          dos = " ", -- e70f
          mac = " ", -- e711
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

    -- Mode text
    local function mode_text()
      return {
        function()
          return ""
        end,
        color = function()
          local m = vim.api.nvim_get_mode().mode
          return { bg = mode_color[m], fg = colors.bg, gui = "bold" }
        end,
        padding = { left = 0, right = 0 },
      }
    end

    -- Return the lualine configuration
    return {
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        theme = "gruvbox-material",
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = {
          statusline = { "alpha", "dashboard", "neo-tree", "oil", "Trouble", "lazy" },
        },
      },
      -- Add custom indicators for both stacks
      sections = {
        lualine_a = {
          {
            mode,
            color = function()
              local m = vim.api.nvim_get_mode().mode
              return { bg = mode_color[m] or colors.blue, fg = colors.bg, gui = "bold" }
            end,
            padding = { left = 1, right = 1 },
          },
          stack_badge(),
        },
        lualine_b = {
          git_branch(),
          {
            "diff",
            symbols = icons.git,
            colored = true,
          },
        },
        lualine_c = {
          root_dir(),
          {
            "diagnostics",
            symbols = icons.diagnostics,
            colored = true,
          },
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
      },
    }
  end,

  config = function(_, opts)
    require("lualine").setup(opts)

    -- Add reload on colorscheme change
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
