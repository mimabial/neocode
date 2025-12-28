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
      -- Note: <C-k> signature help handled by lsp_signature.nvim plugin

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
  -- General Improvements (LazyVim style)
  -- ========================================
  -- Better escape (insert mode)
  map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
  map("i", "jj", "<ESC>", { desc = "Exit insert mode" })

  -- Save file
  map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

  -- Quit
  map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

  -- Select all
  map("n", "<C-a>", "ggVG", { desc = "Select all" })

  -- Open URL under cursor
  map("n", "gx", function()
    local url = vim.fn.expand("<cfile>")
    if url:match("^https?://") then
      vim.fn.jobstart({ "xdg-open", url }, { detach = true })
    else
      vim.notify("No URL under cursor", vim.log.levels.WARN)
    end
  end, { desc = "Open URL under cursor" })

  -- Clear search with <esc>
  map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

  -- Better undo breakpoints (insert mode)
  map("i", ",", ",<c-g>u")
  map("i", ".", ".<c-g>u")
  map("i", ";", ";<c-g>u")

  -- Terminal mode escape
  map("t", "<C-/>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
  map("t", "<C-_>", "<c-\\><c-n>", { desc = "which_key_ignore" }) -- For compatibility

  -- ========================================
  -- Editing
  -- ========================================
  map("n", "x", '"_x', { desc = "Don't copy deleted character" })
  map("v", "p", '"_dp', { desc = "Keep yanked text when pasting" })

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
  -- Window navigation: <C-h/j/k/l> handled by navigator plugins
  -- - tmux-navigator (when in tmux)
  -- - kitty-navigator (when in kitty without tmux)
  -- Both plugins provide seamless navigation between vim windows and terminal multiplexer panes

  -- Window splits
  map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
  map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split horizontal" })
  map("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close window" })
  map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Close other windows" })

  map("n", "<leader>wf", "<cmd>noautocmd w<cr>", { desc = "Save without formatting" })

  -- Resize windows with arrows
  map("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height" })
  map("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height" })
  map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
  map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

  -- Better line movement
  map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move down (display lines)" })
  map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move up (display lines)" })

  -- Better increment/decrement
  map("n", "+", "<C-a>", { desc = "Increment number" })
  map("n", "_", "<C-x>", { desc = "Decrement number" })

  -- Window management shortcuts (LazyVim style)
  map("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
  map("n", "<leader>|", "<C-W>v", { desc = "Split window right" })
  map("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })

  -- ========================================
  -- Buffer management
  -- Most buffer operations in plugins/ui/tabline.lua (BufferLine commands)
  -- Core operations defined here:
  -- ========================================
  map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New Buffer" })
  map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
  map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })

  -- Note: Buffer navigation (<leader>b]/[, <S-h>/<S-l>) defined in tabline.lua
  -- Note: Buffer deletion (<leader>bd) uses BufferLine in tabline.lua
  -- Note: First/Last buffer (<leader>bf/bl) uses BufferLine in tabline.lua

  -- ========================================
  -- Tab Management (LazyVim style)
  -- ========================================
  map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
  map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
  map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
  map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
  map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
  map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

  -- Note: File explorer keybinding (-) is defined in plugins/ui/explorer.lua

  -- ========================================
  -- Git Integration
  -- ========================================
  -- All git keybindings are defined in plugins/git/* files
  -- See plugins/git/lazygit.lua for namespace organization

  -- ========================================
  -- UI/display setting
  -- ========================================
  -- Theme Management
  map("n", "<leader>us", "<cmd>CycleColorScheme<cr>", { desc = "Cycle color scheme" })
  map("n", "<leader>uS", "<cmd>ColorScheme<cr>", { desc = "Select color scheme" })
  map("n", "<leader>uv", "<cmd>CycleColorVariant<cr>", { desc = "Cycle color variant" })
  map("n", "<leader>uV", "<cmd>ColorVariant<cr>", { desc = "Select color variant" })
  map("n", "<leader>ud", "<cmd>ToggleBackground<cr>", { desc = "Toggle dark/light mode" })
  -- System theme integration
  map("n", "<leader>uy", "<cmd>SystemSync<cr>", { desc = "Sync with system theme" })
  map("n", "<leader>uY", "<cmd>ColorModeStatus<cr>", { desc = "Show color mode status" })
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
