-- lua/config/keymaps.lua
-- Standardized keymap definitions with consistent structure and telescope integration

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
  -- Telescope (search & find)
  -- ========================================
  -- Core search functionality
  map("n", "<leader>ff", function()
    -- Attempt to use Telescope first
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
      telescope.find_files()
    else
      -- Fall back to snacks if available
      local snacks_ok, snacks = pcall(require, "snacks.picker")
      if snacks_ok and snacks.files then
        snacks.files()
      else
        -- Ultimate fallback to built-in
        vim.cmd("find")
      end
    end
  end, { desc = "Find Files" })

  map("n", "<leader>fg", function()
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
      telescope.live_grep()
    else
      local snacks_ok, snacks = pcall(require, "snacks.picker")
      if snacks_ok and snacks.grep then
        snacks.grep()
      else
        -- Fallback to built-in grep
        vim.ui.input({ prompt = "Search pattern: " }, function(input)
          if input then
            vim.cmd("vimgrep " .. input .. " **/*")
            vim.cmd("copen")
          end
        end)
      end
    end
  end, { desc = "Find Text (Grep)" })

  map("n", "<leader>fb", function()
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
      telescope.buffers()
    else
      local snacks_ok, snacks = pcall(require, "snacks.picker")
      if snacks_ok and snacks.buffers then
        snacks.buffers()
      else
        vim.cmd("ls")
      end
    end
  end, { desc = "Find Buffers" })

  map("n", "<leader>fr", function()
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
      telescope.oldfiles()
    else
      local snacks_ok, snacks = pcall(require, "snacks.picker")
      if snacks_ok and snacks.recent then
        snacks.recent()
      else
        vim.cmd("browse oldfiles")
      end
    end
  end, { desc = "Recent Files" })

  map("n", "<leader>fh", function()
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
      telescope.help_tags()
    else
      local snacks_ok, snacks = pcall(require, "snacks.picker")
      if snacks_ok and snacks.help then
        snacks.help()
      else
        vim.cmd("help")
      end
    end
  end, { desc = "Find Help" })

  -- LSP integration with Telescope
  map("n", "<leader>fd", function()
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
      telescope.diagnostics({ bufnr = 0 })
    else
      -- Fallback to builtin diagnostics
      vim.diagnostic.setloclist()
    end
  end, { desc = "Document Diagnostics" })

  map("n", "<leader>fD", function()
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
      telescope.diagnostics()
    else
      -- Fallback to builtin diagnostics
      vim.diagnostic.setqflist()
    end
  end, { desc = "Workspace Diagnostics" })

  -- ========================================
  -- Stack-Specific Commands
  -- ========================================
  -- GOTH stack
  map("n", "<leader>sg", function()
    local ok, stacks = pcall(require, "utils.stacks")
    if ok and stacks.configure_stack then
      stacks.configure_stack("goth")
      -- Try to open dashboard if available
      pcall(function()
        if package.loaded["snacks.dashboard"] then
          require("snacks.dashboard").open()
        end
      end)
    else
      vim.notify("Stack configuration module not available", vim.log.levels.WARN)
    end
  end, { desc = "Focus GOTH Stack" })

  -- Next.js stack
  map("n", "<leader>sn", function()
    local ok, stacks = pcall(require, "utils.stacks")
    if ok and stacks.configure_stack then
      stacks.configure_stack("nextjs")
      -- Try to open dashboard if available
      pcall(function()
        if package.loaded["snacks.dashboard"] then
          require("snacks.dashboard").open()
        end
      end)
    else
      vim.notify("Stack configuration module not available", vim.log.levels.WARN)
    end
  end, { desc = "Focus Next.js Stack" })

  -- Both stacks
  map("n", "<leader>sb", function()
    local ok, stacks = pcall(require, "utils.stacks")
    if ok and stacks.configure_stack then
      stacks.configure_stack("both")
      -- Try to open dashboard if available
      pcall(function()
        if package.loaded["snacks.dashboard"] then
          require("snacks.dashboard").open()
        end
      end)
    else
      vim.notify("Stack configuration module not available", vim.log.levels.WARN)
    end
  end, { desc = "Focus Both Stacks" })

  -- ========================================
  -- Terminal Integration
  -- ========================================
  map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal (float)" })
  map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal (horizontal)" })
  map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal (vertical)" })
  map("n", "<C-\\>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })

  -- ========================================
  -- Git Integration
  -- ========================================
  map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
  map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "DiffView Open" })
  map("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git Status" })
  map("n", "<leader>gp", "<cmd>Git pull<cr>", { desc = "Git Pull" })
  map("n", "<leader>gP", "<cmd>Git push<cr>", { desc = "Git Push" })

  -- ========================================
  -- UI & Theme
  -- ========================================
  -- Theme toggling
  map("n", "<leader>us", "<cmd>CycleColorScheme<cr>", { desc = "Cycle color scheme" })
  map("n", "<leader>uS", "<cmd>ColorScheme<cr>", { desc = "Select color scheme" })
  map("n", "<leader>uv", "<cmd>CycleColorVariant<cr>", { desc = "Cycle color variant" })
  map("n", "<leader>uV", "<cmd>ColorVariant<cr>", { desc = "Select color variant" })
  map("n", "<leader>ub", "<cmd>ToggleBackgroundTransparency<cr>", { desc = "Toggle background transparency" })

  -- AI tools
  map("n", "<leader>uc", "<cmd>lua require('copilot.command').toggle()<cr>", { desc = "Toggle Copilot" })
  map("n", "<leader>ui", "<cmd>CodeiumToggle<cr>", { desc = "Toggle Codeium" })

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
  map("n", "<leader>d", function()
    local ok, dashboard = pcall(require, "snacks.dashboard")
    if ok then
      dashboard.open()
    else
      vim.notify("Dashboard not available", vim.log.levels.INFO)
    end
  end, { desc = "Open Dashboard" })

  -- ========================================
  -- Diagnostics
  -- ========================================
  map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
  map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
  map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
  map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
end

return M
