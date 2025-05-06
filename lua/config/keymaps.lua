-- lua/config/keymaps.lua
-- Centralized  definitions: pure keymapping with minmimum descriptions and no which-key integration

local M = {}

function M.setup()
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- ========================================
  -- General keymaps
  -- ========================================

  -- Leader key
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Lazy package manager
  map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

  -- ========================================
  -- Editing keymaps
  -- ========================================

  -- keep selection when indenting in visual mode
  map("v", ">", ">gv", vim.tbl_extend("force", opts, { desc = "Indent and keep selection" }))
  map("v", "<", "<gv", vim.tbl_extend("force", opts, { desc = "Outdent and keep selection" }))

  -- Move lines up and down
  map("v", "J", ":m '>+1<CR>gv=gv", opts)
  map("v", "K", ":m '<-2<CR>gv=gv", opts)

  -- Keep cursor centered when joining lines
  map("n", "J", "mzJ`z", opts)

  -- ========================================
  -- Navigation keymaps
  -- ========================================

  -- Better window navigation
  map("n", "<C-h>", "<C-w>h", opts)
  map("n", "<C-j>", "<C-w>j", opts)
  map("n", "<C-k>", "<C-w>k", opts)
  map("n", "<C-l>", "<C-w>l", opts)

  -- Resize windows with arrows
  map("n", "<C-Up>", ":resize -2<CR>", opts)
  map("n", "<C-Down>", ":resize +2<CR>", opts)
  map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
  map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

  -- Better line movement
  map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
  map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

  -- Keep cursor centered when searching
  map("n", "n", "nzzzv", opts)
  map("n", "N", "Nzzzv", opts)

  -- ========================================
  -- Buffer management
  -- ========================================

  local buffer_maps = {
    { "n", "<leader>bb", "<cmd>e #<cr>", "Switch to Other Buffer" },
    { "n", "<leader>bd", "<cmd>bdelete<cr>", "Delete Buffer" },
    { "n", "<leader>bf", "<cmd>bfirst<cr>", "First Buffer" },
    { "n", "<leader>bl", "<cmd>blast<cr>", "Last Buffer" },
    { "n", "<leader>bn", "<cmd>bnext<cr>", "Next Buffer" },
    { "n", "<leader>bp", "<cmd>bprevious<cr>", "Previous Buffer" },

    -- buffer explorer
    { "n", "<leader>be", "<cmd>Oil<cr>", "Buffer Explorer (Oil)" },
    { "n", "-", "<cmd>Oil<cr>", "Buffer Explorer Parent Dir" },
    { "n", "_", "<cmd>Oil .<cr>", "Buffer Explorer Root Dir" },

    -- buffer navigation with Shift
    { "n", "<S-h>", "<cmd>bprevious<cr>", "Previous Buffer" },
    { "n", "<S-l>", "<cmd>bnext<cr>", "Next Buffer" },
  }

  for _, m in ipairs(buffer_maps) do
    map(m[1], m[2], m[3], vim.tbl_extend("force", opts, { desc = m[4] }))
  end

  -- ========================================
  -- Search & Find
  -- ========================================

  map("n", "<leader>ff", function()
    require("snacks.picker").files()
  end, vim.tbl_extend("force", opts, { desc = "Find Files" }))

  map("n", "<leader>fg", function()
    require("snacks.picker").grep()
  end, vim.tbl_extend("force", opts, { desc = "Find Text (Grep)" }))

  map("n", "<leader>fb", function()
    require("snacks.picker").buffers()
  end, vim.tbl_extend("force", opts, { desc = "Find Buffers" }))

  map("n", "<leader>fr", function()
    require("snacks.picker").recent()
  end, vim.tbl_extend("force", opts, { desc = "Recent Files" }))

  map("n", "<leader>fh", function()
    require("snacks.picker").help()
  end, vim.tbl_extend("force", opts, { desc = "Find Help" }))

  -- Git integration
  map("n", "<leader>gc", function()
    require("snacks.picker").git_commits()
  end, vim.tbl_extend("force", opts, { desc = "Git Commits" }))

  map("n", "<leader>gb", function()
    require("snacks.picker").git_branches()
  end, vim.tbl_extend("force", opts, { desc = "Git Branches" }))

  -- LSP integration
  map("n", "<leader>fd", function()
    require("snacks.picker").diagnostics({ bufnr = 0 })
  end, vim.tbl_extend("force", opts, { desc = "Doc Diagnostics" }))

  map("n", "<leader>fD", function()
    require("snacks.picker").diagnostics()
  end, vim.tbl_extend("force", opts, { desc = "Workspace Diagnostics" }))

  -- ========================================
  -- File Explorer
  -- ========================================

  -- Open Snacks explorer specifically
  map("n", "<leader>fe", function()
    snacks.explorer()
  end, vim.tbl_extend("force", opts, { desc = "Snacks Explorer" }))

  -- Oil file explorer navigation (FileType = oil)
  local group = vim.api.nvim_create_augroup("OilExplorerKeymaps", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "oil",
    desc = "Oil-specific navigation keymaps",
    callback = function()
      local buf_opts = { buffer = 0, noremap = true, silent = true }
      vim.keymap.set("n", "R", function()
        oil.refresh()
      end, buf_opts)
      vim.keymap.set("n", "~", function()
        oil.open(vim.loop.cwd())
      end, buf_opts)
    end,
  })

  -- ========================================
  -- AI Assistant Keymaps
  -- ========================================

  -- Defined in the plugins file

  -- ========================================
  -- Stack
  -- ========================================

  map("n", "<leader>sgf", "<cmd>StackFocus goth<cr>", opts)
  map("n", "<leader>snf", "<cmd>StackFocus nextjs<cr>", opts)

  -- Create stack-specific keymaps based on filetype
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "go", "templ" },
    callback = function()
      -- GOTH stack keymaps
      local buf_opts = { buffer = true, noremap = true, silent = true }
      map("n", "<leader>sgr", "<cmd>GoRun<CR>", vim.tbl_extend("force", buf_opts, { desc = "Run Go project" }))
      map(
        "n",
        "<leader>sgs",
        "<cmd>TemplGenerate<CR>",
        vim.tbl_extend("force", buf_opts, { desc = "Generate Templ files" })
      )
      map("n", "<leader>sgt", "<cmd>TemplNew<CR>", vim.tbl_extend("force", buf_opts, { desc = "New Templ component" }))
      map("n", "<leader>sgd", "<cmd>GoDeclsDir<CR>", vim.tbl_extend("force", buf_opts, { desc = "Go Declarations" }))
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    callback = function()
      -- Next.js stack keymaps
      local buf_opts = { buffer = true, noremap = true, silent = true }
      map(
        "n",
        "<leader>snd",
        "<cmd>npm run dev<CR>",
        vim.tbl_extend("force", buf_opts, { desc = "Next.js dev server" })
      )
      map("n", "<leader>snb", "<cmd>npm run build<CR>", vim.tbl_extend("force", buf_opts, { desc = "Next.js build" }))
      map("n", "<leader>snt", "<cmd>npm run test<CR>", vim.tbl_extend("force", buf_opts, { desc = "Next.js tests" }))
      map("n", "<leader>snl", "<cmd>npm run lint<CR>", vim.tbl_extend("force", buf_opts, { desc = "Next.js lint" }))

      map("n", "<leader>snd", "<cmd>NextDev<CR>", buf_opts)
      map("n", "<leader>snc", "<cmd>NextNewComponent<CR>", buf_opts)
      map("n", "<leader>snp", "<cmd>NextNewPage<CR>", buf_opts)

      -- TypeScript LSP actions
      if pcall(require, "typescript") then
        local ts = require("typescript")
        map(
          "n",
          "<leader>sno",
          ts.actions.organizeImports,
          vim.tbl_extend("force", buf_opts, { desc = "Organize Imports" })
        )
        map("n", "<leader>snr", ts.actions.rename_file, vim.tbl_extend("force", buf_opts, { desc = "Rename File" }))
      end
    end,
  })

  -- ========================================
  -- LSP general keymaps
  -- ========================================

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local bufnr = args.buf

      -- Skip certain LSP clients for keymappings
      if not client or client.name == "copilot" or client.name == "null-ls" then
        return
      end

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

      -- Add additional client-specific keymaps if needed
      if client.name == "gopls" then
        -- Go-specific keymaps (for GOTH stack)
        bufmap("<leader>goi", "<cmd>GoImports<CR>")
        bufmap("<leader>gie", "<cmd>GoIfErr<CR>")
        bufmap("<leader>gfs", "<cmd>GoFillStruct<CR>")
      end
    end,
  })

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

  map("n", "<leader>gg", "<cmd>LazyGit<cr>", opts)
  map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", opts)
  map("n", "<leader>gs", "<cmd>Git<cr>", opts)
  map("n", "<leader>gp", "<cmd>Git pull<cr>", opts)
  map("n", "<leader>gP", "<cmd>Git push<cr>", opts)

  -- ========================================
  -- UI & Theme
  -- ========================================

  -- AI tools
  map("n", "<leader>up", "<cmd>lua require('copilot.command').toggle()<cr>", opts)
  map("n", "<leader>ud", "<cmd>CodeiumToggle<cr>", opts)

  -- Theme toggling
  map("n", "<leader>us", "<cmd>CycleColorScheme<cr>", opts)
  map("n", "<leader>uS", "<cmd>ColorScheme<cr>", opts)
  map("n", "<leader>uv", "<cmd>CycleColorVariant<cr>", opts)
  map("n", "<leader>uV", "<cmd>ColorVariant<cr>", opts)
  map("n", "<leader>ub", "<cmd>ToggleBackgroundTransparency<cr>", opts)

  -- ========================================
  -- Layout presets
  -- ========================================

  map("n", "<leader>L1", "<cmd>Layout coding<cr>", { desc = "Coding Layout" })
  map("n", "<leader>L2", "<cmd>Layout terminal<cr>", { desc = "Terminal Layout" })
  map("n", "<leader>L3", "<cmd>Layout writing<cr>", { desc = "Writing Layout" })
  map("n", "<leader>L4", "<cmd>Layout debug<cr>", { desc = "Debug Layout" })

  -- ========================================
  -- Stack switching
  -- ========================================

  map("n", "<leader>ug", function()
    vim.cmd("StackFocus goth")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, vim.tbl_extend("force", opts, { desc = "Focus GOTH Stack + Dashboard" }))

  map("n", "<leader>un", function()
    vim.cmd("StackFocus nextjs")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, vim.tbl_extend("force", opts, { desc = "Focus Next.js Stack + Dashboard" }))
end

return M
