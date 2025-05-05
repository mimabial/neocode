-- lua/config/keymaps.lua
-- Pure keymapping definitions with no descriptions or which-key integration

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
  map("v", ">", ">gv", opts)
  map("v", "<", "<gv", opts)
  map("v", "J", ":m '>+1<CR>gv=gv", opts)
  map("v", "K", ":m '<-2<CR>gv=gv", opts)
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

  -- Keep cursor centered when navigating search results
  map("n", "n", "nzzzv", opts)
  map("n", "N", "Nzzzv", opts)

  -- ========================================
  -- Plugin Manager
  -- ========================================
  map("n", "<leader>l", "<cmd>Lazy<cr>", opts)

  -- ========================================
  -- Buffer management
  -- ========================================
  map("n", "<leader>bb", "<cmd>e #<cr>", opts)
  map("n", "<leader>bd", "<cmd>Bdelete<cr>", opts)
  map("n", "<leader>bn", "<cmd>bnext<cr>", opts)
  map("n", "<leader>bp", "<cmd>bprevious<cr>", opts)
  map("n", "<leader>br", "<cmd>BufferLineCloseRight<cr>", opts)
  map("n", "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", opts)
  map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", opts)

  -- Use shift keys for quicker buffer navigation
  map("n", "<S-h>", "<cmd>bprevious<cr>", opts)
  map("n", "<S-l>", "<cmd>bnext<cr>", opts)

  -- ========================================
  -- File Explorer
  -- ========================================
  -- Open Oil explorer specifically
  map("n", "<leader>eo", function()
    vim.cmd("Oil")
  end, opts)

  -- Open Snacks explorer specifically
  map("n", "<leader>es", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.explorer then
      pcall(snacks.explorer)
    else
      vim.notify("Snacks explorer not available", vim.log.levels.WARN)
      -- Fallback to oil if requested
      if vim.fn.confirm("Open Oil instead?", "&Yes\n&No", 1) == 1 then
        vim.cmd("Oil")
      end
    end
  end, opts)

  -- Shorthand for directory navigation
  map("n", "-", "<cmd>Oil<cr>", opts)
  map("n", "_", "<cmd>Oil .<cr>", opts)

  -- ========================================
  -- Search functionality (Snacks)
  -- ========================================
  map("n", "<leader>ff", function()
    require("snacks.picker").files()
  end, opts)

  map("n", "<leader>fg", function()
    require("snacks.picker").grep()
  end, opts)

  map("n", "<leader>fb", function()
    require("snacks.picker").buffers()
  end, opts)

  map("n", "<leader>fr", function()
    require("snacks.picker").recent()
  end, opts)

  map("n", "<leader>fh", function()
    require("snacks.picker").help()
  end, opts)

  -- Git integration
  map("n", "<leader>gc", function()
    require("snacks.picker").git_commits()
  end, opts)

  map("n", "<leader>gb", function()
    require("snacks.picker").git_branches()
  end, opts)

  -- LSP integration
  map("n", "<leader>fd", function()
    require("snacks.picker").diagnostics({ bufnr = 0 })
  end, opts)

  map("n", "<leader>fD", function()
    require("snacks.picker").diagnostics()
  end, opts)

  -- ========================================
  -- Stack switching
  -- ========================================
  map("n", "<leader>sg", "<cmd>StackFocus goth<cr>", opts)
  map("n", "<leader>sn", "<cmd>StackFocus nextjs<cr>", opts)
  map("n", "<leader>sb", "<cmd>StackFocus both<cr>", opts)

  -- Add dashboard integration
  map("n", "<leader>sd", function()
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, opts)

  -- Stack + Dashboard combinations
  map("n", "<leader>sdg", function()
    vim.cmd("StackFocus goth")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, opts)

  map("n", "<leader>sdn", function()
    vim.cmd("StackFocus nextjs")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, opts)

  -- ========================================
  -- Terminal integration
  -- ========================================
  map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", opts)
  map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", opts)
  map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", opts)
  map("n", "<C-\\>", "<cmd>ToggleTerm<cr>", opts)

  -- ========================================
  -- Git integration
  -- ========================================
  map("n", "<leader>gg", "<cmd>LazyGit<cr>", opts)
  map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", opts)
  map("n", "<leader>gs", "<cmd>Git<cr>", opts)
  map("n", "<leader>gp", "<cmd>Git pull<cr>", opts)
  map("n", "<leader>gP", "<cmd>Git push<cr>", opts)

  -- ========================================
  -- Theme and UI
  -- ========================================
  map("n", "<leader>us", "<cmd>CycleColorScheme<cr>", opts)
  map("n", "<leader>uS", "<cmd>ColorScheme<cr>", opts)
  map("n", "<leader>uv", "<cmd>CycleColorVariant<cr>", opts)
  map("n", "<leader>uV", "<cmd>ColorVariant<cr>", opts)
  map("n", "<leader>ub", "<cmd>ToggleBackgroundTransparency<cr>", opts)

  -- AI tools
  map("n", "<leader>up", "<cmd>lua require('copilot.command').toggle()<cr>", opts)
  map("n", "<leader>ud", "<cmd>CodeiumToggle<cr>", opts)

  -- ========================================
  -- Layout presets
  -- ========================================
  map("n", "<leader>L1", "<cmd>Layout coding<cr>", opts)
  map("n", "<leader>L2", "<cmd>Layout terminal<cr>", opts)
  map("n", "<leader>L3", "<cmd>Layout writing<cr>", opts)
  map("n", "<leader>L4", "<cmd>Layout debug<cr>", opts)

  -- ========================================
  -- Stack-specific keymaps
  -- ========================================
  -- Create filetype-specific keymaps that don't conflict
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "go", "templ" },
    callback = function()
      local buf_opts = { buffer = true, silent = true, noremap = true }

      -- GOTH stack commands with <leader>g prefix (for go-related)
      map("n", "<leader>gr", "<cmd>GoRun<CR>", buf_opts)
      map("n", "<leader>gs", "<cmd>GOTHServer<CR>", buf_opts)
      map("n", "<leader>gt", "<cmd>TemplGenerate<CR>", buf_opts)
      map("n", "<leader>gn", "<cmd>TemplNew<CR>", buf_opts)
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    callback = function()
      local buf_opts = { buffer = true, silent = true, noremap = true }

      -- Next.js commands with <leader>n prefix
      map("n", "<leader>nd", "<cmd>NextDev<CR>", buf_opts)
      map("n", "<leader>nb", "<cmd>NextBuild<CR>", buf_opts)
      map("n", "<leader>nt", "<cmd>NextTest<CR>", buf_opts)
      map("n", "<leader>nl", "<cmd>NextLint<CR>", buf_opts)
      map("n", "<leader>nc", "<cmd>NextNewComponent<CR>", buf_opts)
      map("n", "<leader>np", "<cmd>NextNewPage<CR>", buf_opts)

      -- TypeScript LSP actions
      if pcall(require, "typescript") then
        local ts = require("typescript")
        map("n", "<leader>no", ts.actions.organizeImports, buf_opts)
        map("n", "<leader>nr", ts.actions.rename_file, buf_opts)
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
      local function bufmap(lhs, rhs)
        vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true })
      end

      -- LSP navigation
      bufmap("gd", vim.lsp.buf.definition)
      bufmap("gD", vim.lsp.buf.declaration)
      bufmap("gi", vim.lsp.buf.implementation)
      bufmap("gr", vim.lsp.buf.references)

      -- LSP information
      bufmap("K", vim.lsp.buf.hover)
      bufmap("<C-k>", vim.lsp.buf.signature_help)

      -- LSP actions
      bufmap("<leader>cr", vim.lsp.buf.rename)
      bufmap("<leader>ca", vim.lsp.buf.code_action)
      bufmap("<leader>cf", function()
        vim.lsp.buf.format({ async = true })
      end)

      -- Diagnostics
      bufmap("<leader>cd", vim.diagnostic.open_float)
      bufmap("<leader>cq", vim.diagnostic.setqflist)
      bufmap("[d", vim.diagnostic.goto_prev)
      bufmap("]d", vim.diagnostic.goto_next)

      -- Add additional client-specific keymaps if needed
      if client.name == "gopls" then
        -- Go-specific keymaps (for GOTH stack)
        bufmap("<leader>goi", "<cmd>GoImports<CR>")
        bufmap("<leader>gie", "<cmd>GoIfErr<CR>")
        bufmap("<leader>gfs", "<cmd>GoFillStruct<CR>")
      end
    end,
  })
end

return M
