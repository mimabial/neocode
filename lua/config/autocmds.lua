-- Create a dedicated autocommand group to avoid duplication
local augroup = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

-- Highlight text on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
  desc = "Highlight text on yank",
})

-- Automatically resize splits when Neovim is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
  desc = "Auto-resize splits on Vim resize",
})

-- Remember cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Go to last location when opening a buffer",
})

-- Toggle between relative and absolute line numbers based on mode
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = augroup,
  callback = function()
    -- Skip special buffers where line numbers shouldn't be enabled
    local ft = vim.bo.filetype
    if ft == "oil" or ft == "terminal" or ft == "starter" then
      return
    end

    if vim.wo.number and not vim.g.disable_relative_number then
      vim.wo.relativenumber = true
    end
  end,
  desc = "Enable relative number when not in insert mode",
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = augroup,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
    end
  end,
  desc = "Disable relative number when in insert mode",
})

-- Add command to toggle relative line numbers
vim.api.nvim_create_user_command("ToggleRelativeNumber", function()
  vim.g.disable_relative_number = not vim.g.disable_relative_number
  if vim.g.disable_relative_number then
    -- Disable relative numbers
    vim.wo.relativenumber = false
    vim.notify("Relative line numbers disabled", vim.log.levels.INFO)
  else
    -- Enable relative numbers
    vim.wo.relativenumber = vim.fn.mode() ~= "i"
    vim.notify("Relative line numbers enabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle relative line numbers" })

-- Add keymapping for the toggle command
vim.keymap.set("n", "<leader>uz", "<cmd>ToggleRelativeNumber<CR>", { desc = "Toggle relative numbers" })

-- Set filetype-specific indentation
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
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
  desc = "Set indentation to 2 spaces for specified filetypes",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "go", "python", "rust", "c", "cpp" },
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end,
  desc = "Set indentation to 4 spaces for specified filetypes",
})

-- GOTH stack file detection
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup,
  pattern = { "*.templ" },
  callback = function()
    vim.bo.filetype = "templ"
  end,
  desc = "Set filetype=templ for .templ files",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup,
  pattern = { "*.go.html", "*.gohtml" },
  callback = function()
    vim.bo.filetype = "gohtmltmpl"
  end,
  desc = "Set filetype=gohtmltmpl for Go HTML template files",
})

-- Special settings for markdown files
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 0
  end,
  desc = "Set markdown-specific settings",
})

-- Auto open directory with oil
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if vim.fn.isdirectory(bufname) == 1 then
      if package.loaded["oil"] then
        -- already loaded, just open
        require("oil").open(bufname)
      else
        -- use Lua API to load the plugin
        require("lazy").load({ plugins = { "oil.nvim" } })
        -- after a short delay, open the directory
        vim.defer_fn(function()
          if package.loaded["oil"] then
            require("oil").open(bufname)
          end
        end, 100)
      end
    end
  end,
  desc = "Open directory in file explorer",
})

-- Trigger linting when files are saved or opened
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
  group = augroup,
  callback = function()
    local lint_ok, lint = pcall(require, "lint")
    if lint_ok then
      lint.try_lint()
    end
  end,
  desc = "Trigger linting when file is saved or read",
})

-- Automatically show diagnostic float when cursor is over a diagnostic line
vim.api.nvim_create_autocmd("CursorHold", {
  group = augroup,
  callback = function()
    local float_opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "always",
      prefix = " ",
      scope = "cursor",
    }
    vim.diagnostic.open_float(nil, float_opts)
  end,
  desc = "Show diagnostics on cursor hold",
})

-- Auto-reload files if they change on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = augroup,
  callback = function()
    if vim.fn.mode() ~= "c" then
      local bufnr = vim.api.nvim_get_current_buf()
      local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
      if not modified and vim.fn.expand("%") ~= "" then
        vim.cmd("checktime")
      end
    end
  end,
  desc = "Auto-reload changed files",
})

-- Configure HTMX custom syntax highlighting
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "html", "templ" },
  callback = function()
    -- Define HTMX attributes for highlighting
    vim.cmd([[
      syntax match htmlArg contained "\<hx-[a-zA-Z\-]\+\>"
      syntax match htmlArg contained "\<data-hx-[a-zA-Z\-]\+\>"
      highlight link htmlArg Keyword
    ]])
  end,
  desc = "Highlight HTMX attributes",
})

