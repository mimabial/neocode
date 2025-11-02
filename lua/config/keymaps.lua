local M = {}

function M.setup()
  -- Helper function for setting keymaps
  local function map(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- ========================================
  -- LSP Keymaps (set up via autocmd)
  -- ========================================
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local opts = { buffer = args.buf, silent = true }

      -- Navigation
      map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
      map("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
      map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find references" }))
      map("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
      map("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))

      -- Information
      map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Show hover information" }))
      map("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))

      -- Actions
      map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
      map("n", "<leader>cr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))

      -- Diagnostics
      map("n", "<leader>cd", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostics" }))
      map("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
      map("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
      map(
        "n",
        "<leader>cq",
        vim.diagnostic.setloclist,
        vim.tbl_extend("force", opts, { desc = "Diagnostics to loclist" })
      )
    end,
  })

  -- ========================================
  -- General/Plugin Management
  -- ========================================
  map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })

  -- ========================================
  -- Editing
  -- ========================================
  map("n", "x", '"_x', { desc = "Don't copy deleted character" })
  map("v", "p", '"_dP', { desc = "Keep yanked text when pasting" })

  -- Keep selection when indenting in visual mode
  map("v", ">", ">gv", { desc = "Indent and keep selection" })
  map("v", "<", "<gv", { desc = "Outdent and keep selection" })

  -- Move lines up and down
  map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
  map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

  -- Vertical scroll and center
  map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
  map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

  -- Keep cursor centered when joining lines or searching
  map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })
  map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
  map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

  -- ========================================
  -- Navigation
  -- ========================================
  -- Window navigation
  map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
  map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
  map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
  map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

  -- Window splits
  map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
  map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split horizontal" })
  map("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close window" })
  map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Close other windows" })

  -- Resize windows with arrows
  map("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height" })
  map("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height" })
  map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
  map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

  -- Better line movement
  map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move down (display lines)" })
  map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move up (display lines)" })

  -- ========================================
  -- Buffer management
  -- ========================================
  map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
  map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
  map("n", "<leader>bf", "<cmd>bfirst<cr>", { desc = "First Buffer" })
  map("n", "<leader>bl", "<cmd>blast<cr>", { desc = "Last Buffer" })
  map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })
  map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })

  -- Buffer navigation with Shift
  map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
  map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

  -- File explorer
  map("n", "-", function()
    require("oil").open()
  end, { desc = "Open Oil Explorer (parent dir)" })

  -- ========================================
  -- Git Integration
  -- ========================================
  map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
  map("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git Status" })
  map("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git Commit" })
  map("n", "<leader>gb", "<cmd>Git branch<cr>", { desc = "Git Branch" })
  map("n", "<leader>gm", "<cmd>Git merge<cr>", { desc = "Git Merge" })
  map("n", "<leader>gr", "<cmd>Git rebase<cr>", { desc = "Git Rebase" })
  map("n", "<leader>gl", "<cmd>Git log --oneline<cr>", { desc = "Git Log" })
  map("n", "<leader>gp", "<cmd>Git pull<cr>", { desc = "Git Pull" })
  map("n", "<leader>gP", "<cmd>Git push<cr>", { desc = "Git Push" })
  map("n", "<leader>gf", "<cmd>Git fetch<cr>", { desc = "Git Fetch" })
  map("n", "<leader>ga", "<cmd>Git add .<cr>", { desc = "Git Add All" })

  -- Note:
  -- <leader>go* - Reserved for octo (handled by plugin keys)
  -- <leader>fG* - Telescope git operations (handled by telescope keys)

  -- ========================================
  -- UI/display setting
  -- ========================================
  -- Theme Management
  map("n", "<leader>us", "<cmd>CycleColorScheme<cr>", { desc = "Cycle color scheme" })
  map("n", "<leader>uS", "<cmd>ColorScheme<cr>", { desc = "Select color scheme" })
  map("n", "<leader>uv", "<cmd>CycleColorVariant<cr>", { desc = "Cycle color variant" })
  map("n", "<leader>uV", "<cmd>ColorVariant<cr>", { desc = "Select color variant" })
  map("n", "<leader>ub", "<cmd>ToggleBackgroundTransparency<cr>", { desc = "Toggle background transparency" })
  -- System theme integration
  map("n", "<leader>uy", "<cmd>SystemSync<cr>", { desc = "Sync with system theme" })
  map("n", "<leader>uY", "<cmd>SystemDetect<cr>", { desc = "Detect system theme" })
  map("n", "<leader>uz", "<cmd>SystemSetTheme<cr>", { desc = "Set system NVIM_SCHEME" })
  map("n", "<leader>uL", "<cmd>SystemListThemes<cr>", { desc = "List available system themes" })
  -- Toggle line wrapping
  map("n", "<leader>tw", "<cmd>set wrap!<CR>", { desc = "Toggle line wrap" })

  -- ========================================
  -- AI Provider Management
  -- ========================================
  map("n", "<leader>as", "<cmd>AIStatus<cr>", { desc = "Show active AI provider" })
  map("n", "<leader>at", "<cmd>AIToggle<cr>", { desc = "Toggle AI provider" })

  -- ========================================
  -- Navic & Outline
  -- ========================================
  map("n", "<leader>nb", "<cmd>DropbarToggle<cr>", { desc = "Toggle breadcrumbs" })
  map("n", "<leader>o", "<cmd>Outline<cr>", { desc = "Toggle outline" })

  -- ========================================
  -- Layout Presets
  -- ========================================
  map("n", "<leader>L1", "<cmd>Layout coding<cr>", { desc = "Coding Layout" })
  map("n", "<leader>L2", "<cmd>Layout terminal<cr>", { desc = "Terminal Layout" })
  map("n", "<leader>L3", "<cmd>Layout writing<cr>", { desc = "Writing Layout" })
  map("n", "<leader>L4", "<cmd>Layout debug<cr>", { desc = "Debug Layout" })

  -- ========================================
  -- Diagnostics
  -- ========================================
  map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
  map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
  map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
  map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
end

return M
