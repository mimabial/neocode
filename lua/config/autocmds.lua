local M = {}

local icons = require("lib.icons")

M.diagnostic_config = {
  virtual_text = {
    prefix = " ",
    spacing = 4,
    source = "if_many",
  },
  float = {
    border = "single",
    severity_sort = true,
    source = true,
    header = "",
    prefix = function(diagnostic)
      return icons.diagnostic_signs[diagnostic.severity] or ""
    end,
  },
  signs = { text = icons.diagnostic_signs },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
}

function M.setup()
  -- ========================================
  -- Diagnostics
  -- ========================================
  vim.diagnostic.config(vim.deepcopy(M.diagnostic_config))

  local diag_grp = vim.api.nvim_create_augroup("DiagnosticEvents", { clear = true })

  vim.api.nvim_create_autocmd("CursorHold", {
    group = diag_grp,
    desc = "Show diagnostics popup on cursor hold",
    callback = function()
      if vim.g.diagnostics_hover == false then
        return
      end
      local bufnr = vim.api.nvim_get_current_buf()
      local existing = vim.b[bufnr].diag_float_win
      if existing and vim.api.nvim_win_is_valid(existing) then
        return
      end
      local _, win = vim.diagnostic.open_float(nil, {
        focus_id = "diagnostic",
        focusable = true,
        -- BufLeave intentionally omitted: vim.lsp.util registers its own
        -- smart BufLeave that skips the close when we focus into the float.
        -- Adding our own here would close the float on focus-in (breaking cj).
        close_events = { "CursorMoved", "InsertEnter", "FocusLost", "WinScrolled" },
        border = "single",
        source = true,
        prefix = " ",
        scope = "cursor",
      })
      if win then
        vim.b[bufnr].diag_float_win = win
      end
    end,
  })

  vim.api.nvim_create_user_command("DiagnosticsReset", function()
    vim.diagnostic.config(vim.deepcopy(M.diagnostic_config))
    vim.notify("Diagnostics reset and reapplied", vim.log.levels.INFO)
  end, { desc = "Reset and reapply diagnostics" })

  -- ========================================
  -- Line Numbers
  -- ========================================
  local num_grp = vim.api.nvim_create_augroup("NumberToggle", { clear = true })

  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = num_grp,
    callback = function()
      local ft = vim.bo.filetype
      local skip = { oil = true, terminal = true, help = true, lazy = true, Trouble = true, trouble = true, notify = true }
      if not skip[ft] then
        vim.wo.number = true
        vim.wo.relativenumber = not vim.g.disable_relative_number
      end
    end,
    desc = "Enable numbers for normal buffers",
  })

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

  -- ========================================
  -- Visual Feedback
  -- ========================================
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      vim.hl.on_yank({ timeout = 300 })
    end,
    desc = "Highlight yanked text",
  })

  -- ========================================
  -- Window Management
  -- ========================================
  vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      vim.cmd("tabdo wincmd =")
    end,
    desc = "Equalize window sizes on resize",
  })

  vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
    desc = "Go to last edit position in file",
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "VimResume" }, {
    callback = function()
      local name = vim.fn.expand("%:t")
      vim.opt.titlestring = (name ~= "" and name or "Neovim") .. " - NVIM"
      vim.opt.title = true
    end,
    desc = "Set window title",
  })

  -- ========================================
  -- Filetype Settings
  -- ========================================
  local indent_grp = vim.api.nvim_create_augroup("FileTypeIndent", { clear = true })
  local indent_groups = {
    [2] = { "lua", "javascript", "typescript", "json", "html", "css", "yaml", "markdown", "tsx", "jsx" },
    [4] = { "go", "python", "rust", "c", "cpp" },
  }
  for width, fts in pairs(indent_groups) do
    vim.api.nvim_create_autocmd("FileType", {
      group = indent_grp,
      pattern = fts,
      callback = function()
        vim.bo.tabstop = width
        vim.bo.shiftwidth = width
      end,
      desc = "Set " .. width .. "-space indent",
    })
  end

  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
    desc = "Disable comment continuation",
  })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.theme",
    callback = function()
      vim.bo.filetype = "hyprlang"
    end,
    desc = "Set filetype for Hyprland .theme files",
  })

  -- GTK CSS files use @variable syntax which standard CSS LSP doesn't understand
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = {
      "*/.config/swaync/*.css",
      "*/.config/waybar/*.css",
      "*/.config/rofi/*.css",
      "*/.config/wofi/*.css",
      "*/gtk-3.0/*.css",
      "*/gtk-4.0/*.css",
    },
    callback = function()
      vim.bo.filetype = "css.gtk"
    end,
    desc = "Set GTK CSS filetype to avoid standard CSS LSP errors",
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "Trouble", "trouble", "qf", "help", "grug-far", "grug-far-history", "grug-far-help" },
    callback = function()
      vim.wo.winfixbuf = true
    end,
    desc = "Prevent buffer replacement in special windows",
  })

  -- ========================================
  -- Terminal
  -- ========================================
  -- Note: <C-h/j/k/l> navigation lives in plugins/ui/terminal.lua;
  -- directory-browsing in plugins/ui/explorer.lua (Oil).
  vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.cmd("startinsert")
      local buf = vim.api.nvim_get_current_buf()
      vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = buf, silent = true })
    end,
    desc = "Configure terminal settings",
  })

  vim.api.nvim_create_autocmd("TermClose", {
    pattern = "*lazygit",
    callback = function()
      pcall(function()
        require("gitsigns").refresh()
      end)
    end,
    desc = "Refresh gitsigns on lazygit exit",
  })

  -- ========================================
  -- Command-line Window
  -- ========================================
  vim.api.nvim_create_autocmd("CmdwinEnter", {
    callback = function()
      vim.keymap.set("n", "<Esc>", "<cmd>quit<cr>", { buffer = true, silent = true })
      vim.keymap.set("n", "q", "<cmd>quit<cr>", { buffer = true, silent = true })
    end,
    desc = "Close command-line window with Esc/q",
  })
end

return M