-- Set up LSP keymaps when an LSP attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Skip attaching keymaps for certain clients
    if client.name == "copilot" then
      return
    end

    -- Create buffer-local keymaps
    local opts = { buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)

    -- Use snacks.picker for references if available
    if package.loaded["snacks.picker"] then
      vim.keymap.set("n", "gr", function()
        require("snacks.picker").lsp_references()
      end, opts)
    else
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    end

    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>cf", function()
      vim.lsp.buf.format({ async = true })
    end, opts)

    -- Show diagnostics in a floating window
    vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, opts)

    -- Add to the quickfix list
    vim.keymap.set("n", "<leader>cq", vim.diagnostic.setqflist, opts)

    -- Add formatting capability if supported
    if client.supports_method("textDocument/formatting") then
      -- Create a command to manually format
      vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end, { desc = "Format buffer with LSP" })
    end
  end,
  desc = "LSP keymaps setup",
})

-- Handle TEMPL file syntax better
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "templ",
  callback = function()
    -- Special indentation
    vim.bo.indentexpr = "GetTemplIndent()"

    -- Create the indent function if it doesn't exist
    if vim.fn.exists("*GetTemplIndent") == 0 then
      vim.cmd([[
        function! GetTemplIndent()
          let curline = getline(v:lnum)
          if curline =~ '^\s*}'
            return indent(v:lnum - 1) - &shiftwidth
          endif

          let prevline = getline(v:lnum - 1)
          let previndent = indent(v:lnum - 1)

          if prevline =~ '{$'
            return previndent + &shiftwidth
          endif

          return previndent
        endfunction
      ]])
    end
  end,
  desc = "Setup Templ file indentation",
})

-- Terminal specific configurations
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    -- Disable line numbers in terminal buffer only
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false

    -- Start in insert mode
    vim.cmd("startinsert")

    -- Set terminal-specific keymaps
    local opts = { buffer = true, silent = true }
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
  end,
  desc = "Terminal-specific settings",
})

-- Refresh gitsigns when lazygit is closed
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  pattern = "*lazygit",
  callback = function()
    if package.loaded["gitsigns"] then
      require("gitsigns").refresh()
    end
  end,
  desc = "Refresh gitsigns when closing lazygit",
})

-- Configure oil-specific settings
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "oil",
  callback = function()
    -- Disable numbers in Oil
    vim.wo.number = false
    vim.wo.relativenumber = false

    -- Enable cursorline for better visibility
    vim.wo.cursorline = true

    -- Set custom highlights
    if vim.g.colors_name == "gruvbox-material" then
      vim.cmd("highlight link OilDir GruvboxAqua")
      vim.cmd("highlight link OilDirIcon GruvboxAqua")
      vim.cmd("highlight link OilLink GruvboxGreen")
    end

    -- Stack-specific filters
    if vim.g.current_stack == "goth" then
      -- Apply GOTH-specific filters if needed
      vim.b.oil_filter_pattern = "node_modules/|vendor/|go.sum"
    elseif vim.g.current_stack == "nextjs" then
      -- Apply Next.js-specific filters if needed
      vim.b.oil_filter_pattern = "node_modules/|.next/|.vercel/|out/|.turbo/"
    end
  end,
  desc = "Oil-specific settings",
})

-- LSP inlay hints (where supported)
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Enable inlay hints for supported clients
    if client and client.supports_method("textDocument/inlayHint") then
      -- Using vim.lsp.inlay_hint instead of the deprecated vim.lsp.buf.inlay_hint
      -- Only available in Neovim 0.10+
      if vim.lsp.inlay_hint then
        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
      end
    end
  end,
  desc = "Enable LSP inlay hints",
})

