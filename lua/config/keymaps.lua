-- lua/config/keymaps.lua
-- Refined keymapping structure with better organization and which-key integration

local M = {}

function M.setup()
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- ========================================
  -- Leader key
  -- ========================================
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- ========================================
  -- Editing keymaps
  -- ========================================
  map("v", ">", ">gv", { desc = "Indent and keep selection" })
  map("v", "<", "<gv", { desc = "Outdent and keep selection" })
  map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
  map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
  map("n", "J", "mzJ`z", { desc = "Join lines and keep cursor" })

  -- ========================================
  -- Navigation keymaps
  -- ========================================
  -- Better window navigation
  map("n", "<C-h>", "<C-w>h", { desc = "Navigate left" })
  map("n", "<C-j>", "<C-w>j", { desc = "Navigate down" })
  map("n", "<C-k>", "<C-w>k", { desc = "Navigate up" })
  map("n", "<C-l>", "<C-w>l", { desc = "Navigate right" })

  -- Resize windows with arrows
  map("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height" })
  map("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height" })
  map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
  map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

  -- Better line movement
  map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Better down navigation" })
  map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Better up navigation" })

  -- Keep cursor centered when navigating search results
  map("n", "n", "nzzzv", { desc = "Next search result centered" })
  map("n", "N", "Nzzzv", { desc = "Previous search result centered" })

  -- Ensure which-key is loaded
  local ok_wk, wk = pcall(require, "which-key")
  if ok_wk then
    -- Register top-level group names for better organization
    wk.register({
      ["<leader>"] = { name = "Leader" },
      ["<leader>b"] = { name = "Buffers" },
      ["<leader>c"] = { name = "Code/LSP" },
      ["<leader>d"] = { name = "Debug" },
      ["<leader>f"] = { name = "Find/Search" },
      ["<leader>g"] = { name = "Git" },
      ["<leader>l"] = { name = "Lazy/Plugins" },
      ["<leader>L"] = { name = "Layouts" },
      ["<leader>n"] = { name = "Next.js" },
      ["<leader>s"] = { name = "Stack" },
      ["<leader>t"] = { name = "Terminal/Toggle" },
      ["<leader>u"] = { name = "UI/Settings" },
      ["<leader>x"] = { name = "Diagnostics/Trouble" },
    })
  end

  -- ========================================
  -- Plugin Manager
  -- ========================================
  map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Open Lazy package manager" })

  -- ========================================
  -- Buffer management
  -- ========================================
  map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
  map("n", "<leader>bd", "<cmd>Bdelete<cr>", { desc = "Delete buffer" })
  map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
  map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
  map("n", "<leader>br", "<cmd>BufferLineCloseRight<cr>", { desc = "Close buffers to right" })
  map("n", "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", { desc = "Close buffers to left" })
  map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close other buffers" })

  -- Use shift keys for quicker buffer navigation
  map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
  map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

  -- ========================================
  -- File Explorer
  -- ========================================
  -- Open file explorer
  map("n", "<leader>e", function()
    local explorer = vim.g.default_explorer or "oil"
    if explorer == "snacks" then
      local ok, snacks = pcall(require, "snacks")
      if ok and snacks.explorer then
        pcall(snacks.explorer)
      else
        -- Fallback to oil if snacks isn't available
        vim.cmd("Oil")
      end
    else
      vim.cmd("Oil")
    end
  end, { desc = "File Explorer" })

  -- Shorthand for directory navigation
  map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
  map("n", "_", "<cmd>Oil .<cr>", { desc = "Open project root" })

  -- ========================================
  -- Search functionality (Snacks/Telescope)
  -- ========================================
  local ok_picker = pcall(require, "snacks.picker")
  if ok_picker then
    -- Non-conflicting search keymaps
    map("n", "<leader>ff", function()
      local ok, picker = pcall(require, "snacks.picker")
      if ok and picker.files then
        pcall(picker.files)
      else
        -- Fallback to another file finder if available
        if pcall(require, "telescope.builtin") then
          require("telescope.builtin").find_files()
        end
      end
    end, { desc = "Find files" })
    map("n", "<leader>fg", function()
      require("snacks.picker").grep()
    end, { desc = "Find text" })
    map("n", "<leader>fb", function()
      require("snacks.picker").buffers()
    end, { desc = "Find buffers" })
    map("n", "<leader>fr", function()
      require("snacks.picker").recent()
    end, { desc = "Recent files" })
    map("n", "<leader>fh", function()
      require("snacks.picker").help()
    end, { desc = "Find help" })

    -- Git integration
    map("n", "<leader>gc", function()
      require("snacks.picker").git_commits()
    end, { desc = "Git commits" })
    map("n", "<leader>gb", function()
      require("snacks.picker").git_branches()
    end, { desc = "Git branches" })

    -- LSP integration
    map("n", "<leader>fd", function()
      require("snacks.picker").diagnostics({ bufnr = 0 })
    end, { desc = "Document diagnostics" })
    map("n", "<leader>fD", function()
      require("snacks.picker").diagnostics()
    end, { desc = "Workspace diagnostics" })
  end

  -- ========================================
  -- Stack switching
  -- ========================================
  map("n", "<leader>sg", "<cmd>StackFocus goth<cr>", { desc = "Focus GOTH stack" })
  map("n", "<leader>sn", "<cmd>StackFocus nextjs<cr>", { desc = "Focus Next.js stack" })
  map("n", "<leader>sb", "<cmd>StackFocus both<cr>", { desc = "Focus both stacks" })

  -- Add dashboard integration
  map("n", "<leader>sd", function()
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, { desc = "Open Dashboard" })

  map("n", "<leader>sdg", function()
    vim.cmd("StackFocus goth")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, { desc = "GOTH stack + Dashboard" })

  map("n", "<leader>sdn", function()
    vim.cmd("StackFocus nextjs")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, { desc = "Next.js stack + Dashboard" })

  -- ========================================
  -- Terminal integration
  -- ========================================
  map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal (float)" })
  map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal (horizontal)" })
  map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal (vertical)" })
  map("n", "<C-\\>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })

  -- ========================================
  -- Git integration
  -- ========================================
  map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
  map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "DiffView Open" })
  map("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status" })
  map("n", "<leader>gp", "<cmd>Git pull<cr>", { desc = "Git pull" })
  map("n", "<leader>gP", "<cmd>Git push<cr>", { desc = "Git push" })

  -- ========================================
  -- Theme and UI
  -- ========================================
  map("n", "<leader>tt", "<cmd>ColorSchemeToggle<cr>", { desc = "Toggle theme" })
  map("n", "<leader>ts", "<cmd>ColorScheme<cr>", { desc = "Select theme" })
  map("n", "<leader>tv", "<cmd>ColorSchemeVariant<cr>", { desc = "Select theme variant" })
  map("n", "<leader>tb", "<cmd>ToggleTransparency<cr>", { desc = "Toggle transparency" })

  -- ========================================
  -- Layout presets
  -- ========================================
  map("n", "<leader>L1", "<cmd>Layout coding<cr>", { desc = "Coding Layout" })
  map("n", "<leader>L2", "<cmd>Layout terminal<cr>", { desc = "Terminal Layout" })
  map("n", "<leader>L3", "<cmd>Layout writing<cr>", { desc = "Writing Layout" })
  map("n", "<leader>L4", "<cmd>Layout debug<cr>", { desc = "Debug Layout" })

  -- Register these keymaps with which-key for visibility
  if ok_wk then
    wk.register({
      ["<leader>L"] = {
        name = "Layouts",
        ["1"] = { "<cmd>Layout coding<cr>", "Coding Layout" },
        ["2"] = { "<cmd>Layout terminal<cr>", "Terminal Layout" },
        ["3"] = { "<cmd>Layout writing<cr>", "Writing Layout" },
        ["4"] = { "<cmd>Layout debug<cr>", "Debug Layout" },
      },
    })
  end

  -- ========================================
  -- Stack-specific keymaps
  -- ========================================
  -- Create filetype-specific keymaps that don't conflict
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "go", "templ" },
    callback = function()
      local buf_opts = { buffer = true }

      -- GOTH stack commands with g prefix to avoid conflicts
      map("n", "<leader>gr", "<cmd>GoRun<CR>", vim.tbl_extend("force", buf_opts, { desc = "Run Go project" }))
      map("n", "<leader>gs", "<cmd>GOTHServer<CR>", vim.tbl_extend("force", buf_opts, { desc = "Start GOTH server" }))
      map(
        "n",
        "<leader>gt",
        "<cmd>TemplGenerate<CR>",
        vim.tbl_extend("force", buf_opts, { desc = "Generate Templ files" })
      )
      map("n", "<leader>gn", "<cmd>TemplNew<CR>", vim.tbl_extend("force", buf_opts, { desc = "New Templ component" }))

      -- Register these keymaps with which-key for the current buffer
      if ok_wk then
        wk.register({
          ["<leader>g"] = {
            name = "GOTH",
            ["r"] = { "<cmd>GoRun<CR>", "Run Go project" },
            ["s"] = { "<cmd>GOTHServer<CR>", "Start GOTH server" },
            ["t"] = { "<cmd>TemplGenerate<CR>", "Generate Templ files" },
            ["n"] = { "<cmd>TemplNew<CR>", "New Templ component" },
          },
        }, { buffer = true })
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    callback = function()
      local buf_opts = { buffer = true }

      -- Next.js commands with n prefix to avoid conflicts
      map("n", "<leader>nd", "<cmd>NextDev<CR>", vim.tbl_extend("force", buf_opts, { desc = "Next.js dev server" }))
      map("n", "<leader>nb", "<cmd>NextBuild<CR>", vim.tbl_extend("force", buf_opts, { desc = "Next.js build" }))
      map("n", "<leader>nt", "<cmd>NextTest<CR>", vim.tbl_extend("force", buf_opts, { desc = "Next.js tests" }))
      map("n", "<leader>nl", "<cmd>NextLint<CR>", vim.tbl_extend("force", buf_opts, { desc = "Next.js lint" }))
      map("n", "<leader>nc", "<cmd>NextNewComponent<CR>", vim.tbl_extend("force", buf_opts, { desc = "New component" }))
      map("n", "<leader>np", "<cmd>NextNewPage<CR>", vim.tbl_extend("force", buf_opts, { desc = "New page" }))

      -- Register these keymaps with which-key for the current buffer
      if ok_wk then
        wk.register({
          ["<leader>n"] = {
            name = "Next.js",
            ["d"] = { "<cmd>NextDev<CR>", "Next.js dev server" },
            ["b"] = { "<cmd>NextBuild<CR>", "Next.js build" },
            ["t"] = { "<cmd>NextTest<CR>", "Next.js tests" },
            ["l"] = { "<cmd>NextLint<CR>", "Next.js lint" },
            ["c"] = { "<cmd>NextNewComponent<CR>", "New component" },
            ["p"] = { "<cmd>NextNewPage<CR>", "New page" },
          },
        }, { buffer = true })
      end

      -- TypeScript LSP actions
      if pcall(require, "typescript") then
        local ts = require("typescript")
        map(
          "n",
          "<leader>no",
          ts.actions.organizeImports,
          vim.tbl_extend("force", buf_opts, { desc = "Organize Imports" })
        )
        map("n", "<leader>nr", ts.actions.rename_file, vim.tbl_extend("force", buf_opts, { desc = "Rename File" }))

        -- Register these keymaps with which-key if available
        if ok_wk then
          wk.register({
            ["<leader>n"] = {
              ["o"] = { ts.actions.organizeImports, "Organize Imports" },
              ["r"] = { ts.actions.rename_file, "Rename File" },
            },
          }, { buffer = true })
        end
      end
    end,
  })

  -- ========================================
  -- LSP keymaps setup in LspAttach event
  -- ========================================
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or client.name == "copilot" then
        return
      end

      local bufnr = args.buf
      local function bufmap(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- LSP navigation
      bufmap("gd", vim.lsp.buf.definition, "Go to Definition")
      bufmap("gD", vim.lsp.buf.declaration, "Go to Declaration")
      bufmap("gi", vim.lsp.buf.implementation, "Go to Implementation")
      bufmap("gr", vim.lsp.buf.references, "Find References")

      -- LSP information
      bufmap("K", vim.lsp.buf.hover, "Hover Documentation")
      bufmap("<C-k>", vim.lsp.buf.signature_help, "Signature Help")

      -- LSP actions
      bufmap("<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
      bufmap("<leader>ca", vim.lsp.buf.code_action, "Code Action")
      bufmap("<leader>cf", function()
        vim.lsp.buf.format({ async = true })
      end, "Format")

      -- Diagnostics
      bufmap("<leader>cd", vim.diagnostic.open_float, "Show Diagnostics")
      bufmap("<leader>cq", vim.diagnostic.setqflist, "Diagnostics to Quickfix")
      bufmap("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
      bufmap("]d", vim.diagnostic.goto_next, "Next Diagnostic")

      -- Register with which-key if available
      if ok_wk then
        wk.register({
          ["g"] = {
            ["d"] = { vim.lsp.buf.definition, "Go to Definition" },
            ["D"] = { vim.lsp.buf.declaration, "Go to Declaration" },
            ["i"] = { vim.lsp.buf.implementation, "Go to Implementation" },
            ["r"] = { vim.lsp.buf.references, "Find References" },
          },
          ["<leader>c"] = {
            name = "Code/LSP",
            ["r"] = { vim.lsp.buf.rename, "Rename Symbol" },
            ["a"] = { vim.lsp.buf.code_action, "Code Action" },
            ["f"] = {
              function()
                vim.lsp.buf.format({ async = true })
              end,
              "Format",
            },
            ["d"] = { vim.diagnostic.open_float, "Show Diagnostics" },
            ["q"] = { vim.diagnostic.setqflist, "Diagnostics to Quickfix" },
          },
          ["[d"] = { vim.diagnostic.goto_prev, "Previous Diagnostic" },
          ["]d"] = { vim.diagnostic.goto_next, "Next Diagnostic" },
        }, { buffer = bufnr })
      end

      -- Add additional client-specific keymaps if needed
      if client.name == "gopls" then
        -- Go-specific keymaps (for GOTH stack)
        bufmap("<leader>goi", "<cmd>GoImports<CR>", "Organize imports")
        bufmap("<leader>gie", "<cmd>GoIfErr<CR>", "Add if err")
        bufmap("<leader>gfs", "<cmd>GoFillStruct<CR>", "Fill struct")

        -- Register with which-key if available
        if ok_wk then
          wk.register({
            ["<leader>go"] = {
              name = "Go Organize",
              ["i"] = { "<cmd>GoImports<CR>", "Organize imports" },
            },
            ["<leader>gi"] = {
              name = "Go Insert",
              ["e"] = { "<cmd>GoIfErr<CR>", "Add if err" },
            },
            ["<leader>gf"] = {
              name = "Go Fill",
              ["s"] = { "<cmd>GoFillStruct<CR>", "Fill struct" },
            },
          }, { buffer = bufnr })
        end
      end
    end,
  })
end

return M
