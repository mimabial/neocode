local M = {}

function M.setup()
  -- Helper function for setting keymaps
  local function map(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- Safe require that falls back gracefully
  local function safe_require(mod)
    local ok, module = pcall(require, mod)
    if not ok then
      vim.notify(string.format("Error loading module '%s': %s", mod, module), vim.log.levels.WARN)
      return nil
    end
    return module
  end

  -- ========================================
  -- Leader key
  -- ========================================
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- ========================================
  -- General/Plugin Management
  -- ========================================
  map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })

  -- ========================================
  -- Editing
  -- ========================================
  -- Keep selection when indenting in visual mode
  map("v", ">", ">gv", { desc = "Indent and keep selection" })
  map("v", "<", "<gv", { desc = "Outdent and keep selection" })

  -- Move lines up and down
  map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
  map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

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
  map("n", "<leader>e", function()
    -- Try to use oil first, fallback to nvim-tree, then built-in explorer
    local ok, oil = pcall(require, "oil")
    if ok then
      oil.open()
    else
      -- Try nvim-tree next
      local tree_ok, _ = pcall(require, "nvim-tree.api")
      if tree_ok then
        vim.cmd("NvimTreeToggle")
      else
        -- Ultimate fallback to built-in
        vim.cmd("Ex")
      end
    end
  end, { desc = "Open File Explorer" })

  map("n", "-", function()
    local ok, oil = pcall(require, "oil")
    if ok then
      oil.open()
    else
      vim.cmd("Ex")
    end
  end, { desc = "File Explorer (parent dir)" })

  -- ========================================
  -- Symbols Outline
  -- ========================================
  map("n", "<leader>cs", "<cmd>SymbolsOutline<cr>", { desc = "Symbols Outline" })

  -- ========================================
  -- Stack-Specific Commands
  -- ========================================

  map("n", "<leader>sg", function()
    local has_go = vim.fn.glob("*.go") ~= ""
    if has_go then
      vim.cmd("GoTest")
    else
      vim.notify("No Go files detected", vim.log.levels.WARN)
    end
  end, { desc = "Go: Run tests" })

  map("n", "<leader>sn", function()
    local has_package = vim.fn.glob("package.json") ~= ""
    if has_package then
      vim.cmd("terminal npm run dev")
    else
      vim.notify("No package.json detected", vim.log.levels.WARN)
    end
  end, { desc = "Next.js: Start dev server" })

  -- ========================================
  -- Git Integration (Core Commands Only)
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
  -- UI & Theme
  -- ========================================
  -- Theme toggling
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

  -- ========================================
  -- AI Provider Management
  -- ========================================
  map("n", "<leader>ac", "<cmd>AICycle<cr>", { desc = "Cycle AI providers" })
  map("n", "<leader>ad", "<cmd>AIDisable<cr>", { desc = "Disable AI providers" })
  map("n", "<leader>as", "<cmd>AIStatus<cr>", { desc = "Show active AI provider" })
  map("n", "<leader>ap", "<cmd>AICopilot<cr>", { desc = "Toggle Copilot" })
  map("n", "<leader>am", "<cmd>AICodeium<cr>", { desc = "Toggle Codeium" })

  -- ========================================
  -- Layout Presets
  -- ========================================
  map("n", "<leader>L1", "<cmd>Layout coding<cr>", { desc = "Coding Layout" })
  map("n", "<leader>L2", "<cmd>Layout terminal<cr>", { desc = "Terminal Layout" })
  map("n", "<leader>L3", "<cmd>Layout writing<cr>", { desc = "Writing Layout" })
  map("n", "<leader>L4", "<cmd>Layout debug<cr>", { desc = "Debug Layout" })

  -- ========================================
  -- Dashboard
  -- ========================================
  map("n", "<leader>d", "<cmd>Alpha<cr>", { desc = "Open Dashboard" })

  -- ========================================
  -- Diagnostics
  -- ========================================
  map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
  map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
  map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
  map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
end

return M
