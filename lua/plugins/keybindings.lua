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
      silent = true, -- disable default notifications
      notify = false, -- turn off warning notifications entirely
      show_help = false, -- don’t show the little help text in the cmdline
      show_keys = false, -- don’t echo the current key + label in the cmdline
    })

    -- Keybindings

    wk.register({
      ["<leader>"] = { name = "Leader" },
      a = { name = "Actions" }, -- a: general commands, automations…
      b = { name = "Buffers" }, -- b: buffer-switching, closing…
      c = { name = "Code/Completions" }, -- c: snippets, auto-complete…
      d = { name = "Debug" }, -- d: dap, breakpoints…
      e = { name = "Explorer" }, -- e: file-tree, symbol-tree…
      f = { name = "Find/Search" }, -- f: Telescope, grep…
      g = { name = "Git" }, -- g: blame, status, pull…
      h = { name = "Help/Doc" }, -- h: `:h`, LSP hover, cheatsheets…
      i = { name = "Insert/IDE" }, -- i: toggle insert-mode tools…
      j = { name = "Jump/Navigation" }, -- j: treesitter-jump, marks…
      k = { name = "Keymaps" }, -- k: toggle which-key, show keys…
      l = { name = "LSP" }, -- l: formatting, code actions…
      m = { name = "Marks/Bookmarks" }, -- m: set/jump marks, vim-bookmarks…
      n = { name = "Next.js" }, -- n: project-specific commands…
      o = { name = "Open/File" }, -- o: open file, recent, projects…
      p = { name = "Projects/Packer" }, -- p: sessions, plugin manager…
      q = { name = "Quit/Close" }, -- q: quit, close buffer, exit…
      r = { name = "Refactor/Replace" }, -- r: rename, substitute, macros…
      s = { name = "Session/Search" }, -- s: session save/load, live grep…
      t = { name = "Terminal/Toggle" }, -- t: floating terminal, toggleterm…
      u = { name = "UI/Settings" }, -- u: colorscheme, statusline…
      v = { name = "VCS/Versioning" }, -- v: svn, hg, GitFlow, patch…
      w = { name = "Windows" }, -- w: splits, tabs, resize…
      x = { name = "Diagnostics/Trouble" }, -- x: show errors, list references…
      y = { name = "Yank/Registers" }, -- y: yank history, paste…
      z = { name = "Utilities/Misc" }, -- z: zoom, toggle wrap, misc…
    }, {
      mode = "n",
      prefix = "",
      silent = true,
      noremap = true,
    })

    -- Define top-level groups with consistent naming
    wk.register({})

    -- Define buffer management descriptions
    wk.register({
      { "<leader>bb", desc = "Other Buffer" },
      { "<leader>bd", desc = "Delete Buffer" },
      { "<leader>bl", desc = "Close Left Buffers" },
      { "<leader>bn", desc = "Next Buffer" },
      { "<leader>bo", desc = "Close Other Buffers" },
      { "<leader>bp", desc = "Prev Buffer" },
      { "<leader>br", desc = "Close Right Buffers" },
    })

    -- Define finder descriptions
    wk.register({
      { "<leader>fD", desc = "Workspace Diagnostics" },
      { "<leader>fb", desc = "Find Buffers" },
      { "<leader>fd", desc = "Document Diagnostics" },
      { "<leader>ff", desc = "Find Files" },
      { "<leader>fg", desc = "Find Text" },
      { "<leader>fh", desc = "Find Help" },
      { "<leader>fr", desc = "Recent Files" },
    })

    -- Git commands descriptions
    wk.register({
      { "<leader>gP", desc = "Git Push" },
      { "<leader>gb", desc = "Git Branches" },
      { "<leader>gc", desc = "Git Commits" },
      { "<leader>gd", desc = "DiffView Open" },
      { "<leader>gg", desc = "LazyGit" },
      { "<leader>gp", desc = "Git Pull" },
      { "<leader>gs", desc = "Git Status" },
    })

    -- Stack commands descriptions
    wk.register({
      { "<leader>sb", desc = "Focus Both" },
      { "<leader>sd", group = "Dashboard" },
      { "<leader>sd", desc = "Open Dashboard" },
      { "<leader>sdg", desc = "GOTH Dashboard" },
      { "<leader>sdn", desc = "Next.js Dashboard" },
      { "<leader>sg", desc = "Focus GOTH" },
      { "<leader>sn", desc = "Focus Next.js" },
    })

    -- Terminal commands descriptions
    wk.register({
      { "<leader>tf", desc = "Terminal (float)" },
      { "<leader>th", desc = "Terminal (horizontal)" },
      { "<leader>tv", desc = "Terminal (vertical)" },
    })

    -- UI settings descriptions
    wk.register({
      { "<leader>uS", desc = "Select theme" },
      { "<leader>uV", desc = "Select theme variant" },
      { "<leader>ub", desc = "Toggle background transparency" },
      { "<leader>ud", desc = "Toggle Codeium" },
      { "<leader>up", desc = "Toggle Copilot" },
      { "<leader>us", desc = "Change theme" },
      { "<leader>uv", desc = "Change theme variant" },
    })

    -- Layout descriptions
    wk.register({
      { "<leader>L1", desc = "Coding Layout" },
      { "<leader>L2", desc = "Terminal Layout" },
      { "<leader>L3", desc = "Writing Layout" },
      { "<leader>L4", desc = "Debug Layout" },
    })

    -- GOTH stack commands descriptions
    wk.register({
      { "<leader>gfs", buffer = 1, desc = "Fill struct" },
      { "<leader>gie", buffer = 1, desc = "Add if err" },
      { "<leader>gn", buffer = 1, desc = "New Templ component" },
      { "<leader>goi", buffer = 1, desc = "Organize imports" },
      { "<leader>gr", buffer = 1, desc = "Run Go project" },
      { "<leader>gs", buffer = 1, desc = "Start GOTH server" },
      { "<leader>gt", buffer = 1, desc = "Generate Templ files" },
    })

    -- Next.js commands descriptions
    wk.register({
      { "<leader>nb", buffer = 1, desc = "Next.js build" },
      { "<leader>nc", buffer = 1, desc = "New component" },
      { "<leader>nd", buffer = 1, desc = "Next.js dev server" },
      { "<leader>nl", buffer = 1, desc = "Next.js lint" },
      { "<leader>no", buffer = 1, desc = "Organize Imports" },
      { "<leader>np", buffer = 1, desc = "New page" },
      { "<leader>nr", buffer = 1, desc = "Rename File" },
      { "<leader>nt", buffer = 1, desc = "Next.js tests" },
    })

    -- LSP keymaps descriptions
    wk.register({
      { "<C-k>", desc = "Signature Help" },
      { "<leader>c", group = "Code/LSP" },
      { "<leader>ca", desc = "Code Action" },
      { "<leader>cd", desc = "Show Diagnostics" },
      { "<leader>cf", desc = "Format" },
      { "<leader>cq", desc = "Diagnostics to Quickfix" },
      { "<leader>cr", desc = "Rename Symbol" },
      { "K", desc = "Hover Documentation" },
      { "[d", desc = "Previous Diagnostic" },
      { "]d", desc = "Next Diagnostic" },
      { "g", group = "Goto" },
      { "gD", desc = "Go to Declaration" },
      { "gd", desc = "Go to Definition" },
      { "gi", desc = "Go to Implementation" },
      { "gr", desc = "Find References" },
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
