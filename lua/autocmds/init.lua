local M = {}

function M.setup()
  -- 1) Line number toggling
  local num_grp = vim.api.nvim_create_augroup("NumToggle", { clear = true })
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = num_grp,
    callback = function()
      local ft = vim.bo.filetype
      if ft:match("^(oil|terminal|help|lazy)$") then
        return
      end
      vim.wo.number = true
      if not vim.g.disable_relative_number then
        vim.wo.relativenumber = true
      end
    end,
    desc = "Enable numbers for normal buffers",
  })
  vim.api.nvim_create_autocmd({ "InsertEnter", "BufLeave", "FocusLost", "WinLeave" }, {
    group = num_grp,
    callback = function()
      if vim.wo.number then
        vim.wo.relativenumber = false
      end
    end,
    desc = "Disable relative numbers when leaving buffer or entering insert mode",
  })
  vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "FocusGained", "WinEnter" }, {
    group = num_grp,
    callback = function()
      if vim.wo.number and not vim.g.disable_relative_number then
        vim.wo.relativenumber = true
      end
    end,
    desc = "Re-enable relative numbers when entering buffer or leaving insert mode",
  })

  -- 2) Yank highlighting
  vim.api.nvim_create_augroup("YankHighlight", { clear = true })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = "YankHighlight",
    callback = function()
      vim.highlight.on_yank({ timeout = 300 })
    end,
    desc = "Highlight yanked text",
  })

  -- 3) Auto-resize splits
  vim.api.nvim_create_augroup("AutoResizeSplits", { clear = true })
  vim.api.nvim_create_autocmd("VimResized", {
    group = "AutoResizeSplits",
    callback = function()
      vim.cmd("tabdo wincmd =")
    end,
    desc = "Equalize window sizes on resize",
  })

  -- 4) Restore cursor position
  vim.api.nvim_create_augroup("RestoreCursor", { clear = true })
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = "RestoreCursor",
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
    desc = "Go to last edit position in file",
  })

  -- 5) Filetype-specific indentation
  local indent_grp = vim.api.nvim_create_augroup("FileTypeIndent", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = indent_grp,
    pattern = {
      "lua",
      "javascript",
      "typescript",
      "json",
      "html",
      "css",
      "yaml",
      "markdown",
      "tsx",
      "jsx",
    },
    callback = function()
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
    end,
    desc = "Set 2-space indent for web and templating files",
  })
  vim.api.nvim_create_autocmd("FileType", {
    group = indent_grp,
    pattern = { "go", "python", "rust", "c", "cpp" },
    callback = function()
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
    end,
    desc = "Set 4-space indent for compiled languages",
  })

  -- 6) Directory auto-open
  vim.api.nvim_create_augroup("DirExplorer", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = "DirExplorer",
    callback = function()
      local name = vim.api.nvim_buf_get_name(0)
      if vim.fn.isdirectory(name) == 1 then
        require("oil").open(name)
      end
    end,
    desc = "Open directory path in configured explorer",
  })

  -- 7) Linting on save/open
  vim.api.nvim_create_augroup("AutoLint", { clear = true })
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    group = "AutoLint",
    callback = function()
      local ok, lint = pcall(require, "lint")
      if ok then
        lint.try_lint()
      end
    end,
    desc = "Run lint checks on file save or open",
  })

  -- 8) Exit notify windows with 'q'
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "notify",
    callback = function()
      -- map 'q' to close the float
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true, desc = "Close notification" })
      -- (optionally) map <Esc> as well
      vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = true, silent = true })
    end,
  })

  -- 9) Auto-reload changed files
  vim.api.nvim_create_augroup("AutoReload", { clear = true })
  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group = "AutoReload",
    callback = function()
      if vim.fn.mode() ~= "c" and not vim.bo.modified and vim.fn.expand("%") ~= "" then
        vim.cmd("checktime")
      end
    end,
    desc = "Reload file if changed outside Neovim",
  })

  -- 10) Terminal mode settings
  vim.api.nvim_create_augroup("TerminalMode", { clear = true })
  vim.api.nvim_create_autocmd("TermOpen", {
    group = "TerminalMode",
    callback = function()
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.cmd("startinsert")
      local buf = vim.api.nvim_get_current_buf()
      -- Define terminal-mode mappings
      local term_mappings = {
        ["<Esc>"] = "<C-\\><C-n>",
        ["<C-h>"] = "<C-\\><C-n><C-w>h",
        ["<C-j>"] = "<C-\\><C-n><C-w>j",
        ["<C-k>"] = "<C-\\><C-n><C-w>k",
        ["<C-l>"] = "<C-\\><C-n><C-w>l",
      }
      for lhs, rhs in pairs(term_mappings) do
        vim.keymap.set("t", lhs, rhs, { buffer = buf, silent = true })
      end
    end,
    desc = "Configure terminal keymaps",
  })

  -- 11) Refresh gitsigns after lazygit
  local git_grp = vim.api.nvim_create_augroup("GitSignsRefresh", { clear = true })
  vim.api.nvim_create_autocmd("TermClose", {
    group = git_grp,
    pattern = "*lazygit",
    desc = "Refresh gitsigns on lazygit exit",
    callback = function()
      local ok, gs = pcall(require, "gitsigns")
      if ok and gs.refresh then
        gs.refresh()
      end
    end,
  })

  -- 12) Update window title
  vim.api.nvim_create_augroup("WinTitle", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "VimResume" }, {
    group = "WinTitle",
    callback = function()
      local name = vim.fn.expand("%:t")
      if name == "" then
        name = "Untitled"
      end
      vim.opt.titlestring = string.format("%s - NVIM", name)
      vim.opt.title = true
    end,
    desc = "Set window title",
  })

  -- 13) Disable auto comment continuation
  vim.api.nvim_create_augroup("NoCommentCont", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = "NoCommentCont",
    pattern = "*",
    callback = function()
      vim.bo.formatoptions = vim.bo.formatoptions:gsub("[cro]", "")
    end,
    desc = "Disable auto comment continuation",
  })
end

return M
