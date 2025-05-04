-- lua/plugins/noice.lua
-- Plugin specification for noice.nvim with streamlined config, keymaps, and autocmds
return {
  "folke/noice.nvim",
  enabled = function()
    return not vim.g.use_snacks_ui
  end,
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },

  -- Key mappings for Noice commands and scrolling
  keys = {
    {
      "<leader>nl",
      function()
        require("noice").cmd("last")
      end,
      desc = "Noice Last Message",
    },
    {
      "<leader>nh",
      function()
        require("noice").cmd("history")
      end,
      desc = "Noice History",
    },
    {
      "<leader>na",
      function()
        require("noice").cmd("all")
      end,
      desc = "Noice All Messages",
    },
    {
      "<leader>nd",
      function()
        require("noice").cmd("dismiss")
      end,
      desc = "Dismiss All Messages",
    },
    {
      "<C-f>",
      function()
        local ok, lsp = pcall(require, "noice.lsp")
        if ok and lsp.scroll(4) then
          return
        end
        return "<C-f>"
      end,
      expr = true,
      silent = true,
      desc = "Scroll forward in Noice or fallback",
      mode = { "i", "n", "s" },
    },
    {
      "<C-b>",
      function()
        local ok, lsp = pcall(require, "noice.lsp")
        if ok and lsp.scroll(-4) then
          return
        end
        return "<C-b>"
      end,
      expr = true,
      silent = true,
      desc = "Scroll backward in Noice or fallback",
      mode = { "i", "n", "s" },
    },
  },

  -- Plugin-specific options
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
      opts = {
        position = { row = "30%", col = "50%" },
        size = { width = 60, height = "auto" },
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
      },
      format = {
        cmdline = { pattern = "^:", icon = ": ", lang = "vim", title = "  C Line  " },
        search_down = { kind = "search", pattern = "^/", icon = "/ ", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = "? ", lang = "regex" },
        filter = { pattern = "^:%s*!", icon = "!", lang = "bash" },
        lua = { pattern = { "^:%s*lua" }, icon = "λ", lang = "lua" },
        help = { pattern = "^:%s*he?l?p?", icon = "?" },
      },
      routes = {
        { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
        { filter = { event = "msg_show", kind = "search_count" }, opts = { view = "virtualtext" } },
      },
    },
    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
      view_warn = "notify",
      view_history = "messages",
      view_search = "virtualtext",
    },
    popupmenu = {
      enabled = true,
      backend = "nui",
      kind_icons = {},
    },
    redirect = { view = "popup", filter = { event = "msg_show" } },
    commands = {
      history = {
        view = "split",
        opts = { enter = true, format = "details" },
        filter = { any = { { event = "notify" }, { error = true } } },
      },
      last = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = { any = { { event = "notify" }, { error = true } } },
        filter_opts = { count = 1 },
      },
      errors = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = { error = true },
        filter_opts = { reverse = true },
      },
    },
    notify = { enabled = true, view = "notify" },
    lsp = {
      progress = { enabled = true, view = "mini", throttle = 1000 / 30 },
      override = { ["vim.lsp.util.convert_input_to_markdown_lines"] = true, ["vim.lsp.util.stylize_markdown"] = true },
      hover = { enabled = true },
      signature = { enabled = true, auto_open = { enabled = true, trigger = true, luasnip = true, throttle = 50 } },
      message = { enabled = true, view = "notify" },
      documentation = { view = "hover", opts = { lang = "markdown", replace = true, render = "plain" } },
    },
    markdown = {
      hover = {
        ["|(%S-)|"] = vim.cmd.help,
        ["%[.-%]%((%S-)%)"] = function(url)
          -- Safe fallback if noice.util is not available
          local ok, util = pcall(require, "noice.util")
          if ok and util and util.open then
            return util.open(url)
          else
            -- Fallback: try basic URL opening with system command
            vim.fn.system(string.format("xdg-open %s || open %s", url, url))
            return true
          end
        end,
      },
      highlights = { ["|%S-|"] = "@text.reference", ["@%S+"] = "@parameter", ["^%s*(Parameters:)"] = "@text.title" },
    },
    override = {
      ["vim.diagnostic.goto_next"] = false,
      ["vim.diagnostic.goto_prev"] = false,
    },
    presets = { bottom_search = true, command_palette = true, long_message_to_split = true, lsp_doc_border = true },
    smart_move = { enabled = true, excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" } },
    throttle = 1000 / 30,
    views = {
      cmdline_popup = { position = { row = 5, col = "50%" }, size = { width = 60, height = "auto" } },
      popupmenu = {
        relative = "editor",
        position = { row = 8, col = "50%" },
        size = { width = 60, height = 10 },
        border = { style = "rounded", padding = { 0, 1 } },
      },
    },
    routes = {
      { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
      { filter = { event = "msg_show", kind = "search_count" }, opts = { view = "virtualtext" } },
    },
  },

  -- Setup and custom autocmds
  config = function(_, opts)
    -- stash the current lazyredraw setting
    local was_lazy = vim.opt.lazyredraw:get()

    -- turn off lazyredraw so Noice can render correctly
    vim.opt.lazyredraw = false

    -- Safe loading of noice
    local ok, noice = pcall(require, "noice")
    if not ok then
      vim.notify("[ERROR] Failed to load noice.nvim: " .. tostring(noice), vim.log.levels.ERROR)
      -- restore lazyredraw before bailing
      vim.opt.lazyredraw = was_lazy
      return
    end

    -- Setup noice with error handling
    local setup_ok, err = pcall(function()
      noice.setup(opts)
    end)
    if not setup_ok then
      vim.notify("[ERROR] Failed to setup noice.nvim: " .. tostring(err), vim.log.levels.ERROR)
      vim.opt.lazyredraw = was_lazy
      return
    end

    -- restore the original lazyredraw value
    vim.opt.lazyredraw = was_lazy

    -- Hide Noice for certain filetypes
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("NoiceDisable", { clear = true }),
      pattern = { "neo-tree", "dashboard", "alpha", "lazy" },
      callback = function()
        vim.b.noice_disable = true
      end,
    })
  end,
}
