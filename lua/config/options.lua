-- lua/config/keymaps.lua
-- Centralized keymap definitions with enhanced stack support

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

  -- Better indenting
  map("v", "<", "<gv", opts)
  map("v", ">", ">gv", opts)

  -- Move lines up and down
  map("v", "J", ":m '>+1<CR>gv=gv", opts)
  map("v", "K", ":m '<-2<CR>gv=gv", opts)

  -- Keep cursor centered when searching
  map("n", "n", "nzzzv", opts)
  map("n", "N", "Nzzzv", opts)

  -- Keep cursor centered when joining lines
  map("n", "J", "mzJ`z", opts)

  -- ========================================
  -- Buffer and window management
  -- ========================================

  -- Buffer navigation
  map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
  map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
  map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
  map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })

  -- Window maximization toggle
  map("n", "<leader>wm", function()
    local winid = vim.api.nvim_get_current_win()
    if M._latest_zoom_winid ~= winid then
      M._latest_zoom_winid = winid
      M._latest_zoom_layout = vim.fn.winrestcmd()
      vim.cmd("wincmd |")
      vim.cmd("wincmd _")
    else
      vim.cmd(M._latest_zoom_layout)
      M._latest_zoom_winid = nil
      M._latest_zoom_layout = nil
    end
  end, { desc = "Toggle window maximize" })

  -- ========================================
  -- File explorer
  -- ========================================

  -- Oil.nvim
  map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
  map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Explorer (Oil)" })

  -- ========================================
  -- Search and navigation
  -- ========================================

  -- Search with Snacks/Telescope
  local ok_picker, picker = pcall(require, "snacks.picker")
  
  if ok_picker then
    -- Snacks picker
    map("n", "<leader>ff", function() picker.files() end, { desc = "Find files" })
    map("n", "<leader>fg", function() picker.grep() end, { desc = "Live grep" })
    map("n", "<leader>fb", function() picker.buffers() end, { desc = "Find buffers" })
    map("n", "<leader>fr", function() picker.recent() end, { desc = "Recent files" })
    map("n", "<leader>fh", function() picker.help() end, { desc = "Help tags" })
    map("n", "<leader>fs", function() picker.lsp_symbols() end, { desc = "Find symbols" })
    map("n", "<leader>fd", function() picker.diagnostics() end, { desc = "Diagnostics" })
  else
    -- Fallback to Telescope if Snacks not available
    local has_telescope, _ = pcall(require, "telescope.builtin")
    if has_telescope then
      local telescope = require("telescope.builtin")
      map("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
      map("n", "<leader>fg", telescope.live_grep, { desc = "Live grep" })
      map("n", "<leader>fb", telescope.buffers, { desc = "Find buffers" })
      map("n", "<leader>fr", telescope.oldfiles, { desc = "Recent files" })
      map("n", "<leader>fh", telescope.help_tags, { desc = "Help tags" })
    end
  end

  -- ========================================
  -- Git integration
  -- ========================================

  -- Git keymaps
  map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
  map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diffview open" })
  map("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "Diffview close" })
  map("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push" })
  map("n", "<leader>gl", "<cmd>Git pull<cr>", { desc = "Git pull" })

  -- GitSigns navigation (depends on gitsigns.nvim)
  if package.loaded["gitsigns"] then
    map("n", "]g", function() require("gitsigns").next_hunk() end, { desc = "Next git hunk" })
    map("n", "[g", function() require("gitsigns").prev_hunk() end, { desc = "Previous git hunk" })
    map("n", "<leader>hs", function() require("gitsigns").stage_hunk() end, { desc = "Stage hunk" })
    map("n", "<leader>hr", function() require("gitsigns").reset_hunk() end, { desc = "Reset hunk" })
    map("n", "<leader>hb", function() require("gitsigns").blame_line() end, { desc = "Blame line" })
    map("n", "<leader>hd", function() require("gitsigns").diffthis() end, { desc = "Diff this" })
  end

  -- ========================================
  -- LSP general keymaps
  -- ========================================

  -- Applied in lsp.lua via on_attach

  -- ========================================
  -- Terminal integration
  -- ========================================

  -- ToggleTerm mappings
  map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal float" })
  map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal horizontal" })
  map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal vertical" })
  map("n", "<C-\\>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })

  -- ========================================
  -- UI and theme keymaps
  -- ========================================

  -- Theme toggling
  map("n", "<leader>ut", "<cmd>ColorSchemeToggle<cr>", { desc = "Toggle colorscheme" })
  map("n", "<leader>uT", "<cmd>ToggleTransparency<cr>", { desc = "Toggle transparency" })

  -- Layout presets
  map("n", "<leader>L1", "<cmd>Layout coding<cr>", { desc = "Coding layout" })
  map("n", "<leader>L2", "<cmd>Layout terminal<cr>", { desc = "Terminal layout" })
  map("n", "<leader>L3", "<cmd>Layout writing<cr>", { desc = "Writing layout" })
  map("n", "<leader>L4", "<cmd>Layout debug<cr>", { desc = "Debug layout" })

  -- Toggles
  map("n", "<leader>uc", function()
    -- Toggle Copilot
    if package.loaded["copilot"] then
      local copilot = require("copilot")
      if copilot.status then
        local enabled = copilot.status.enabled and true or false
        if enabled then
          vim.cmd("Copilot disable")
          vim.notify(" Copilot disabled", vim.log.levels.INFO)
        else
          vim.cmd("Copilot enable")
          vim.notify(" Copilot enabled", vim.log.levels.INFO)
        end
      end
    end
  end, { desc = "Toggle Copilot" })

  map("n", "<leader>ui", function()
    -- Toggle Codeium
    if vim.fn.exists("g:codeium_enabled") == 1 then
      if vim.g.codeium_enabled then
        vim.cmd("CodeiumDisable")
        vim.notify("󰧑 Codeium disabled", vim.log.levels.INFO)
      else
        vim.cmd("CodeiumEnable")
        vim.notify("󰧑 Codeium enabled", vim.log.levels.INFO)
      end
    end
  end, { desc = "Toggle Codeium" })

  -- ========================================
  -- Stack-specific keymaps
  -- ========================================

  -- Stack switching
  map("n", "<leader>usg", function()
    vim.cmd("StackFocus goth")
    vim.notify("󰟓 Switched to GOTH stack", vim.log.levels.INFO)
  end, { desc = "Focus GOTH stack" })

  map("n", "<leader>usn", function()
    vim.cmd("StackFocus nextjs")
    vim.notify(" Switched to Next.js stack", vim.log.levels.INFO)
  end, { desc = "Focus Next.js stack" })

  map("n", "<leader>usb", function()
    vim.cmd("StackFocus both")
    vim.notify("󰡄 Using both stacks", vim.log.levels.INFO)
  end, { desc = "Use both stacks" })

  -- GOTH stack-specific keymaps for all users
  map("n", "<leader>sg", "<cmd>GOTHServer<cr>", { desc = "GOTH server" })
  map("n", "<leader>sr", "<cmd>GoRun<cr>", { desc = "Go run" })
  map("n", "<leader>st", "<cmd>GoTest<cr>", { desc = "Go test" })
  map("n", "<leader>sT", "<cmd>TemplGenerate<cr>", { desc = "Templ generate" })
  map("n", "<leader>sn", "<cmd>TemplNew<cr>", { desc = "New Templ component" })

  -- Next.js stack-specific keymaps for all users
  map("n", "<leader>nd", "<cmd>NextDev<cr>", { desc = "Next.js dev server" })
  map("n", "<leader>nb", "<cmd>NextBuild<cr>", { desc = "Next.js build" })
  map("n, "<leader>nl", "<cmd>NextLint<cr>", { desc = "Next.js lint" })
  map("n", "<leader>nc", "<cmd>NextNewComponent<cr>", { desc = "New Next.js component" })
  map("n", "<leader>np", "<cmd>NextNewPage<cr>", { desc = "New Next.js page" })
  
  -- Create file-type specific keymaps through autocmd
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "go", "templ" },
    callback = function()
      -- GOTH stack file-specific keymaps
      local buf_opts = { buffer = true, noremap = true, silent = true }
      map("n", "<leader>gr", "<cmd>GoRun<CR>", vim.tbl_extend("force", buf_opts, { desc = "Run Go project" }))
      map("n", "<leader>gt", "<cmd>GoTest<CR>", vim.tbl_extend("force", buf_opts, { desc = "Run Go tests" }))
      map("n", "<leader>gi", "<cmd>GoImports<CR>", vim.tbl_extend("force", buf_opts, { desc = "Go imports" }))
      map("n", "<leader>gf", "<cmd>GoFmt<CR>", vim.tbl_extend("force", buf_opts, { desc = "Go format" }))
      
      -- Add extra mappings if go.nvim is available
      if package.loaded["go"] then
        map("n", "<leader>ge", "<cmd>GoIfErr<CR>", vim.tbl_extend("force", buf_opts, { desc = "Add if err" }))
        map("n", "<leader>gfs", "<cmd>GoFillStruct<CR>", vim.tbl_extend("force", buf_opts, { desc = "Fill struct" }))
      end
      
      -- Templ-specific keymaps
      if vim.bo.filetype == "templ" then
        map("n", "<leader>tg", "<cmd>TemplGenerate<CR>", vim.tbl_extend("force", buf_opts, { desc = "Generate templates" }))
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    callback = function()
      -- Next.js stack file-specific keymaps
      local buf_opts = { buffer = true, noremap = true, silent = true }
      map("n", "<leader>nr", "<cmd>NextDev<CR>", vim.tbl_extend("force", buf_opts, { desc = "Run Next.js dev" }))
      map("n", "<leader>nb", "<cmd>NextBuild<CR>", vim.tbl_extend("force", buf_opts, { desc = "Build Next.js" }))
      map("n", "<leader>nl", "<cmd>NextLint<CR>", vim.tbl_extend("force", buf_opts, { desc = "Lint Next.js" }))
      
      -- TypeScript-specific keymaps
      if package.loaded["typescript-tools"] then
        local api = require("typescript-tools.api")
        map("n", "<leader>toi", api.organize_imports, vim.tbl_extend("force", buf_opts, { desc = "Organize imports" }))
        map("n", "<leader>tmi", api.add_missing_imports, vim.tbl_extend("force", buf_opts, { desc = "Add missing imports" }))
        map("n", "<leader>tru", api.remove_unused, vim.tbl_extend("force", buf_opts, { desc = "Remove unused" }))
        map("n", "<leader>tfa", api.fix_all, vim.tbl_extend("force", buf_opts, { desc = "Fix all issues" }))
      end
    end,
  })
end

return M
