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

    local ok, wk = pcall(require, "which-key")
    if not ok then
      vim.notify("[whichkey] which-key.nvim not found", vim.log.levels.WARN)
      return
    end

    -- Setup which-key with updated options
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
      filter = function(mapping)
        -- show mappings with a description or group label
        return (mapping.desc and mapping.desc ~= "") or (mapping.group and mapping.group ~= "")
      end,
      show_help = false,
      show_keys = false,
      disable = {
        bt = { "terminal", "nofile" },
        ft = { "TelescopePrompt", "TelescopeResults", "neo-tree", "dashboard", "alpha", "lazy" },
      },
    })

    -- Consolidated which-key registrations using new recommended spec
    wk.register({
      ["<leader>"] = { name = "Leader" },
      ["<leader>a"] = { name = "Actions" },
      ["<leader>b"] = { name = "Buffers" },
      ["<leader>c"] = { name = "Code/LSP" },
      ["<leader>d"] = { name = "Debug/Dashboard" },
      ["<leader>f"] = { name = "Find/Telescope" },
      ["<leader>g"] = { name = "Git" },
      ["<leader>L"] = { name = "Layouts" },
      ["<leader>n"] = { name = "Notifications" },
      ["<leader>s"] = { name = "Stack/Sessions" },
      ["<leader>t"] = { name = "Terminal/Toggle" },
      ["<leader>u"] = { name = "UI/Settings" },
      ["<leader>w"] = { name = "Windows" },
      ["<leader>x"] = { name = "Diagnostics/Trouble" },
      ["<leader>z"] = { name = "Folds" },

      ["<leader>bb"] = { desc = "Other Buffer" },
      ["<leader>bd"] = { desc = "Delete Buffer" },
      ["<leader>bf"] = { desc = "First Buffer" },
      ["<leader>bl"] = { desc = "Last Buffer" },
      ["<leader>bn"] = { desc = "Next Buffer" },
      ["<leader>bp"] = { desc = "Previous Buffer" },

      ["<leader>e"] = { desc = "Open File Explorer (Default)" },
      ["<leader>E"] = { desc = "NvimTree Explorer" },

      ["<leader>fD"] = { desc = "Workspace Diagnostics" },
      ["<leader>fb"] = { desc = "Find Buffers" },
      ["<leader>fd"] = { desc = "Document Diagnostics" },
      ["<leader>ff"] = { desc = "Find Files" },
      ["<leader>fg"] = { desc = "Find Text (Grep)" },
      ["<leader>fh"] = { desc = "Find Help" },
      ["<leader>fr"] = { desc = "Recent Files" },

      ["<leader>gP"] = { desc = "Git Push" },
      ["<leader>gb"] = { desc = "Git Branches" },
      ["<leader>gc"] = { desc = "Git Commits" },
      ["<leader>gd"] = { desc = "DiffView Open" },
      ["<leader>gg"] = { desc = "LazyGit" },
      ["<leader>gp"] = { desc = "Git Pull" },
      ["<leader>gs"] = { desc = "Git Status" },

      ["<leader>rc"] = { desc = "Clean debug prints" },
      ["<leader>re"] = { desc = "Extract function" },
      ["<leader>ri"] = { desc = "Inline variable" },
      ["<leader>rp"] = { desc = "Debug print" },
      ["<leader>rr"] = { desc = "Refactoring menu" },
      ["<leader>rv"] = { desc = "Extract variable" },

      ["<leader>sg"] = { desc = "Focus GOTH Stack" },
      ["<leader>sn"] = { desc = "Focus Next.js Stack" },

      ["<leader>tf"] = { desc = "Terminal (float)" },
      ["<leader>th"] = { desc = "Terminal (horizontal)" },
      ["<leader>tv"] = { desc = "Terminal (vertical)" },

      ["<leader>uS"] = { desc = "Select color scheme" },
      ["<leader>uV"] = { desc = "Select color variant" },
      ["<leader>ub"] = { desc = "Toggle transparency" },
      ["<leader>uc"] = { desc = "Toggle Copilot" },
      ["<leader>ui"] = { desc = "Toggle Codeium" },
      ["<leader>us"] = { desc = "Cycle color scheme" },
      ["<leader>uv"] = { desc = "Cycle color variant" },

      ["<leader>L1"] = { desc = "Coding Layout" },
      ["<leader>L2"] = { desc = "Terminal Layout" },
      ["<leader>L3"] = { desc = "Writing Layout" },
      ["<leader>L4"] = { desc = "Debug Layout" },

      ["<leader>ca"] = { desc = "Code Action" },
      ["<leader>cd"] = { desc = "Show Diagnostics" },
      ["<leader>cf"] = { desc = "Format" },
      ["<leader>cr"] = { desc = "Rename Symbol" },
      ["<leader>cs"] = { desc = "Symbols Outline" },

      ["<leader>xL"] = { desc = "Location List (Trouble)" },
      ["<leader>xQ"] = { desc = "Quickfix List (Trouble)" },
      ["<leader>xX"] = { desc = "Buffer Diagnostics (Trouble)" },
      ["<leader>xx"] = { desc = "Diagnostics (Trouble)" },

      ["<leader>za"] = { desc = "Toggle fold" },
      ["<leader>zR"] = { desc = "Open all folds" },
      ["<leader>zM"] = { desc = "Close all folds" },
      ["<leader>zo"] = { desc = "Open fold" },
      ["<leader>zc"] = { desc = "Close fold" },
      ["<leader>zf"] = { desc = "Create fold" },
      ["<leader>zd"] = { desc = "Delete fold" },
    }, { prefix = "", mode = "n" })

    -- LSP registrations
    local function register_lsp_keys(bufnr)
      local wk_lsp_ok, wk_lsp = pcall(require, "which-key")
      if not wk_lsp_ok then
        return
      end
      wk_lsp.register({
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
        ["<leader>c"] = {
          name = "Code/LSP",
          r = { desc = "Rename Symbol" },
          a = { desc = "Code Action" },
          f = { desc = "Format" },
          d = { desc = "Show Diagnostics" },
          q = { desc = "Diagnostics to loclist" }, -- Fixed from "Quickfix" to "loclist"
          s = { desc = "Symbols Outline" },
        },
      }, { buffer = bufnr })
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        register_lsp_keys(args.buf)
      end,
    })

    -- Filetype-specific mappings (GOTH stack)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "go", "templ" },
      callback = function(args)
        local ok_ft, wk_ft = pcall(require, "which-key")
        if not ok_ft then
          return
        end
        wk_ft.register({
          ["<leader>s"] = {
            name = "Stack Actions",
            r = { desc = "Run GOTH Server" },
            t = { desc = "Run Go Tests" },
            g = { desc = "Generate Templ Files" },
          },
        }, { buffer = args.buf })
      end,
    })

    -- Filetype-specific mappings (Next.js stack)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      callback = function(args)
        local ok_ft, wk_ft = pcall(require, "which-key")
        if not ok_ft then
          return
        end
        wk_ft.register({
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
