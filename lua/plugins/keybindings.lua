-- lua/plugins/which-key.lua
-- Enhanced WhichKey configuration with better plugin integration

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  priority = 820,
  config = function()
    local ok, wk = pcall(require, "which-key")
    if not ok then
      vim.notify("[whichkey] which-key.nvim not found", vim.log.levels.WARN)
      return
    end

    -- Setup
    wk.setup({
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = { enabled = false, suggestions = 20 },
        presets = {
          operators = false, -- adds help for operators like d, y, ...
          motions = false, -- adds help for motions
          text_objects = false, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling, etc.
          g = true, -- bindings for prefixed with g
        },
      },
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and its label
        group = "+", -- symbol prepended to a group
      },
      keys = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>", -- binding to scroll up inside the popup
      },
      window = {
        border = "single", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      },
      layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
        align = "left", -- align columns left, center or right
      },
      replace = {
        desc = {
          -- strip common boilerplate in all descriptions
          { "^<silent>", "" }, -- remove leading `<silent>`
          { "^<cmd>", "" }, -- remove leading `<cmd>`
          { "^<Cmd>", "" }, -- remove leading `<Cmd>`
          { "<CR>$", "" }, -- remove trailing `<CR>`
          { "^call%s+", "" }, -- remove leading `call `
          { "^lua%s+", "" }, -- remove leading `lua `
          { "^:%s*", "" }, -- remove any leading `:` and spaces
          { "^%s*", "" }, -- remove any other leading whitespace
        },
      },
      show_help = true, -- show help message on the command line when the popup is visible
      triggers = {
        { "<auto>", mode = "no" },
      },
      -- Disable the WhichKey popup for certain buf/win types: floating windows, non-modifiable buffers
      disable = {
        buftypes = { "terminal", "nofile" },
        filetypes = { "TelescopePrompt", "TelescopeResults", "oil", "neo-tree" },
      },
    })

    -- Define top-level groups with consistent naming
    wk.register({
      ["<leader>"] = { name = "Leader" },
      ["<leader>L"] = { name = "Layouts" },
      ["<leader>b"] = { name = "Buffers" },
      ["<leader>c"] = { name = "Code/LSP" },
      ["<leader>d"] = { name = "Debug" },
      ["<leader>f"] = { name = "Find/Search" },
      ["<leader>g"] = { name = "Git" },
      ["<leader>l"] = { name = "Lazy/Plugins" },
      ["<leader>n"] = { name = "Notifications" },
      ["<leader>s"] = { name = "Stack" },
      ["<leader>t"] = { name = "Terminal/Toggle" },
      ["<leader>u"] = { name = "UI/Settings" },
      ["<leader>x"] = { name = "Diagnostics/Trouble" },
    })

    -- Define buffer management keys
    wk.register({
      ["<leader>b"] = {
        name = "Buffers",
        b = { "<cmd>e #<cr>", "Other Buffer" },
        d = { "<cmd>Bdelete<cr>", "Delete Buffer" },
        l = { "<cmd>BufferLineCloseLeft<cr>", "Close Left Buffers" },
        n = { "<cmd>bnext<cr>", "Next Buffer" },
        o = { "<cmd>BufferLineCloseOthers<cr>", "Close Other Buffers" },
        p = { "<cmd>bprevious<cr>", "Prev Buffer" },
        r = { "<cmd>BufferLineCloseRight<cr>", "Close Right Buffers" },
      },
    })

    -- Define finder keys
    wk.register({
      ["<leader>f"] = {
        name = "Find",
        D = { desc = "Workspace Diagnostics" },
        b = { desc = "Find Buffers" },
        d = { desc = "Document Diagnostics" },
        f = { desc = "Find Files" },
        g = { desc = "Find Text" },
        h = { desc = "Find Help" },
        r = { desc = "Recent Files" },
      },
    })

    -- Git commands
    wk.register({
      ["<leader>g"] = {
        name = "Git",
        P = { "<cmd>Git push<cr>", "Git Push" },
        b = { desc = "Git Branches" },
        c = { desc = "Git Commits" },
        d = { "<cmd>DiffviewOpen<cr>", "DiffView Open" },
        g = { "<cmd>LazyGit<cr>", "LazyGit" },
        p = { "<cmd>Git pull<cr>", "Git Pull" },
        s = { "<cmd>Git<cr>", "Git Status" },
      },
    })

    -- Stack commands
    wk.register({
      ["<leader>s"] = {
        name = "Stack",
        b = { "<cmd>StackFocus both<cr>", "Focus Both" },
        d = { name = "Dashboard" },
        g = { "<cmd>StackFocus goth<cr>", "Focus GOTH" },
        n = { "<cmd>StackFocus nextjs<cr>", "Focus Next.js" },
      },
      ["<leader>sd"] = {
        name = "Dashboard",
        g = { desc = "GOTH Dashboard" },
        n = { desc = "Next.js Dashboard" },
      },
    })

    -- Terminal commands
    wk.register({
      ["<leader>t"] = {
        name = "Terminal/Toggle",
        f = { "<cmd>ToggleTerm direction=float<cr>", "Terminal (float)" },
        h = { "<cmd>ToggleTerm direction=horizontal<cr>", "Terminal (horizontal)" },
        t = { "<cmd>ToggleTerm<cr>", "Toggle Terminal" },
        v = { "<cmd>ToggleTerm direction=vertical<cr>", "Terminal (vertical)" },
      },
    })

    -- UI settings
    wk.register({
      ["<leader>u"] = {
        name = "UI/Themes",
        S = { desc = "Select theme" },
        V = { desc = "Select theme variant" },
        b = { desc = "Toggle background transparency" },
        s = { desc = "Change theme" },
        v = { desc = "Change theme variant" },
      },
    })

    -- Debug commands
    wk.register({
      ["<leader>d"] = {
        name = "Debug",
        O = { desc = "Step Out" },
        b = { desc = "Toggle Breakpoint" },
        c = { desc = "Continue" },
        i = { desc = "Step Into" },
        o = { desc = "Step Over" },
        r = { desc = "REPL" },
        t = { desc = "Terminate" },
        u = { desc = "Toggle UI" },
      },
    })

    -- LSP commands
    wk.register({
      ["<leader>c"] = {
        name = "Code/LSP",
        a = { desc = "Code Action" },
        d = { desc = "Show Diagnostics" },
        f = { desc = "Format" },
        l = { desc = "Lint" },
        q = { desc = "Diagnostics to Quickfix" },
        r = { desc = "Rename" },
      },
    })

    -- Layout commands
    wk.register({
      ["<leader>L"] = {
        name = "Layouts",
        ["1"] = { "<cmd>Layout coding<cr>", "Coding Layout" },
        ["2"] = { "<cmd>Layout terminal<cr>", "Terminal Layout" },
        ["3"] = { "<cmd>Layout writing<cr>", "Writing Layout" },
        ["4"] = { "<cmd>Layout debug<cr>", "Debug Layout" },
      },
    })

    -- Set up autocommand to register plugin-defined keymaps
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        -- Skip if which-key isn't available
        if not ok or not wk then
          return
        end

        -- After plugins load, try to find and register their keymaps
        local plugin_name = event.data

        -- Try to get the plugin keymaps from its module
        local plugin_ok, plugin = pcall(require, plugin_name)
        if plugin_ok and plugin.keys then
          wk.register(plugin.keys)
        end
      end,
    })
  end,
}
