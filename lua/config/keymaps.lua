-- Define keymaps using which-key for better organization
local wk = require("which-key")

-- Define leader key groups
wk.register({
  ["<leader>"] = {
    b = { name = "+buffer" },
    c = { name = "+code/lsp" },
    d = { name = "+debug" },
    f = { name = "+find/telescope" },
    g = { name = "+git" },
    h = { name = "+git hunks" },
    n = { name = "+noice/notifications" },
    q = { name = "+quit/session" },
    s = { name = "+search" },
    t = { name = "+terminal/toggle" },
    u = { name = "+ui" },
    w = { name = "+windows" },
    x = { name = "+diagnostics/quickfix" },
  },
})

-- Buffer management
wk.register({
  ["<leader>b"] = {
    b = { "<cmd>e #<cr>", "Switch to Other Buffer" },
    d = { "<cmd>bdelete<cr>", "Delete Buffer" },
    f = { "<cmd>bfirst<cr>", "First Buffer" },
    h = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
    l = { "<cmd>blast<cr>", "Last Buffer" },
    n = { "<cmd>bnext<cr>", "Next Buffer" },
    p = { "<cmd>bprevious<cr>", "Previous Buffer" },
    e = { "<cmd>Neotree buffers reveal float<cr>", "Buffer Explorer" },
  },
})

-- Buffer navigation with Shift
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- LSP and Code actions
wk.register({
  ["<leader>c"] = {
    name = "+code/lsp",
    a = { vim.lsp.buf.code_action, "Code Action" },
    d = { vim.diagnostic.open_float, "Line Diagnostics" },
    f = { vim.lsp.buf.format, "Format" },
    F = { "<cmd>FormatToggle<CR>", "Toggle Format on Save" },
    i = { "<cmd>LspInfo<cr>", "LSP Info" },
    l = { "<cmd>lua require('lint').try_lint()<cr>", "Trigger Linting" },
    r = { vim.lsp.buf.rename, "Rename Symbol" },
    s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
    S = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
  },
})

-- LSP related keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
vim.keymap.set("n", "gr", function() require("telescope.builtin").lsp_references() end, { desc = "Go to References" })
vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show Documentation" })
vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

-- Stack-specific keymaps
wk.register({
  ["<leader>cs"] = {
    name = "+stack-specific",
    g = {
      name = "+goth",
      c = { function() require("config.utils").new_templ_component() end, "New Templ Component" },
      p = { "<cmd>StackFocus goth<cr>", "Focus GOTH Stack" },
    },
    n = {
      name = "+nextjs",
      c = { function() require("config.utils").new_nextjs_component("client") end, "New Client Component" },
      s = { function() require("config.utils").new_nextjs_component("server") end, "New Server Component" },
      p = { function() require("config.utils").new_nextjs_component("page") end, "New Page" },
      l = { function() require("config.utils").new_nextjs_component("layout") end, "New Layout" },
      f = { "<cmd>StackFocus nextjs<cr>", "Focus Next.js Stack" },
    },
  },
})

-- Debug mode keymaps
wk.register({
  ["<leader>d"] = {
    name = "+debug",
    b = { function() require("dap").toggle_breakpoint() end, "Toggle Breakpoint" },
    B = { function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "Conditional Breakpoint" },
    c = { function() require("dap").continue() end, "Continue" },
    C = { function() require("dap").run_to_cursor() end, "Run to Cursor" },
    e = { function() require("dapui").eval() end, "Evaluate Expression" },
    i = { function() require("dap").step_into() end, "Step Into" },
    o = { function() require("dap").step_over() end, "Step Over" },
    O = { function() require("dap").step_out() end, "Step Out" },
    r = { function() require("dap").repl.toggle() end, "Toggle REPL" },
    R = { function() require("dap").restart() end, "Restart" },
    t = { function() require("dap").terminate() end, "Terminate" },
    u = { function() require("dapui").toggle() end, "Toggle UI" },
  },
})

