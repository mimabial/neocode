local M = {}
local diagnostics = require("config.diagnostics")

local LSP_CAPABILITY_MAPS = {
  { capability = "definition", lhs = "gd", rhs = vim.lsp.buf.definition, desc = "Go to definition" },
  { capability = "declaration", lhs = "gD", rhs = vim.lsp.buf.declaration, desc = "Go to declaration" },
  { capability = "references", lhs = "gr", rhs = vim.lsp.buf.references, desc = "Find references" },
  { capability = "implementation", lhs = "gi", rhs = vim.lsp.buf.implementation, desc = "Go to implementation" },
  { capability = "typeDefinition", lhs = "gt", rhs = vim.lsp.buf.type_definition, desc = "Go to type definition" },
  {
    capability = "hover",
    lhs = "K",
    rhs = function()
      vim.lsp.buf.hover({ border = "single" })
    end,
    desc = "Show hover information",
  },
  { capability = "codeAction", lhs = "<leader>ca", rhs = vim.lsp.buf.code_action, desc = "Code actions" },
  { capability = "rename", lhs = "<leader>cr", rhs = vim.lsp.buf.rename, desc = "Rename symbol" },
}

local function enter_diagnostics_float()
  vim.diagnostic.open_float(nil, {
    focus_id = "diagnostic",
    focusable = true,
    focus = true,
    scope = "cursor",
    border = "single",
    source = true,
    prefix = " ",
    close_events = {},
  })
  -- open_floating_preview only auto-focuses an *existing* float; for a
  -- fresh open it returns the winid without switching. Switch manually.
  local floatwin = vim.b.lsp_floating_preview
  if floatwin and vim.api.nvim_win_is_valid(floatwin) and vim.api.nvim_get_current_win() ~= floatwin then
    vim.api.nvim_set_current_win(floatwin)
  end
end

