-- lua/config/keymaps.lua
-- Centralized keymap definitions: buffer management, Snacks picker, explorer, and stack commands

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

  -- keep selection when indenting in visual mode
  map("v", ">", ">gv", vim.tbl_extend("force", opts, { desc = "Indent and keep selection" }))
  map("v", "<", "<gv", vim.tbl_extend("force", opts, { desc = "Outdent and keep selection" }))

  -- Window navigation
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
  
  -- Lazy package manager
  map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
  
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

  local ok_picker, picker = pcall(require, "snacks.picker")
  if ok_picker then
    local snack_maps = {
      {
        "n",
        "<leader>ff",
        function() picker.files() end,
        "Find Files",
      },
      {
        "n",
        "<leader>fg",
        function() picker.grep() end,
        "Find Text (Grep)",
      },
      {
        "n",
        "<leader>fb",
        function() picker.buffers() end,
        "Find Buffers",
      },
      {
        "n",
        "<leader>fh",
        function() picker.help() end,
        "Find Help",
      },
      {
        "n",
        "<leader>fr",
        function() picker.recent() end,
        "Recent Files",
      },
      -- git integration
      {
        "n",
        "<leader>gc",
        function() picker.git_log() end,
        "Git Commits",
      },
      {
        "n",
        "<leader>gb",
        function() picker.git_branches() end,
        "Git Branches",
      },
      -- lsp integration
      {
        "n",
        "<leader>fd",
        function() picker.diagnostics({ bufnr = 0 }) end,
        "Doc Diagnostics",
      },
      {
        "n",
        "<leader>fD",
        function() picker.diagnostics() end,
        "Workspace Diagnostics",
      },
    }
    
    for _, m in ipairs(snack_maps) do
      map(m[1], m[2], m[3], vim.tbl_extend("force", opts, { desc = m[4] }))
    end
  end
  
  -- Fallback to Telescope if Snacks not available
  if not ok_picker and pcall(require, "telescope.builtin") then
    local telescope = require("telescope.builtin")
    map("n", "<leader>ff", telescope.find_files, { desc = "Find Files" })
    map("n", "<leader>fg", telescope.live_grep, { desc = "Find Text (Grep)" })
    map("n", "<leader>fb", telescope.buffers, { desc = "Find Buffers" })
    map("n", "<leader>fh", telescope.help_tags, { desc = "Find Help" })
  end
  
  -- ========================================
  -- File Explorer
  -- ========================================