-- Function keys for debugging
vim.keymap.set("n", "<F5>", function() require("dap").continue() end, { desc = "Continue" })
vim.keymap.set("n", "<F10>", function() require("dap").step_over() end, { desc = "Step Over" })
vim.keymap.set("n", "<F11>", function() require("dap").step_into() end, { desc = "Step Into" })
vim.keymap.set("n", "<F12>", function() require("dap").step_out() end, { desc = "Step Out" })

-- Telescope / Find
wk.register({
  ["<leader>f"] = {
    name = "+find/telescope",
    ["/"] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find in Buffer" },
    b = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
    c = { "<cmd>Telescope commands<cr>", "Find Commands" },
    C = { function() require("telescope.builtin").find_files({cwd = vim.fn.stdpath("config")}) end, "Find Config Files" },
    d = { "<cmd>Telescope diagnostics bufnr=0<cr>", "Find Document Diagnostics" },
    D = { "<cmd>Telescope diagnostics<cr>", "Find Workspace Diagnostics" },
    e = { "<cmd>Telescope file_browser<cr>", "File Browser" },
    f = { "<cmd>Telescope find_files<cr>", "Find Files" },
    g = { "<cmd>Telescope live_grep<cr>", "Find Text (Grep)" },
    h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
    k = { "<cmd>Telescope keymaps<cr>", "Find Keymaps" },
    o = { "<cmd>Telescope vim_options<cr>", "Find Options" },
    p = { "<cmd>Telescope projects<cr>", "Find Projects" },
    r = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
    R = { "<cmd>Telescope frecency<cr>", "Frecent Files" },
    s = { "<cmd>Telescope lsp_document_symbols<cr>", "Find Document Symbols" },
    S = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Find Workspace Symbols" },
    t = { "<cmd>Telescope filetypes<cr>", "Find Filetypes" },
    T = { "<cmd>Telescope builtin<cr>", "Find Telescope Pickers" },
    ["."] = { "<cmd>Telescope resume<cr>", "Resume Last Search" },
  },
})

-- Git commands
wk.register({
  ["<leader>g"] = {
    name = "+git",
    b = { "<cmd>Telescope git_branches<cr>", "Git Branches" },
    c = { "<cmd>Telescope git_commits<cr>", "Git Commits" },
    d = { "<cmd>DiffviewOpen<cr>", "DiffView Open" },
    D = { "<cmd>DiffviewClose<cr>", "DiffView Close" },
    e = { "<cmd>Neotree git_status reveal float<cr>", "Git Explorer" },
    g = { "<cmd>LazyGit<cr>", "Lazygit" },
    h = { "<cmd>DiffviewFileHistory %<cr>", "File History" },
    H = { "<cmd>DiffviewFileHistory<cr>", "Project History" },
    l = { "<cmd>Git pull<cr>", "Git Pull" },
    p = { "<cmd>Git push<cr>", "Git Push" },
    s = { "<cmd>Telescope git_status<cr>", "Git Status" },
  }
})

-- Git Signs / Hunks 
wk.register({
  ["<leader>h"] = {
    name = "+git hunks",
    b = { function() require("gitsigns").blame_line({ full = true }) end, "Blame Line" },
    B = { function() require("gitsigns").toggle_current_line_blame() end, "Toggle Line Blame" },
    d = { function() require("gitsigns").diffthis() end, "Diff This" },
    D = { function() require("gitsigns").diffthis("~") end, "Diff This ~" },
    p = { function() require("gitsigns").preview_hunk() end, "Preview Hunk" },
    r = { function() require("gitsigns").reset_hunk() end, "Reset Hunk" },
    R = { function() require("gitsigns").reset_buffer() end, "Reset Buffer" },
    s = { function() require("gitsigns").stage_hunk() end, "Stage Hunk" },
    S = { function() require("gitsigns").stage_buffer() end, "Stage Buffer" },
    u = { function() require("gitsigns").undo_stage_hunk() end, "Undo Stage Hunk" },
  }
})