function M.setup()
  local function map(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  local lsp_keymaps = vim.api.nvim_create_augroup("LspKeymaps", { clear = true })

  local function supports(client, capability_map)
    return client.server_capabilities[capability_map.capability .. "Provider"]
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_keymaps,
    callback = function(args)
      if vim.b[args.buf].bigfile then
        return
      end
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
      end

      for _, capability_map in ipairs(LSP_CAPABILITY_MAPS) do
        if supports(client, capability_map) then
          map("n", capability_map.lhs, capability_map.rhs, { buffer = args.buf, desc = capability_map.desc })
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = lsp_keymaps,
    callback = function(args)
      local remaining_clients = vim.tbl_filter(function(client)
        return client.id ~= args.data.client_id
      end, vim.lsp.get_clients({ bufnr = args.buf }))
      for _, capability_map in ipairs(LSP_CAPABILITY_MAPS) do
        local still_supported = vim.iter(remaining_clients):any(function(client)
          return supports(client, capability_map)
        end)
        if not still_supported then
          pcall(vim.keymap.del, "n", capability_map.lhs, { buffer = args.buf })
        end
      end
    end,
  })

  map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostics" })
  map("n", "<leader>cj", enter_diagnostics_float, { desc = "Show diagnostics + jump in" })

  -- General/Plugin Management
  map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })

  -- Diagnostics
  map("n", "<leader>ch", diagnostics.toggle_hover, { desc = "Toggle diagnostics hover popup" })

  -- General Improvements
  map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
  map("i", "jj", "<ESC>", { desc = "Exit insert mode" })

  map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
  map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
  map("n", "<C-a>", "ggVG", { desc = "Select all" })

  map("n", "gx", function()
    local url = vim.fn.expand("<cfile>")
    if url:match("^https?://") then
      vim.fn.jobstart({ "xdg-open", url }, { detach = true })
    else
      vim.notify("No URL under cursor", vim.log.levels.WARN)
    end
  end, { desc = "Open URL under cursor" })

  map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

  -- Undo breakpoints
  map("i", ",", ",<c-g>u")
  map("i", ".", ".<c-g>u")
  map("i", ";", ";<c-g>u")

  map("t", "<C-/>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
  map("t", "<C-_>", "<c-\\><c-n>", { desc = "which_key_ignore" })

  -- Editing
  map("n", "x", '"_x', { desc = "Don't copy deleted character" })

  map("v", ">", ">gv", { desc = "Indent and keep selection" })
  map("v", "<", "<gv", { desc = "Outdent and keep selection" })

  map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
  map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

  map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
  map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

  map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })
  map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
  map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
  map("n", "*", "*zzzv", { desc = "Search word forward (centered)" })
  map("n", "#", "#zzzv", { desc = "Search word backward (centered)" })
  map("n", "%", "%zz", { desc = "Match pair (centered)" })

  -- Navigation
  -- Note: <C-h/j/k/l> window navigation handled by tmux-navigator (in tmux)
  -- and kitty-navigator (in kitty without tmux).

  map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
  map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split horizontal" })
  map("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close window" })
  map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Close other windows" })
  map("n", "<leader>wf", function()
    local autoformat_disabled = vim.b.disable_autoformat
    vim.b.disable_autoformat = true
    local ok, err = pcall(vim.cmd.write)
    vim.b.disable_autoformat = autoformat_disabled
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end, { desc = "Save without formatting" })

  map("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height" })
  map("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height" })
  map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
  map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

  map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move down (display lines)" })
  map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move up (display lines)" })

  map("n", "+", "<C-a>", { desc = "Increment number" })
  map("n", "_", "<C-x>", { desc = "Decrement number" })

  map("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
  map("n", "<leader>|", "<C-W>v", { desc = "Split window right" })
  map("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })

  -- Buffer management
  -- Note: BufferLine commands defined in plugins/ui/tabline.lua.
  map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New Buffer" })
  map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
  map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })

  -- Tab Management
  map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
  map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
  map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
  map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
  map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
  map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

  -- Note: file explorer (-) keybinding lives in plugins/ui/explorer.lua;
  -- git keybindings live in plugins/git/* (see lazygit.lua for namespacing).

  -- UI/Theme
  map("n", "<leader>us", "<cmd>CycleColorScheme<cr>", { desc = "Cycle color scheme" })
  map("n", "<leader>uS", "<cmd>ColorScheme<cr>", { desc = "Select color scheme" })
  map("n", "<leader>uv", "<cmd>CycleColorVariant<cr>", { desc = "Cycle color variant" })
  map("n", "<leader>uV", "<cmd>ColorVariant<cr>", { desc = "Select color variant" })
  map("n", "<leader>ud", "<cmd>ToggleBackground<cr>", { desc = "Toggle dark/light mode" })
  map("n", "<leader>ut", "<cmd>ToggleTransparency<cr>", { desc = "Toggle transparency" })
  map("n", "<leader>uy", "<cmd>SystemSync<cr>", { desc = "Sync with system theme" })
  map("n", "<leader>uY", "<cmd>ColorModeStatus<cr>", { desc = "Show color mode status" })
  map("n", "<leader>uz", "<cmd>SystemSetTheme<cr>", { desc = "Set system NVIM_SCHEME" })
  map("n", "<leader>uL", "<cmd>SystemListThemes<cr>", { desc = "List available system themes" })
  map("n", "<leader>tw", "<cmd>set wrap!<CR>", { desc = "Toggle line wrap" })

  -- AI / Navic / Layouts
  map("n", "<leader>nb", "<cmd>NavicToggle<cr>", { desc = "Toggle breadcrumbs" })
  map("n", "<leader>L1", "<cmd>Layout coding<cr>", { desc = "Coding Layout" })
  map("n", "<leader>L2", "<cmd>Layout terminal<cr>", { desc = "Terminal Layout" })
  map("n", "<leader>L3", "<cmd>Layout writing<cr>", { desc = "Writing Layout" })
  map("n", "<leader>L4", "<cmd>Layout debug<cr>", { desc = "Debug Layout" })
end

return M