-- Update Vim title
vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "VimResume" }, {
  group = augroup,
  callback = function()
    local icon = "  "
    local filename = vim.fn.expand("%:t")
    local filetype = vim.bo.filetype

    if filename == "" then
      filename = "Untitled"
    end

    -- Add an icon based on filetype if available
    if filetype == "lua" then
      icon = "  "
    elseif
      filetype == "javascript"
      or filetype == "javascriptreact"
      or filetype == "typescript"
      or filetype == "typescriptreact"
    then
      icon = "  "
    elseif filetype == "go" then
      icon = "  "
    elseif filetype == "templ" then
      icon = "  "
    elseif filetype == "python" then
      icon = "  "
    elseif filetype == "rust" then
      icon = "  "
    elseif filetype == "markdown" then
      icon = "  "
    end

    vim.opt.titlestring = icon .. " " .. filename .. " - NVIM"
  end,
  desc = "Update Vim title",
})

-- Load more autocmds from project-specific config if exists
local project_config = vim.fn.getcwd() .. "/.nvim/autocmds.lua"
if vim.fn.filereadable(project_config) == 1 then
  dofile(project_config)
end

-- Start screen
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = function()
    -- Only show if no arguments were passed and not in diff mode
    if vim.fn.argc() == 0 and not vim.opt.diff:get() then
      -- If mini.starter is installed, it will handle this automatically
      -- Otherwise, can set up a custom start screen
      if not require("lazy.core.config").plugins["mini.starter"] then
        -- Create a custom start screen
        local buf = vim.api.nvim_create_buf(false, true)
        local width = vim.o.columns
        local height = vim.o.lines

        -- Create centered window
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = math.floor(width * 0.8),
          height = math.floor(height * 0.8),
          row = math.floor(height * 0.1),
          col = math.floor(width * 0.1),
          style = "minimal",
          border = "rounded",
        })

        -- Add some welcome content
        local lines = {
          "",
          "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
          "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
          "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
          "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
          "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
          "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
          "",
          "   Welcome to your custom Neovim setup!",
          "",
          "   Press 'ff' to find files",
          "   Press 'fg' to live grep",
          "   Press 'fb' to browse buffers",
          "   Press 'fr' to see recent files",
          "",
          "   Press 'L1' for coding layout",
          "   Press 'L2' for terminal layout",
          "   Press 'L3' for writing layout",
          "",
          "   Happy coding!",
          "",
        }

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

        -- Set buffer-local keymaps
        local opts = { buffer = buf, silent = true }
        vim.keymap.set("n", "q", "<cmd>quit<CR>", opts)
        vim.keymap.set("n", "<ESC>", "<cmd>quit<CR>", opts)

        -- Use snacks.picker instead of telescope if available
        vim.keymap.set("n", "ff", function()
          require("snacks.picker").find_files()
        end, opts)
        vim.keymap.set("n", "fg", function()
          require("snacks.picker").live_grep()
        end, opts)
        vim.keymap.set("n", "fb", function()
          require("snacks.picker").buffers()
        end, opts)
        vim.keymap.set("n", "fr", function()
          require("snacks.picker").oldfiles()
        end, opts)

        vim.keymap.set("n", "L1", "<cmd>Layout coding<CR>", opts)
        vim.keymap.set("n", "L2", "<cmd>Layout terminal<CR>", opts)
        vim.keymap.set("n", "L3", "<cmd>Layout writing<CR>", opts)

        -- Center the text by adding spaces to the beginning of each line
        local centered_lines = {}
        for _, line in ipairs(lines) do
          table.insert(centered_lines, string.rep(" ", 10) .. line)
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, centered_lines)

        -- Set highlight for the buffer
        local ns_id = vim.api.nvim_create_namespace("StartScreen")

        -- Apply syntax highlighting to the welcome message
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Title", 1, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Title", 2, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Title", 3, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Title", 4, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Title", 5, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Title", 6, 0, -1)

        vim.api.nvim_buf_add_highlight(buf, ns_id, "String", 8, 0, -1)

        vim.api.nvim_buf_add_highlight(buf, ns_id, "Keyword", 10, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Keyword", 11, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Keyword", 12, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Keyword", 13, 0, -1)

        vim.api.nvim_buf_add_highlight(buf, ns_id, "Function", 15, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Function", 16, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, ns_id, "Function", 17, 0, -1)

        vim.api.nvim_buf_add_highlight(buf, ns_id, "Comment", 19, 0, -1)
      end
    end
  end,
  desc = "Show custom start screen",
})