-- Noice and notifications
wk.register({
  ["<leader>n"] = {
    name = "+noice/notifications",
    a = { function() require("noice").cmd("all") end, "Noice All" },
    d = { function() require("noice").cmd("dismiss") end, "Dismiss All" },
    h = { function() require("noice").cmd("history") end, "Noice History" },
    l = { function() require("noice").cmd("last") end, "Noice Last Message" },
    e = { function() require("noice").cmd("errors") end, "Noice Errors" },
  }
})

-- Quick exit and sessions
wk.register({
  ["<leader>q"] = {
    name = "+quit/session",
    q = { "<cmd>qa<cr>", "Quit All" },
    w = { "<cmd>wqa<cr>", "Save and Quit All" },
    s = { function() require("persistence").load() end, "Restore Session" },
    l = { function() require("persistence").load({ last = true }) end, "Restore Last Session" },
    d = { function() require("persistence").stop() end, "Don't Save Current Session" },
  }
})

-- Search commands
wk.register({
  ["<leader>s"] = {
    name = "+search",
    b = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Buffer" },
    d = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
    g = { "<cmd>Telescope git_status<cr>", "Git Status" },
    h = { "<cmd>Telescope command_history<cr>", "Command History" },
    m = { "<cmd>Telescope marks<cr>", "Marks" },
    M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
    r = { "<cmd>Telescope registers<cr>", "Registers" },
    s = { "<cmd>Telescope lsp_document_symbols<cr>", "Symbols" },
    t = { "<cmd>TodoTelescope<cr>", "Todo" },
    T = { "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", "Todo/Fix/Fixme" },
    w = { "<cmd>Telescope grep_string<cr>", "Word Under Cursor" },
  }
})

-- Terminal/toggle commands
wk.register({
  ["<leader>t"] = {
    name = "+terminal/toggle",
    f = { "<cmd>ToggleTerm direction=float<cr>", "Terminal (float)" },
    h = { "<cmd>ToggleTerm direction=horizontal<cr>", "Terminal (horizontal)" },
    v = { "<cmd>ToggleTerm direction=vertical<cr>", "Terminal (vertical)" },
    t = { "<cmd>ToggleTerm<cr>", "Toggle terminal" },
    b = { function() require("gitsigns").toggle_current_line_blame() end, "Toggle Line Blame" },
    d = { function() require("gitsigns").toggle_deleted() end, "Toggle Deleted" },
    n = { function() _G.toggle_node() end, "Node Terminal" },
    p = { function() _G.toggle_python() end, "Python Terminal" },
    c = { function() require("config.utils").toggle_colorcolumn() end, "Toggle Color Column" },
    w = { function() vim.wo.wrap = not vim.wo.wrap; vim.notify("Wrap " .. (vim.wo.wrap and "enabled" or "disabled")) end, "Toggle Wrap" },
  }
})

-- UI toggles and commands
wk.register({
  ["<leader>u"] = {
    name = "+ui",
    c = { "<cmd>ColorSchemeToggle<cr>", "Toggle Colorscheme" },
    n = { function() require("notify").dismiss({ silent = true, pending = true }) end, "Dismiss Notifications" },
    r = { "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", "Redraw / Clear Highlight" },
    t = { "<cmd>ToggleTransparency<cr>", "Toggle Transparency" },
    l = { "<cmd>Lazy<cr>", "Lazy Plugin Manager" },
    L = { "<cmd>LazyUpdate<cr>", "Update Plugins" },
    m = { "<cmd>Mason<cr>", "Mason LSP Manager" },
    M = { "<cmd>MasonUpdate<cr>", "Update LSP Servers" },
  }
})

