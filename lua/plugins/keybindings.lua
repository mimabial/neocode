return {
  "folke/which-key.nvim",
  event = "UIEnter",
  priority = 820,
  config = function()
    -- Health check for which-key
    local health_ok, health = pcall(require, "which-key.health")
    if health_ok and type(health.check) == "function" then
      health.check()
    end

    local ok, which_key = pcall(require, "which-key")
    if not ok then
      vim.notify("[Error] which-key.nvim not found", vim.log.levels.WARN)
      return
    end

    -- Setup which-key
    which_key.setup({
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
      win = {
        no_overlap = true,
        border = "single",
        padding = { 1, 1 },
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "left",
      },
      -- show mappings with a description or group label
      filter = function(mapping)
        return (mapping.desc and mapping.desc ~= "") or (mapping.group and mapping.group ~= "")
      end,
      show_help = false,
      show_keys = false,
      disable = {
        bt = { "terminal", "nofile" },
        ft = { "TelescopePrompt", "TelescopeResults", "neo-tree", "dashboard", "alpha", "lazy" },
      },
    })

    -- Group definitions
    which_key.register({
      ["<leader>"] = { name = "Leader" },
      ["<leader>b"] = { name = "Buffers" },
      ["<leader>c"] = { name = "Code/LSP" },
      ["<leader>d"] = { name = "Debug/Dashboard" },
      ["<leader>f"] = { name = "Find/Telescope" },
      ["<leader>g"] = { name = "Git" },
      ["<leader>L"] = { name = "Layouts" },
      ["<leader>n"] = { name = "Notifications" },
      ["<leader>r"] = { name = "Refactoring" },
      ["<leader>s"] = { name = "Stack/Sessions" },
      ["<leader>t"] = { name = "Terminal/Toggle" },
      ["<leader>u"] = { name = "UI/Settings" },
      ["<leader>w"] = { name = "Windows" },
      ["<leader>x"] = { name = "Diagnostics/Trouble" },
      ["<leader>z"] = { name = "Folds" },
    })

    -- Buffer mappings
    which_key.register({
      ["<leader>bb"] = { desc = "Other Buffer" },
      ["<leader>bd"] = { desc = "Delete Buffer" },
      ["<leader>bf"] = { desc = "First Buffer" },
      ["<leader>bl"] = { desc = "Last Buffer" },
      ["<leader>bn"] = { desc = "Next Buffer" },
      ["<leader>bp"] = { desc = "Previous Buffer" },
      ["<leader>bP"] = { desc = "Pick Buffer" },
      ["<leader>b<"] = { desc = "Move Buffer Left" },
      ["<leader>b>"] = { desc = "Move Buffer Right" },
      ["<leader>b."] = { desc = "Sort by Directory" },
      ["<leader>b,"] = { desc = "Sort by Extension" },
    })

      for i = 1, 9 do
        which_key.register({
          ["<leader>b" .. i] = { desc = "Go to buffer " .. i },
        })
      end

    -- File/Explorer
    which_key.register({
      ["<leader>e"] = { desc = "Open File Explorer" },
      ["<leader>E"] = { desc = "NvimTree Explorer" },
    })

    -- Telescope/Find
    which_key.register({
      ["<leader>ff"] = { desc = "Find Files" },
      ["<leader>fg"] = { desc = "Find Text (Grep)" },
      ["<leader>fb"] = { desc = "Find Buffers" },
      ["<leader>fr"] = { desc = "Recent Files" },
      ["<leader>fh"] = { desc = "Find Help" },
      ["<leader>fd"] = { desc = "Document Diagnostics" },
      ["<leader>fD"] = { desc = "Workspace Diagnostics" },
    })

    -- Git
    which_key.register({
      ["<leader>gg"] = { desc = "LazyGit" },
      ["<leader>gd"] = { desc = "DiffView Open" },
      ["<leader>gs"] = { desc = "Git Status" },
      ["<leader>gb"] = { desc = "Git Branches" },
      ["<leader>gc"] = { desc = "Git Commits" },
      ["<leader>gp"] = { desc = "Git Pull" },
      ["<leader>gP"] = { desc = "Git Push" },
    })

    -- Refactoring
    which_key.register({
      ["<leader>rr"] = { desc = "Refactoring menu" },
      ["<leader>re"] = { desc = "Extract function" },
      ["<leader>ri"] = { desc = "Inline variable" },
      ["<leader>rp"] = { desc = "Debug print" },
      ["<leader>rc"] = { desc = "Clean debug prints" },
      ["<leader>rv"] = { desc = "Extract variable" },
    })

    -- Stack
    which_key.register({
      ["<leader>sg"] = { desc = "Focus GOTH Stack" },
      ["<leader>sn"] = { desc = "Focus Next.js Stack" },
    })

    -- Terminal
    which_key.register({
      ["<leader>tf"] = { desc = "Terminal (float)" },
      ["<leader>th"] = { desc = "Terminal (horizontal)" },
      ["<leader>tv"] = { desc = "Terminal (vertical)" },
      ["<leader>tt"] = { desc = "Toggle Terminal" },
    })

    -- UI/Settings
    which_key.register({
      ["<leader>us"] = { desc = "Cycle color scheme" },
      ["<leader>uS"] = { desc = "Select color scheme" },
      ["<leader>uv"] = { desc = "Cycle color variant" },
      ["<leader>uV"] = { desc = "Select color variant" },
      ["<leader>ub"] = { desc = "Toggle transparency" },
      ["<leader>uc"] = { desc = "Toggle Copilot" },
      ["<leader>ui"] = { desc = "Toggle Codeium" },
    })

    -- Layouts
    which_key.register({
      ["<leader>L1"] = { desc = "Coding Layout" },
      ["<leader>L2"] = { desc = "Terminal Layout" },
      ["<leader>L3"] = { desc = "Writing Layout" },
      ["<leader>L4"] = { desc = "Debug Layout" },
    })

    -- LSP mappings
    which_key.register({
      ["<leader>ca"] = { desc = "Code Action" },
      ["<leader>cd"] = { desc = "Show Diagnostics" },
      ["<leader>cf"] = { desc = "Format" },
      ["<leader>cr"] = { desc = "Rename Symbol" },
      ["<leader>cs"] = { desc = "Symbols Outline" },
    })

    -- Trouble/Diagnostics
    which_key.register({
      ["<leader>xx"] = { desc = "Diagnostics (Trouble)" },
      ["<leader>xX"] = { desc = "Buffer Diagnostics (Trouble)" },
      ["<leader>xQ"] = { desc = "Quickfix List (Trouble)" },
      ["<leader>xL"] = { desc = "Location List (Trouble)" },
    })

    -- Folds
    which_key.register({
      ["<leader>zR"] = { desc = "Open all folds" },
      ["<leader>zM"] = { desc = "Close all folds" },
      ["<leader>zo"] = { desc = "Open fold" },
      ["<leader>zc"] = { desc = "Close fold" },
      ["<leader>za"] = { desc = "Toggle fold" },
      ["<leader>zf"] = { desc = "Create fold" },
      ["<leader>zd"] = { desc = "Delete fold" },
    })

    -- Register LSP-specific keymaps when LSP attaches
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        which_key.register({
          ["g"] = {
            name = "Goto",
            d = { desc = "Go to Definition" },
            D = { desc = "Go to Declaration" },
            i = { desc = "Go to Implementation" },
            r = { desc = "Find References" },
          },
          K = { desc = "Hover Documentation" },
          ["<C-k>"] = { desc = "Signature Help" },
          ["[d"] = { desc = "Previous Diagnostic" },
          ["]d"] = { desc = "Next Diagnostic" },
        }, { buffer = args.buf })
      end,
    })

    -- Stack-specific keymaps for GOTH
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "go", "templ" },
      callback = function(args)
        which_key.register({
          ["<leader>s"] = {
            name = "Stack Actions",
            r = { desc = "Run GOTH Server" },
            t = { desc = "Run Go Tests" },
            g = { desc = "Generate Templ Files" },
          },
        }, { buffer = args.buf })
      end,
    })

    -- Stack-specific keymaps for Next.js
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      callback = function(args)
        which_key.register({
          ["<leader>s"] = {
            name = "Stack Actions",
            r = { desc = "Run Next.js Server" },
            b = { desc = "Build Next.js App" },
            l = { desc = "Lint Next.js App" },
          },
        }, { buffer = args.buf })
      end,
    })
  end,
}
