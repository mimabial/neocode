-- lua/plugins/keybindings.lua
-- Enhanced WhichKey configuration with symbols-outline integration

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

    -- Setup with better theming
    wk.setup({
      plugins = {
        marks = true,
        registers = true,
        spelling = { enabled = false },
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
        border = "single", -- Match border style with other UI elements
        position = "bottom",
        margin = { 1, 0, 1, 0 },
        padding = { 1, 1, 1, 1 },
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "left",
      },
      ignore_missing = true, -- Don't show "no mapping found"
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " },
      show_help = false, -- Keep UI clean
      show_keys = false, -- Don't show the key in the command line
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
        filetypes = {
          "TelescopePrompt",
          "TelescopeResults",
          "oil",
          "neo-tree",
          "dashboard",
          "alpha",
          "lazy",
        },
      },
    })

    -- Standard leader key group definitions - match keymaps.lua structure
    local groups = {
      ["<leader>"] = { name = "Leader" },
      ["<leader>a"] = { name = "Actions" },
      ["<leader>b"] = { name = "Buffers" },
      ["<leader>c"] = { name = "Code/LSP" },
      ["<leader>d"] = { name = "Debug/Dashboard" },
      ["<leader>e"] = { name = "Explorer" },
      ["<leader>f"] = { name = "Find/Telescope" },
      ["<leader>g"] = { name = "Git" },
      ["<leader>L"] = { name = "Layouts" },
      ["<leader>s"] = { name = "Stack/Sessions" },
      ["<leader>t"] = { name = "Terminal/Toggle" },
      ["<leader>u"] = { name = "UI/Settings" },
      ["<leader>w"] = { name = "Windows" },
      ["<leader>x"] = { name = "Diagnostics/Trouble" },
    }

    -- Register standard groups
    wk.register(groups)

    -- Buffer management keys
    wk.register({
      ["<leader>bb"] = { desc = "Other Buffer" },
      ["<leader>bd"] = { desc = "Delete Buffer" },
      ["<leader>bf"] = { desc = "First Buffer" },
      ["<leader>bl"] = { desc = "Last Buffer" },
      ["<leader>bn"] = { desc = "Next Buffer" },
      ["<leader>bp"] = { desc = "Previous Buffer" },
    })

    -- Explorer keys
    wk.register({
      ["<leader>e"] = { desc = "Open File Explorer (Default)" },
      ["<leader>E"] = { desc = "NvimTree Explorer" },
    })

    -- Telescope/finder keys
    wk.register({
      ["<leader>f"] = { name = "Find/Telescope" },
      ["<leader>ff"] = { desc = "Find Files" },
      ["<leader>fg"] = { desc = "Find Text (Grep)" },
      ["<leader>fb"] = { desc = "Find Buffers" },
      ["<leader>fr"] = { desc = "Recent Files" },
      ["<leader>fh"] = { desc = "Find Help" },
      ["<leader>fd"] = { desc = "Document Diagnostics" },
      ["<leader>fD"] = { desc = "Workspace Diagnostics" },
    })

    -- Git commands
    wk.register({
      ["<leader>g"] = { name = "Git" },
      ["<leader>gP"] = { desc = "Git Push" },
      ["<leader>gb"] = { desc = "Git Branches" },
      ["<leader>gc"] = { desc = "Git Commits" },
      ["<leader>gd"] = { desc = "DiffView Open" },
      ["<leader>gg"] = { desc = "LazyGit" },
      ["<leader>gp"] = { desc = "Git Pull" },
      ["<leader>gs"] = { desc = "Git Status" },
    })

    -- Stack commands
    wk.register({
      ["<leader>s"] = { name = "Stack/Sessions" },
      ["<leader>sg"] = { desc = "Focus GOTH Stack" },
      ["<leader>sn"] = { desc = "Focus Next.js Stack" },
    })

    -- Terminal commands
    wk.register({
      ["<leader>t"] = { name = "Terminal/Toggle" },
      ["<leader>tf"] = { desc = "Terminal (float)" },
      ["<leader>th"] = { desc = "Terminal (horizontal)" },
      ["<leader>tv"] = { desc = "Terminal (vertical)" },
    })

    -- UI settings
    wk.register({
      ["<leader>u"] = { name = "UI/Settings" },
      ["<leader>us"] = { desc = "Cycle color scheme" },
      ["<leader>uS"] = { desc = "Select color scheme" },
      ["<leader>uv"] = { desc = "Cycle color variant" },
      ["<leader>uV"] = { desc = "Select color variant" },
      ["<leader>ub"] = { desc = "Toggle transparency" },
      ["<leader>uc"] = { desc = "Toggle Copilot" },
      ["<leader>ui"] = { desc = "Toggle Codeium" },
    })

    -- Layout presets
    wk.register({
      ["<leader>L"] = { name = "Layouts" },
      ["<leader>L1"] = { desc = "Coding Layout" },
      ["<leader>L2"] = { desc = "Terminal Layout" },
      ["<leader>L3"] = { desc = "Writing Layout" },
      ["<leader>L4"] = { desc = "Debug Layout" },
    })

    -- LSP commands with symbols-outline integration
    wk.register({
      ["<leader>c"] = { name = "Code/LSP" },
      ["<leader>ca"] = { desc = "Code Action" },
      ["<leader>cd"] = { desc = "Show Diagnostics" },
      ["<leader>cf"] = { desc = "Format" },
      ["<leader>cr"] = { desc = "Rename Symbol" },
      ["<leader>cs"] = { desc = "Symbols Outline" }, -- New symbols-outline integration
    })

    -- Trouble/Diagnostics keys
    wk.register({
      ["<leader>x"] = { name = "Diagnostics/Trouble" },
      ["<leader>xx"] = { desc = "Diagnostics (Trouble)" },
      ["<leader>xX"] = { desc = "Buffer Diagnostics (Trouble)" },
      ["<leader>xQ"] = { desc = "Quickfix List (Trouble)" },
      ["<leader>xL"] = { desc = "Location List (Trouble)" },
    })

    -- LSP keybinding descriptions - set in LspAttach
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
            ["s"] = { desc = "Symbols Outline" }, -- Add inside LspAttach for buffer-specific binding
          },
          ["[d"] = { desc = "Previous Diagnostic" },
          ["]d"] = { desc = "Next Diagnostic" },
        }, { buffer = bufnr })
      end,
    })

    -- File-type specific keymaps for GOTH stack
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
          },
        }, { buffer = args.buf })
      end,
    })

    -- File-type specific keymaps for Next.js
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
            ["c"] = { desc = "New component" },
            ["p"] = { desc = "New page" },
          },
        }, { buffer = args.buf })
      end,
    })
  end,
}
