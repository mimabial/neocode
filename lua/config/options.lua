-- Options configured via vim.opt
local options = {
  -- Display
  number = true,                -- Show line numbers
  relativenumber = true,        -- Show relative line numbers
  cursorline = true,            -- Highlight current line
  wrap = false,                 -- Don't wrap lines
  scrolloff = 8,                -- Keep 8 lines above/below cursor when scrolling
  sidescrolloff = 8,            -- Keep 8 columns to the left/right of cursor
  showmode = false,             -- Hide mode text ('-- INSERT --')
  showcmd = false,              -- Hide command line
  cmdheight = 1,                -- Command line height
  signcolumn = "yes",           -- Always show sign column
  termguicolors = true,         -- True color support
  background = "dark",          -- Use dark background
  
  -- Status line
  laststatus = 3,               -- Global status line
  
  -- Indentation
  tabstop = 2,                  -- Number of spaces tabs count for
  shiftwidth = 2,               -- Size of an indent
  expandtab = true,             -- Use spaces instead of tabs
  smartindent = true,           -- Smart indentation
  breakindent = true,           -- Enable break indent
  
  -- Search
  ignorecase = true,            -- Case insensitive searching
  smartcase = true,             -- Override ignorecase when search contains uppercase
  hlsearch = true,              -- Highlight search
  
  -- Files
  swapfile = false,             -- Don't use swapfile
  backup = false,               -- Don't create backup files
  undofile = true,              -- Save undo history
  
  -- Misc
  mouse = "a",                  -- Enable mouse support
  updatetime = 250,             -- Decrease update time
  timeoutlen = 300,             -- Time in milliseconds to wait for a mapped sequence
  
  -- Split windows
  splitright = true,            -- Split windows right
  splitbelow = true,            -- Split windows below
  
  -- Completion
  completeopt = "menu,menuone,noselect", -- Better completion experience
  
  -- Show invisible characters
  list = true,                  -- Show invisible characters
  listchars = { tab = "» ", trail = "·", nbsp = "␣" }, -- Define which invisibles to show
  
  -- Clipboard
  clipboard = "unnamedplus",    -- Sync with system clipboard
  
  -- Prompt confirmation
  confirm = true,               -- Confirm before exiting if unsaved changes
  
  -- Auto write files
  autowrite = true,             -- Auto save before commands like :next and :make
  
  -- Popup menu
  pumheight = 10,               -- Maximum number of entries in a popup
  
  -- Folding
  foldlevel = 99,
  foldlevelstart = 99,
  foldenable = true,
  foldmethod = "expr",
  foldexpr = "nvim_treesitter#foldexpr()",
  
  -- Hide end-of-buffer tildes
  fillchars = { eob = " " },    -- Hide tilde on empty lines
}

-- Show search count message when searching
vim.opt.shortmess:remove("S")

-- Enhanced search count display
vim.opt.statusline:append("%=%{v:lua.require'config.utils'.search_count()}")

-- Apply all options
for k, v in pairs(options) do
  vim.opt[k] = v
end

-- Configure vim.g settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Diagnostics configuration
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    severity = {
      min = vim.diagnostic.severity.HINT,
    },
    source = "if_many",
    spacing = 4,
  },
  float = {
    border = "rounded",
    severity_sort = true,
    source = "always",
    header = "",
    prefix = function(diagnostic)
      local signs = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.INFO] = " ",
        [vim.diagnostic.severity.HINT] = " ",
      }
      return signs[diagnostic.severity] .. " "
    end,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Configure signs for diagnostics
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Set up global utility functions
_G.utils = {
  -- Check if a plugin is installed
  has_plugin = function(plugin)
    return require("lazy.core.config").spec.plugins[plugin] ~= nil
  end,
  
  -- Check if a command exists
  has_command = function(cmd)
    return vim.fn.exists(":" .. cmd) == 2
  end,
  
  -- Get the current buffer's working directory
  get_buf_dir = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    return vim.fn.fnamemodify(bufname, ":p:h")
  end,
  
  -- Create a new scratch buffer
  scratch_buffer = function()
    vim.cmd([[
      enew
      setlocal buftype=nofile
      setlocal bufhidden=hide
      setlocal noswapfile
      setlocal nobuflisted
    ]])
    return vim.api.nvim_get_current_buf()
  end,
  
  -- Center the current buffer content
  center_buffer = function()
    local win_height = vim.api.nvim_win_get_height(0)
    local buf_height = vim.api.nvim_buf_line_count(0)
    local padding = math.floor((win_height - buf_height) / 2)
    if padding > 0 then
      local lines = {}
      for _ = 1, padding do
        table.insert(lines, "")
      end
      vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
      vim.api.nvim_buf_set_lines(0, buf_height + padding, buf_height + padding, false, lines)
      vim.api.nvim_win_set_cursor(0, {padding + 1, 0})
    end
  end,
}