-- Windows management
wk.register({
  ["<leader>w"] = {
    name = "+window",
    ["-"] = { "<C-W>s", "Split window below" },
    ["|"] = { "<C-W>v", "Split window right" },
    ["2"] = { "<C-W>v", "Layout double columns" },
    h = { "<C-W>h", "Go to left window" },
    j = { "<C-W>j", "Go to lower window" },
    k = { "<C-W>k", "Go to upper window" },
    l = { "<C-W>l", "Go to right window" },
    q = { "<C-W>q", "Close window" },
    w = { "<C-W>w", "Other window" },
    ["="] = { "<C-W>=", "Balance windows" },
  }
})

-- Diagnostics and quickfix
wk.register({
  ["<leader>x"] = {
    name = "+diagnostics/quickfix",
    d = { "<cmd>TroubleToggle document_diagnostics<cr>", "Document Diagnostics" },
    l = { "<cmd>TroubleToggle loclist<cr>", "Location List" },
    q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix List" },
    t = { "<cmd>TodoTrouble<cr>", "Todo Trouble" },
    T = { "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", "Todo/Fix/Fixme Trouble" },
    w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace Diagnostics" },
    x = { "<cmd>TroubleToggle<cr>", "Toggle Trouble" },
    f = { function() require("config.utils").toggle_qf() end, "Toggle Quickfix" },
  }
})

-- Navigation key pairs 
wk.register({
  ["["] = {
    b = { "<cmd>bprevious<cr>", "Previous Buffer" },
    c = { function() require("gitsigns").prev_hunk() end, "Previous Hunk" },
    d = { vim.diagnostic.goto_prev, "Previous Diagnostic" },
    l = { "<cmd>lprev<cr>", "Previous Location" },
    q = { "<cmd>cprev<cr>", "Previous Quickfix" },
    t = { function() require("todo-comments").jump_prev() end, "Previous Todo" },
  },
  ["]"] = {
    b = { "<cmd>bnext<cr>", "Next Buffer" },
    c = { function() require("gitsigns").next_hunk() end, "Next Hunk" },
    d = { vim.diagnostic.goto_next, "Next Diagnostic" },
    l = { "<cmd>lnext<cr>", "Next Location" },
    q = { "<cmd>cnext<cr>", "Next Quickfix" },
    t = { function() require("todo-comments").jump_next() end, "Next Todo" },
  },
})

-- Movement in insert mode
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down" })
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Save file
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Unindent line" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent line" })

-- Layout switching keymaps
vim.keymap.set("n", "<leader>L1", "<cmd>Layout coding<cr>", { desc = "Coding Layout" })
vim.keymap.set("n", "<leader>L2", "<cmd>Layout terminal<cr>", { desc = "Terminal Layout" })
vim.keymap.set("n", "<leader>L3", "<cmd>Layout writing<cr>", { desc = "Writing Layout" })
vim.keymap.set("n", "<leader>L4", "<cmd>Layout debug<cr>", { desc = "Debug Layout" })

-- Add more stack-specific keymaps
-- GOTH
vim.keymap.set("n", "<leader>cgt", "<cmd>!go test ./...<cr>", { desc = "Run Go Tests" })
vim.keymap.set("n", "<leader>cgm", "<cmd>!go mod tidy<cr>", { desc = "Go Mod Tidy" })
vim.keymap.set("n", "<leader>cgb", "<cmd>!go build<cr>", { desc = "Go Build" })
vim.keymap.set("n", "<leader>cgr", "<cmd>!go run .<cr>", { desc = "Go Run" })

-- Next.js
vim.keymap.set("n", "<leader>cnd", "<cmd>!npm run dev<cr>", { desc = "Next.js Dev" })
vim.keymap.set("n", "<leader>cnb", "<cmd>!npm run build<cr>", { desc = "Next.js Build" })
vim.keymap.set("n", "<leader>cnt", "<cmd>!npm test<cr>", { desc = "Run Tests" })
vim.keymap.set("n", "<leader>cni", "<cmd>!npm install<cr>", { desc = "NPM Install" })

-- Quick reload config
vim.keymap.set("n", "<leader>cr", "<cmd>ReloadConfig<cr>", { desc = "Reload Config" })
