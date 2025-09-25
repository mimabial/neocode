return {
  "folke/which-key.nvim",
  event = "UIEnter",
  priority = 820,
  config = function()
    local ok, which_key = pcall(require, "which-key")
    if not ok then
      vim.notify("[Error] which-key.nvim not found", vim.log.levels.WARN)
      return
    end

    -- Setup which-key
    which_key.setup({
      win = {
        title = false,
      },
      -- show mappings with a description or group label
      filter = function(mapping)
        return (mapping.desc and mapping.desc ~= "") or (mapping.group and mapping.group ~= "")
      end,
      show_help = false,
      show_keys = false,
      disable = {
        bt = {}, -- options: terminal, nofile,...
        ft = { "TelescopePrompt", "TelescopeResults", "neo-tree", "lazy" },
      },
    })

    -- Group definitions using v3 API
    which_key.add({
      { "<leader>a",  group = "Avante" },
      { "<leader>b",  group = "Buffers" },
      { "<leader>c",  group = "Code/LSP" },
      { "<leader>d",  group = "Debug" },
      { "<leader>f",  group = "Find/Telescope" },
      { "<leader>fG", group = "Find Git" },
      { "<leader>g",  group = "Git" },
      { "<leader>go", group = "Git Operations (Octo)" },
      { "<leader>L",  group = "Layouts" },
      { "<leader>n",  group = "Notifications" },
      { "<leader>r",  group = "Refactoring" },
      { "<leader>s",  group = "Stack/Sessions" },
      { "<leader>t",  group = "Terminal/Toggle" },
      { "<leader>u",  group = "UI/Settings" },
      { "<leader>w",  group = "Windows" },
      { "<leader>x",  group = "Diagnostics/Trouble" },
      { "<leader>z",  group = "Folds" },
    })

    -- Avante
    which_key.add({
      { "<leader>aa", desc = "Ask Avante" },
      { "<leader>ae", desc = "Edit with Avante" },
      { "<leader>ar", desc = "Refresh Avante" },
    })

    -- Buffer mappings
    which_key.add({
      { "<leader>bb", desc = "Other Buffer" },
      { "<leader>bd", desc = "Delete Buffer" },
      { "<leader>bf", desc = "First Buffer" },
      { "<leader>bl", desc = "Last Buffer" },
      { "<leader>bn", desc = "Next Buffer" },
      { "<leader>bp", desc = "Previous Buffer" },
      { "<leader>bP", desc = "Pick Buffer" },
      { "<leader>b<", desc = "Move Buffer Left" },
      { "<leader>b>", desc = "Move Buffer Right" },
      { "<leader>b.", desc = "Sort by Directory" },
      { "<leader>b,", desc = "Sort by Extension" },
    })

    -- Buffer number mappings
    for i = 1, 9 do
      which_key.add({
        { "<leader>b" .. i, desc = "Go to buffer " .. i },
      })
    end

    -- File/Explorer
    which_key.add({
      { "<leader>e", desc = "Open File Explorer" },
      { "<leader>E", desc = "NvimTree Explorer" },
    })

    -- Telescope/Find
    which_key.add({
      { "<leader>ff", desc = "Find Files" },
      { "<leader>fg", desc = "Find Text (Grep)" },
      { "<leader>fb", desc = "Find Buffers" },
      { "<leader>fr", desc = "Recent Files" },
      { "<leader>fh", desc = "Find Help" },
      { "<leader>fs", desc = "Find Current Word" },
      { "<leader>fc", desc = "Command History" },
      { "<leader>f/", desc = "Search History" },
      { "<leader>fk", desc = "Find Keymaps" },
      { "<leader>fd", desc = "Document Diagnostics" },
      { "<leader>fD", desc = "Workspace Diagnostics" },
      { "<leader>ft", desc = "Find Symbols" },
    })

    -- Telescope Git (moved to fG namespace)
    which_key.add({
      { "<leader>fGc", desc = "Find Git Commits" },
      { "<leader>fGb", desc = "Find Git Branches" },
      { "<leader>fGs", desc = "Find Git Status" },
      { "<leader>fGf", desc = "Find Git Files" },
    })

    -- Core Git (no conflicts)
    which_key.add({
      { "<leader>gg", desc = "LazyGit" },
      { "<leader>gs", desc = "Git Status" },
      { "<leader>gc", desc = "Git Commit" },
      { "<leader>gb", desc = "Git Branch" },
      { "<leader>gm", desc = "Git Merge" },
      { "<leader>gr", desc = "Git Rebase" },
      { "<leader>gl", desc = "Git Log" },
      { "<leader>gp", desc = "Git Pull" },
      { "<leader>gP", desc = "Git Push" },
      { "<leader>gf", desc = "Git Fetch" },
      { "<leader>ga", desc = "Git Add All" },
    })

    -- Octo (go namespace)
    which_key.add({
      { "<leader>go",  desc = "Octo" },
      { "<leader>gpr", desc = "PR List" },
      { "<leader>gi",  desc = "Issue List" },
    })

    -- Refactoring
    which_key.add({
      { "<leader>rr", desc = "Refactoring menu" },
      { "<leader>re", desc = "Extract function" },
      { "<leader>ri", desc = "Inline variable" },
      { "<leader>rp", desc = "Debug print" },
      { "<leader>rc", desc = "Clean debug prints" },
      { "<leader>rv", desc = "Extract variable" },
    })

    -- Stack
    which_key.add({
      { "<leader>sg", desc = "Focus GOTH Stack" },
      { "<leader>sn", desc = "Focus Next.js Stack" },
    })

    -- Terminal
    which_key.add({
      { "<leader>tf", desc = "Terminal (float)" },
      { "<leader>th", desc = "Terminal (horizontal)" },
      { "<leader>tv", desc = "Terminal (vertical)" },
      { "<leader>tt", desc = "Toggle Terminal" },
    })

    -- UI/Settings
    which_key.add({
      { "<leader>us", desc = "Cycle color scheme" },
      { "<leader>uS", desc = "Select color scheme" },
      { "<leader>uv", desc = "Cycle color variant" },
      { "<leader>uV", desc = "Select color variant" },
      { "<leader>ub", desc = "Toggle transparency" },
      { "<leader>uy", desc = "Sync with system theme" },
      { "<leader>uY", desc = "Detect system theme" },
      { "<leader>uz", desc = "Set system NVIM_SCHEME" },
      { "<leader>uL", desc = "List available system themes" },
    })

    -- Navic & Outline
    which_key.add({
      { "<leader>nb", desc = "Toggle breadcrumbs" },
      { "<leader>o",  desc = "Toggle outline" },
      { "]]",         desc = "Next reference" },
      { "[[",         desc = "Prev reference" },
    })

    -- Layouts
    which_key.add({
      { "<leader>L1", desc = "Coding Layout" },
      { "<leader>L2", desc = "Terminal Layout" },
      { "<leader>L3", desc = "Writing Layout" },
      { "<leader>L4", desc = "Debug Layout" },
    })

    -- LSP mappings
    which_key.add({
      { "<leader>ca", desc = "Code Action" },
      { "<leader>cd", desc = "Show Diagnostics" },
      { "<leader>cf", desc = "Format" },
      { "<leader>cr", desc = "Rename Symbol" },
      { "<leader>cs", desc = "Symbols (Trouble)" },
    })

    -- Trouble/Diagnostics
    which_key.add({
      { "<leader>xx", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xQ", desc = "Quickfix List (Trouble)" },
      { "<leader>xL", desc = "Location List (Trouble)" },
    })

    -- Folds
    which_key.add({
      { "<leader>zR", desc = "Open all folds" },
      { "<leader>zM", desc = "Close all folds" },
      { "<leader>zo", desc = "Open fold" },
      { "<leader>zc", desc = "Close fold" },
      { "<leader>za", desc = "Toggle fold" },
      { "<leader>zf", desc = "Create fold" },
      { "<leader>zd", desc = "Delete fold" },
    })

    -- Register LSP-specific keymaps when LSP attaches
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        which_key.add({
          { "gd",    desc = "Go to Definition",     buffer = args.buf },
          { "gD",    desc = "Go to Declaration",    buffer = args.buf },
          { "gi",    desc = "Go to Implementation", buffer = args.buf },
          { "gr",    desc = "Find References",      buffer = args.buf },
          { "K",     desc = "Hover Documentation",  buffer = args.buf },
          { "<C-k>", desc = "Signature Help",       buffer = args.buf },
          { "[d",    desc = "Previous Diagnostic",  buffer = args.buf },
          { "]d",    desc = "Next Diagnostic",      buffer = args.buf },
        })
      end,
    })
  end,
}
