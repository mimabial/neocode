-- lua/config/autocmds.lua
-- Refactored autocommand definitions organized into feature-specific augroups

local M = {}

-- Helper to safely require optional modules
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[Autocmds] Could not load '%s': %s", mod, m), vim.log.levels.WARN)
    return nil
  end
  return m
end

function M.setup()
  -- 1) Line number toggling
  local num_grp = vim.api.nvim_create_augroup("NumToggle", { clear = true })
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = num_grp,
    callback = function()
      local ft = vim.bo.filetype
      if ft:match("^(oil|terminal|starter|help|lazy)$") then
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
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = num_grp,
    callback = function()
      if vim.wo.number and not vim.g.disable_relative_number then
        vim.wo.relativenumber = true
      end
    end,
    desc = "Re-enable relative numbers after insert",
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
      "svelte",
      "tsx",
      "jsx",
      "templ",
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
        local explorer = vim.g.default_explorer or "oil"
        if explorer == "snacks" and safe_require("snacks.explorer") then
          require("snacks.explorer").open({ path = name })
        elseif safe_require("oil") then
          require("oil").open(name)
        else
          vim.notify("No explorer available for directory", vim.log.levels.WARN)
        end
      end
    end,
    desc = "Open directory path in configured explorer",
  })

  -- 7) Linting on save/open
  vim.api.nvim_create_augroup("AutoLint", { clear = true })
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    group = "AutoLint",
    callback = function()
      local lint = safe_require("lint")
      if lint then
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

  -- 10) HTMX attributes highlighting
  vim.api.nvim_create_augroup("HTMXHighlight", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = "HTMXHighlight",
    pattern = { "html", "templ" },
    callback = function()
      vim.cmd([[syntax match htmlArg contained "\<hx-[a-zA-Z\-]\+" ]])
      vim.cmd([[syntax match htmlArg contained "\<data-hx-[a-zA-Z\-]\+" ]])
      vim.cmd([[highlight link htmlArg Keyword]])
    end,
    desc = "Highlight HTMX attributes",
  })

  -- 11) Templ indentation
  vim.api.nvim_create_augroup("TemplIndent", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = "TemplIndent",
    pattern = "templ",
    callback = function()
      vim.bo.indentexpr = "GetTemplIndent()"
      if vim.fn.exists("*GetTemplIndent") == 0 then
        vim.cmd([[
          function! GetTemplIndent()
            let cl = getline(v:lnum)
            if cl =~ '^\s*}'
              return indent(v:lnum-1) - &shiftwidth
            endif
            let pl = getline(v:lnum-1)
            let pi = indent(v:lnum-1)
            if pl =~ '{$'
              return pi + &shiftwidth
            endif
            return pi
          endfunction
        ]])
      end
    end,
    desc = "Configure Templ indentation",
  })

  -- 12) Terminal mode settings
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

  -- 13) Refresh gitsigns after lazygit after lazygit
  local git_grp = vim.api.nvim_create_augroup("GitSignsRefresh", { clear = true })
  vim.api.nvim_create_autocmd("TermClose", {
    group = git_grp,
    pattern = "*lazygit",
    desc = "Refresh gitsigns on lazygit exit",
    callback = function()
      local gs = safe_require("gitsigns")
      if gs and gs.refresh then
        gs.refresh()
      end
    end,
  })

  -- 15) Update window title) Update window title
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

  -- 16) Project-specific autocmds
  local proj = vim.fn.getcwd() .. "/.nvim/autocmds.lua"
  if vim.fn.filereadable(proj) == 1 then
    pcall(dofile, proj)
  end

  -- 17) Disable auto comment continuation
  vim.api.nvim_create_augroup("NoCommentCont", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = "NoCommentCont",
    pattern = "*",
    callback = function()
      vim.bo.formatoptions = vim.bo.formatoptions:gsub("[cro]", "")
    end,
    desc = "Disable auto comment continuation",
  })

  -- 18) Try to load project-specific configuration if it exists
  local project_init = vim.fn.getcwd() .. "/.nvim/init.lua"
  if vim.fn.filereadable(project_init) == 1 then
    vim.notify("📝 Loading project-specific configuration", vim.log.levels.INFO)
    local ok, err = pcall(dofile, project_init)
    if not ok then
      vim.notify("❌ Error in project config: " .. err, vim.log.levels.ERROR)
    end
  end
end

return M
