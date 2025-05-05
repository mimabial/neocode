-- lua/plugins/keybindings.lua
-- Centralized WhichKey configuration for keymap descriptions

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
        marks = true,
        registers = true,
        spelling = { enabled = false, suggestions = 20 },
        presets = {
          operators = false,
          motions = false,
          text_objects = false,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
      window = {
        border = "single",
        position = "bottom",
        margin = { 1, 0, 1, 0 },
        padding = { 2, 2, 2, 2 },
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "left",
      },
      ignore_missing = false,
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " },
      show_help = true,
      show_keys = true,
      triggers = "auto",
      triggers_nowait = {
        -- marks
        "`",
        "'",
        "g`",
        "g'",
        -- registers
        '"',
        "<c-r>",
        -- spelling
        "z=",
      },
      triggers_blacklist = {
        i = { "j", "k" },
        v = { "j", "k" },
      },
      -- Disable the WhichKey popup for certain buf/win types
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
      ["<leader>e"] = { name = "Explorer" },
      ["<leader>f"] = { name = "Find/Search" },
      ["<leader>g"] = { name = "Git" },
      ["<leader>l"] = { desc = "Lazy/Plugins" },
      ["<leader>n"] = { name = "Next.js" },
      ["<leader>s"] = { name = "Stack" },
      ["<leader>t"] = { name = "Terminal/Toggle" },
      ["<leader>u"] = { name = "UI/Settings" },
      ["<leader>x"] = { name = "Diagnostics/Trouble" },
    })

    -- Editing keymaps descriptions
    wk.register({
      [">"] = { desc = "Indent and keep selection" },
      ["<"] = { desc = "Outdent and keep selection" },
      ["J"] = { desc = "Move selection down" },
      ["K"] = { desc = "Move selection up" },
    }, { mode = "v" })

    wk.register({
      ["J"] = { desc = "Join lines and keep cursor" },
    })

    -- Navigation keymaps descriptions
    wk.register({
      ["<C-h>"] = { desc = "Navigate left" },
      ["<C-j>"] = { desc = "Navigate down" },
      ["<C-k>"] = { desc = "Navigate up" },
      ["<C-l>"] = { desc = "Navigate right" },
      ["<C-Up>"] = { desc = "Decrease window height" },
      ["<C-Down>"] = { desc = "Increase window height" },
      ["<C-Left>"] = { desc = "Decrease window width" },
      ["<C-Right>"] = { desc = "Increase window width" },
      ["j"] = { desc = "Better down navigation" },
      ["k"] = { desc = "Better up navigation" },
      ["n"] = { desc = "Next search result centered" },
      ["N"] = { desc = "Previous search result centered" },
    })

    -- Explorer keymaps
    wk.register({
      ["<leader>eo"] = { desc = "Open Oil Explorer" },
      ["<leader>es"] = { desc = "Open Snacks Explorer" },
      ["-"] = { desc = "Open parent directory" },
      ["_"] = { desc = "Open project root" },
    })

    -- Define buffer management descriptions
    wk.register({
      ["<leader>b"] = {
        name = "Buffers",
        b = { desc = "Other Buffer" },
        d = { desc = "Delete Buffer" },
        l = { desc = "Close Left Buffers" },
        n = { desc = "Next Buffer" },
        o = { desc = "Close Other Buffers" },
        p = { desc = "Prev Buffer" },
        r = { desc = "Close Right Buffers" },
      },
      ["<S-h>"] = { desc = "Previous buffer" },
      ["<S-l>"] = { desc = "Next buffer" },
    })

    -- Define finder descriptions
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

    -- Git commands descriptions
    wk.register({
      ["<leader>g"] = {
        name = "Git",
        P = { desc = "Git Push" },
        b = { desc = "Git Branches" },
        c = { desc = "Git Commits" },
        d = { desc = "DiffView Open" },
        g = { desc = "LazyGit" },
        p = { desc = "Git Pull" },
        s = { desc = "Git Status" },
      },
    })

    -- Stack commands descriptions
    wk.register({
      ["<leader>s"] = {
        name = "Stack",
        b = { desc = "Focus Both" },
        d = { desc = "Open Dashboard" },
        g = { desc = "Focus GOTH" },
        n = { desc = "Focus Next.js" },
      },
      ["<leader>sd"] = {
        name = "Dashboard",
        g = { desc = "GOTH Dashboard" },
        n = { desc = "Next.js Dashboard" },
      },
    })

    -- Terminal commands descriptions
    wk.register({
      ["<leader>t"] = {
        name = "Terminal/Toggle",
        f = { desc = "Terminal (float)" },
        h = { desc = "Terminal (horizontal)" },
        v = { desc = "Terminal (vertical)" },
      },
      ["<C-\\>"] = { desc = "Toggle terminal" },
    })

    -- UI settings descriptions
    wk.register({
      ["<leader>u"] = {
        name = "UI/Themes",
        S = { desc = "Select theme" },
        V = { desc = "Select theme variant" },
        b = { desc = "Toggle background transparency" },
        d = { desc = "Toggle Codeium" },
        p = { desc = "Toggle Copilot" },
        s = { desc = "Change theme" },
        v = { desc = "Change theme variant" },
      },
    })

    -- Layout descriptions
    wk.register({
      ["<leader>L"] = {
        name = "Layouts",
        ["1"] = { desc = "Coding Layout" },
        ["2"] = { desc = "Terminal Layout" },
        ["3"] = { desc = "Writing Layout" },
        ["4"] = { desc = "Debug Layout" },
      },
    })

    -- GOTH stack commands descriptions
    wk.register({
      ["<leader>gr"] = { desc = "Run Go project" },
      ["<leader>gs"] = { desc = "Start GOTH server" },
      ["<leader>gt"] = { desc = "Generate Templ files" },
      ["<leader>gn"] = { desc = "New Templ component" },
      ["<leader>goi"] = { desc = "Organize imports" },
      ["<leader>gie"] = { desc = "Add if err" },
      ["<leader>gfs"] = { desc = "Fill struct" },
    }, { mode = "n", buffer = vim.fn.bufnr(), ft = { "go", "templ" } })

    -- Next.js commands descriptions
    wk.register({
      ["<leader>n"] = {
        name = "Next.js",
        d = { desc = "Next.js dev server" },
        b = { desc = "Next.js build" },
        t = { desc = "Next.js tests" },
        l = { desc = "Next.js lint" },
        c = { desc = "New component" },
        p = { desc = "New page" },
        o = { desc = "Organize Imports" },
        r = { desc = "Rename File" },
      },
    }, { buffer = vim.fn.bufnr(), ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" } })

    -- LSP keymaps descriptions
    wk.register({
      ["g"] = {
        name = "Goto",
        ["d"] = { desc = "Go to Definition" },
        ["D"] = { desc = "Go to Declaration" },
        ["i"] = { desc = "Go to Implementation" },
        ["r"] = { desc = "Find References" },
      },
      ["K"] = { desc = "Hover Documentation" },
      ["<C-k>"] = { desc = "Signature Help" },
      ["<leader>c"] = {
        name = "Code/LSP",
        ["r"] = { desc = "Rename Symbol" },
        ["a"] = { desc = "Code Action" },
        ["f"] = { desc = "Format" },
        ["d"] = { desc = "Show Diagnostics" },
        ["q"] = { desc = "Diagnostics to Quickfix" },
      },
      ["[d"] = { desc = "Previous Diagnostic" },
      ["]d"] = { desc = "Next Diagnostic" },
    })

    -- Register LSP descriptions on attach
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        if not ok or not wk then
          return
        end

        local bufnr = args.buf
        wk.register({
          ["g"] = {
            name = "Goto",
            ["d"] = { desc = "Go to Definition" },
            ["D"] = { desc = "Go to Declaration" },
            ["i"] = { desc = "Go to Implementation" },
            ["r"] = { desc = "Find References" },
          },
          ["K"] = { desc = "Hover Documentation" },
          ["<C-k>"] = { desc = "Signature Help" },
          ["<leader>c"] = {
            name = "Code/LSP",
            ["r"] = { desc = "Rename Symbol" },
            ["a"] = { desc = "Code Action" },
            ["f"] = { desc = "Format" },
            ["d"] = { desc = "Show Diagnostics" },
            ["q"] = { desc = "Diagnostics to Quickfix" },
          },
          ["[d"] = { desc = "Previous Diagnostic" },
          ["]d"] = { desc = "Next Diagnostic" },
        }, { buffer = bufnr })
      end,
    })

    -- Register file-type specific descriptions
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "go", "templ" },
      callback = function(args)
        if not ok or not wk then
          return
        end

        wk.register({
          ["<leader>g"] = {
            name = "GOTH",
            ["r"] = { desc = "Run Go project" },
            ["s"] = { desc = "Start GOTH server" },
            ["t"] = { desc = "Generate Templ files" },
            ["n"] = { desc = "New Templ component" },
            ["o"] = { name = "Organize", ["i"] = { desc = "Organize imports" } },
            ["i"] = { name = "Insert", ["e"] = { desc = "Add if err" } },
            ["f"] = { name = "Fill", ["s"] = { desc = "Fill struct" } },
          },
        }, { buffer = args.buf })
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      callback = function(args)
        if not ok or not wk then
          return
        end

        wk.register({
          ["<leader>n"] = {
            name = "Next.js",
            ["d"] = { desc = "Next.js dev server" },
            ["b"] = { desc = "Next.js build" },
            ["t"] = { desc = "Next.js tests" },
            ["l"] = { desc = "Next.js lint" },
            ["c"] = { desc = "New component" },
            ["p"] = { desc = "New page" },
            ["o"] = { desc = "Organize Imports" },
            ["r"] = { desc = "Rename File" },
          },
        }, { buffer = args.buf })
      end,
    })
  end,
}
