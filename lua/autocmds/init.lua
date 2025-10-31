local M = {}

function M.setup()
  -- 1) Line number toggling
  local num_grp = vim.api.nvim_create_augroup("NumberToggle", { clear = true })

  -- Enable numbers for normal buffers only once
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = num_grp,
    callback = function()
      local ft = vim.bo.filetype
      if not ft:match("^(oil|terminal|help|lazy|Trouble|trouble|notify)$") then
        vim.wo.number = true
        vim.wo.relativenumber = not vim.g.disable_relative_number
      end
    end,
    desc = "Enable numbers for normal buffers",
  })

  -- Toggle relative numbers on focus/mode changes
  vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
    group = num_grp,
    callback = function()
      if vim.wo.number then
        vim.wo.relativenumber = false
      end
    end,
    desc = "Disable relative numbers on insert/unfocus",
  })

  vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
    group = num_grp,
    callback = function()
      if vim.wo.number and not vim.g.disable_relative_number then
        vim.wo.relativenumber = true
      end
    end,
    desc = "Enable relative numbers on normal/focus",
  })

  -- 2) Yank highlighting
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      vim.highlight.on_yank({ timeout = 300 })
    end,
    desc = "Highlight yanked text",
  })

  -- 3) Auto-resize splits
  vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      vim.cmd("tabdo wincmd =")
    end,
    desc = "Equalize window sizes on resize",
  })

  -- 4) Restore cursor position
  vim.api.nvim_create_autocmd("BufReadPost", {
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
    pattern = { "lua", "javascript", "typescript", "json", "html", "css", "yaml", "markdown", "tsx", "jsx" },
    callback = function()
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
    end,
    desc = "Set 2-space indent for web languages",
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
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
      local name = vim.api.nvim_buf_get_name(0)
      if vim.fn.isdirectory(name) == 1 then
        require("oil").open(name)
      end
    end,
    desc = "Open directory path in configured explorer",
  })

  -- 7) Terminal mode settings
  vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.cmd("startinsert")

      local buf = vim.api.nvim_get_current_buf()
      local opts = { buffer = buf, silent = true }
      vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
      vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", opts)
      vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", opts)
      vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", opts)
      vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", opts)
    end,
    desc = "Configure terminal keymaps",
  })

  -- 8) Refresh gitsigns after lazygit
  vim.api.nvim_create_autocmd("TermClose", {
    pattern = "*lazygit",
    callback = function()
      pcall(function()
        require("gitsigns").refresh()
      end)
    end,
    desc = "Refresh gitsigns on lazygit exit",
  })

  -- 9) Update window title
  vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "VimResume" }, {
    callback = function()
      local name = vim.fn.expand("%:t")
      vim.opt.titlestring = (name ~= "" and name or "Neovim") .. " - NVIM"
      vim.opt.title = true
    end,
    desc = "Set window title",
  })

  -- 10) Prevent auto-comment continuation (runs after ftplugin to reset option)
  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
    desc = "Disable comment continuation",
  })

  -- 11) Command-line window keymaps
  vim.api.nvim_create_autocmd("CmdwinEnter", {
    callback = function()
      vim.keymap.set("n", "<Esc>", "<cmd>quit<cr>", { buffer = true, silent = true })
      vim.keymap.set("n", "q", "<cmd>quit<cr>", { buffer = true, silent = true })
    end,
    desc = "Close command-line window with Esc/q",
  })

  -- 12) Filetype detection for .theme files (Hyprland theme configs)
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.theme",
    callback = function()
      vim.bo.filetype = "hyprlang"
    end,
    desc = "Set filetype for Hyprland .theme files",
  })

  -- 13) Force bashls to attach to zsh files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "zsh",
    callback = function()
      vim.lsp.start({
        name = "bashls",
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh", "bash", "zsh" },
        root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
      })
    end,
  })

  -- 14) Protect special windows from buffer replacement
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "spectre_panel", "Trouble", "trouble", "qf", "help" },
    callback = function()
      vim.wo.winfixbuf = true
    end,
    desc = "Prevent buffer replacement in special windows",
  })

  -- 15) Return to previous window when closing a window
  vim.api.nvim_create_autocmd("WinClosed", {
    nested = true,
    callback = function(args)
      -- Only run if we're currently in a different window than the one being closed
      if vim.api.nvim_get_current_win() ~= tonumber(args.match) then
        return
      end
      -- Return to previous window
      pcall(vim.cmd.wincmd, "p")
    end,
    desc = "Return to previous window on close",
  })
end

return M