-- Snacks explorer
  local ok_snacks, snacks = pcall(require, "snacks")
  if ok_snacks then
    map("n", "<leader>e", function()
      snacks.explorer()
    end, vim.tbl_extend("force", opts, { desc = "Snacks Explorer" }))
  else
    -- Oil fallback
    map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Oil Explorer" })
  end
  
  -- ========================================
  -- AI Assistant Keymaps
  -- ========================================
  
  -- Copilot
  if pcall(require, "copilot") then
    map("n", "<leader>uc", function()
      local copilot_client = vim.lsp.get_clients({ name = "copilot" })[1]
      if copilot_client then
        copilot_client.stop()
        vim.notify("Copilot disabled", vim.log.levels.INFO)
      else
        vim.cmd("Copilot enable")
        vim.notify("Copilot enabled", vim.log.levels.INFO)
      end
    end, { desc = "Toggle Copilot" })
  end
  
  -- Codeium
  if vim.fn.exists("g:codeium_enabled") == 1 then
    map("n", "<leader>ui", function()
      if vim.g.codeium_enabled then
        vim.cmd("CodeiumDisable")
      else
        vim.cmd("CodeiumEnable")
      end
    end, { desc = "Toggle Codeium" })
  end
  
  -- ========================================
  -- Stack-specific keymaps
  -- ========================================

  -- Create stack-specific keymaps based on filetype
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "go", "templ" },
    callback = function()
      -- GOTH stack keymaps
      local buf_opts = { buffer = true, noremap = true, silent = true }
      map("n", "<leader>sgr", "<cmd>GoRun<CR>", vim.tbl_extend("force", buf_opts, { desc = "Run Go project" }))
      map("n", "<leader>sgs", "<cmd>TemplGenerate<CR>", vim.tbl_extend("force", buf_opts, { desc = "Generate Templ files" }))
      map("n", "<leader>sgt", "<cmd>TemplNew<CR>", vim.tbl_extend("force", buf_opts, { desc = "New Templ component" }))
      map("n", "<leader>sgd", "<cmd>GoDeclsDir<CR>", vim.tbl_extend("force", buf_opts, { desc = "Go Declarations" }))
    end,
  })
  
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    callback = function()
      -- Next.js stack keymaps
      local buf_opts = { buffer = true, noremap = true, silent = true }
      map("n", "<leader>snd", "<cmd>npm run dev<CR>", vim.tbl_extend("force", buf_opts, { desc = "Next.js dev server" }))
      map("n", "<leader>snb", "<cmd>npm run build<CR>", vim.tbl_extend("force", buf_opts, { desc = "Next.js build" }))
      map("n", "<leader>snt", "<cmd>npm run test<CR>", vim.tbl_extend("force", buf_opts, { desc = "Next.js tests" }))
      map("n", "<leader>snl", "<cmd>npm run lint<CR>", vim.tbl_extend("force", buf_opts, { desc = "Next.js lint" }))
      
      -- TypeScript LSP actions
      if pcall(require, "typescript") then
        local ts = require("typescript")
        map("n", "<leader>sno", ts.actions.organizeImports, vim.tbl_extend("force", buf_opts, { desc = "Organize Imports" }))
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
      bufmap("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format")
      
      -- Diagnostics
      bufmap("<leader>cd", vim.diagnostic.open_float, "Show Diagnostics")
      bufmap("<leader>cq", vim.diagnostic.setqflist, "Diagnostics to Quickfix")
      bufmap("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
      bufmap("]d", vim.diagnostic.goto_next, "Next Diagnostic")
    end,
  })
  
  -- ========================================
  -- UI & Theme keymaps
  -- ========================================
  
  -- Theme toggling
  map("n", "<leader>ut", "<cmd>ColorSchemeToggle<cr>", { desc = "Toggle Colorscheme" })
  map("n", "<leader>uT", "<cmd>ToggleTransparency<cr>", { desc = "Toggle Transparency" })
  
  -- Layouts
  map("n", "<leader>L1", "<cmd>Layout coding<cr>", { desc = "Coding Layout" })
  map("n", "<leader>L2", "<cmd>Layout terminal<cr>", { desc = "Terminal Layout" })
  map("n", "<leader>L3", "<cmd>Layout writing<cr>", { desc = "Writing Layout" })
  map("n", "<leader>L4", "<cmd>Layout debug<cr>", { desc = "Debug Layout" })
  
  -- Stack switching
  map("n", "<leader>usg", function()
    vim.cmd("StackFocus goth")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, vim.tbl_extend("force", opts, { desc = "Focus GOTH Stack + Dashboard" }))
  
  map("n", "<leader>usn", function()
    vim.cmd("StackFocus nextjs")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, vim.tbl_extend("force", opts, { desc = "Focus Next.js Stack + Dashboard" }))
  
  -- Terminal integration
  if pcall(require, "toggleterm") then
    map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal (float)" })
    map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal (horizontal)" })
    map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal (vertical)" })
    map("n", "<C-\\>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
  end
  
  -- Git
  map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
  map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "DiffView Open" })
end

  -- Snacks explorer (wrapped as function to satisfy keymap API)
  local ok_snacks, snacks = pcall(require, "snacks")
  if ok_snacks then
    map("n", "<leader>e", function()
      snacks.explorer()
    end, vim.tbl_extend("force", opts, { desc = "Snacks Explorer" }))
  end

  -- Stack switching + dashboard
  map("n", "<leader>usg", function()
    vim.cmd("StackFocus goth")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, vim.tbl_extend("force", opts, { desc = "Focus GOTH Stack + Dashboard" }))
  map("n", "<leader>usn", function()
    vim.cmd("StackFocus nextjs")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, vim.tbl_extend("force", opts, { desc = "Focus Next.js Stack + Dashboard" }))

  -- Oil filetype navigation
  local ok_oil, oil = pcall(require, "oil")
  if ok_oil then
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
  end

end

return M
