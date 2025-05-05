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
      { "<leader>", group = "Leader" },
      { "<leader>L", group = "Layouts" },
      { "<leader>b", group = "Buffers" },
      { "<leader>c", group = "Code/LSP" },
      { "<leader>d", group = "Debug" },
      { "<leader>f", group = "Find/Search" },
      { "<leader>g", group = "Git" },
      { "<leader>l", group = "Lazy/Plugins" },
      { "<leader>n", group = "Notifications" },
      { "<leader>s", group = "Stack" },
      { "<leader>t", group = "Terminal/Toggle" },
      { "<leader>u", group = "UI/Settings" },
      { "<leader>x", group = "Diagnostics/Trouble" },
    })

    -- Define buffer management keys
    wk.register({
      { "<leader>b", group = "Buffers" },
      { "<leader>bb", "<cmd>e #<cr>", desc = "Other Buffer" },
      { "<leader>bd", "<cmd>Bdelete<cr>", desc = "Delete Buffer" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close Left Buffers" },
      { "<leader>bn", "<cmd>bnext<cr>", desc = "Next Buffer" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close Other Buffers" },
      { "<leader>bp", "<cmd>bprevious<cr>", desc = "Prev Buffer" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close Right Buffers" },
    })

    -- Define finder keys
    wk.register({
      { "<leader>f", group = "Find" },
      { "<leader>fD", desc = "Workspace Diagnostics" },
      { "<leader>fb", desc = "Find Buffers" },
      { "<leader>fd", desc = "Document Diagnostics" },
      { "<leader>ff", desc = "Find Files" },
      { "<leader>fg", desc = "Find Text" },
      { "<leader>fh", desc = "Find Help" },
      { "<leader>fr", desc = "Recent Files" },
    })

    -- Git commands
    wk.register({
      { "<leader>g", group = "Git" },
      { "<leader>gP", "<cmd>Git push<cr>", desc = "Git Push" },
      { "<leader>gb", desc = "Git Branches" },
      { "<leader>gc", desc = "Git Commits" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "DiffView Open" },
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      { "<leader>gp", "<cmd>Git pull<cr>", desc = "Git Pull" },
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
    })

    -- Stack commands
    wk.register({
      { "<leader>s", group = "Stack" },
      { "<leader>sb", "<cmd>StackFocus both<cr>", desc = "Focus Both" },
      { "<leader>sd", group = "Dashboard" },
      { "<leader>sdg", desc = "GOTH Dashboard" },
      { "<leader>sdn", desc = "Next.js Dashboard" },
      { "<leader>sg", "<cmd>StackFocus goth<cr>", desc = "Focus GOTH" },
      { "<leader>sn", "<cmd>StackFocus nextjs<cr>", desc = "Focus Next.js" },
    })

    -- Terminal commands
    wk.register({
      { "<leader>t", group = "Terminal/Toggle" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal (float)" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal (horizontal)" },
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal (vertical)" },
    })

    -- UI settings
    wk.register({
      { "<leader>u", group = "UI/Themes" },
      { "<leader>uS", desc = "Select theme" },
      { "<leader>uV", desc = "Select theme variant" },
      { "<leader>ub", desc = "Toggle background transparency" },
      { "<leader>us", desc = "Change theme" },
      { "<leader>uv", desc = "Change theme variant" },
    })

    -- Debug commands
    wk.register({
      { "<leader>d", group = "Debug" },
      { "<leader>dO", desc = "Step Out" },
      { "<leader>db", desc = "Toggle Breakpoint" },
      { "<leader>dc", desc = "Continue" },
      { "<leader>di", desc = "Step Into" },
      { "<leader>do", desc = "Step Over" },
      { "<leader>dr", desc = "REPL" },
      { "<leader>dt", desc = "Terminate" },
      { "<leader>du", desc = "Toggle UI" },
    })

    -- LSP commands
    wk.register({
      { "<leader>c", group = "Code/LSP" },
      { "<leader>ca", desc = "Code Action" },
      { "<leader>cd", desc = "Show Diagnostics" },
      { "<leader>cf", desc = "Format" },
      { "<leader>cl", desc = "Lint" },
      { "<leader>cq", desc = "Diagnostics to Quickfix" },
      { "<leader>cr", desc = "Rename" },
    })

    -- Layout commands
    wk.register({
      { "<leader>L", group = "Layouts" },
      { "<leader>L1", "<cmd>Layout coding<cr>", desc = "Coding Layout" },
      { "<leader>L2", "<cmd>Layout terminal<cr>", desc = "Terminal Layout" },
      { "<leader>L3", "<cmd>Layout writing<cr>", desc = "Writing Layout" },
      { "<leader>L4", "<cmd>Layout debug<cr>", desc = "Debug Layout" },
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
