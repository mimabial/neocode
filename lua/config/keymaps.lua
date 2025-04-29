-- Define keymaps using vim.keymap.set directly
-- Define leader key groups first (for which-key only)
local wk = require("which-key")

wk.register({
  ["<leader>"] = {
    b = { name = "+buffer" },
    c = { name = "+code/lsp" },
    d = { name = "+debug" },
    f = { name = "+find/telescope" },
    g = { name = "+git" },
    h = { name = "+git hunks" },
    L = { name = "+layouts" },
    n = { name = "+noice/notifications" },
    q = { name = "+quit/session" },
    s = { name = "+stack-specific" },
    t = { name = "+terminal/toggle" },
    u = { name = "+ui" },
    w = { name = "+windows" },
    x = { name = "+diagnostics/quickfix" },
    e = { name = "+explorer" },
  },
  ["["] = { name = "+prev" },
  ["]"] = { name = "+next" },
  ["g"] = { name = "+goto/lsp" },
})

-- Register subgroups
wk.register({
  ["<leader>cg"] = { name = "+goth" },
  ["<leader>cn"] = { name = "+nextjs" },
  ["<leader>sg"] = { name = "+goth stack" },
  ["<leader>sn"] = { name = "+nextjs stack" },
})

-- Buffer management
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bf", "<cmd>bfirst<cr>", { desc = "First Buffer" })
vim.keymap.set("n", "<leader>bh", "<cmd>Telescope buffers<cr>", { desc = "Find Buffer" })
vim.keymap.set("n", "<leader>bl", "<cmd>blast<cr>", { desc = "Last Buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>be", "<cmd>Neotree buffers reveal float<cr>", { desc = "Buffer Explorer" })

-- Buffer navigation with Shift
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- LSP and Code actions
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format" })
vim.keymap.set("n", "<leader>cF", "<cmd>FormatToggle<CR>", { desc = "Toggle Format on Save" })
vim.keymap.set("n", "<leader>ci", "<cmd>LspInfo<cr>", { desc = "LSP Info" })
vim.keymap.set("n", "<leader>cl", "<cmd>lua require('lint').try_lint()<cr>", { desc = "Trigger Linting" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set("n", "<leader>cs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document Symbols" })
vim.keymap.set("n", "<leader>cS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "Workspace Symbols" })
vim.keymap.set("n", "<leader>cR", "<cmd>ReloadConfig<cr>", { desc = "Reload Config" })

-- GOTH stack specific
vim.keymap.set("n", "<leader>cgc", function() require("config.utils").new_templ_component() end, { desc = "New Templ Component" })
vim.keymap.set("n", "<leader>cgt", "<cmd>!go test ./...<cr>", { desc = "Run Go Tests" })
vim.keymap.set("n", "<leader>cgm", "<cmd>!go mod tidy<cr>", { desc = "Go Mod Tidy" })
vim.keymap.set("n", "<leader>cgb", "<cmd>!go build<cr>", { desc = "Go Build" })
vim.keymap.set("n", "<leader>cgr", "<cmd>!go run .<cr>", { desc = "Go Run" })

-- Next.js specific
vim.keymap.set("n", "<leader>cnc", function() require("config.utils").new_nextjs_component("client") end, { desc = "New Client Component" })
vim.keymap.set("n", "<leader>cns", function() require("config.utils").new_nextjs_component("server") end, { desc = "New Server Component" })
vim.keymap.set("n", "<leader>cnp", function() require("config.utils").new_nextjs_component("page") end, { desc = "New Page" })
vim.keymap.set("n", "<leader>cnl", function() require("config.utils").new_nextjs_component("layout") end, { desc = "New Layout" })
vim.keymap.set("n", "<leader>cnd", "<cmd>!npm run dev<cr>", { desc = "Next.js Dev" })
vim.keymap.set("n", "<leader>cnb", "<cmd>!npm run build<cr>", { desc = "Next.js Build" })
vim.keymap.set("n", "<leader>cnt", "<cmd>!npm test<cr>", { desc = "Run Tests" })
vim.keymap.set("n", "<leader>cni", "<cmd>!npm install<cr>", { desc = "NPM Install" })

-- Debug mode keymaps
vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end, { desc = "Continue" })
vim.keymap.set("n", "<leader>dC", function() require("dap").run_to_cursor() end, { desc = "Run to Cursor" })
vim.keymap.set("n", "<leader>de", function() require("dapui").eval() end, { desc = "Evaluate Expression" })
vim.keymap.set("n", "<leader>di", function() require("dap").step_into() end, { desc = "Step Into" })
vim.keymap.set("n", "<leader>do", function() require("dap").step_over() end, { desc = "Step Over" })
vim.keymap.set("n", "<leader>dO", function() require("dap").step_out() end, { desc = "Step Out" })
vim.keymap.set("n", "<leader>dr", function() require("dap").repl.toggle() end, { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>dR", function() require("dap").restart() end, { desc = "Restart" })
vim.keymap.set("n", "<leader>dt", function() require("dap").terminate() end, { desc = "Terminate" })
vim.keymap.set("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Toggle UI" })
vim.keymap.set("n", "<leader>dg", function() _G.debug_goth_app() end, { desc = "Debug GOTH App" })

-- Function keys for debugging
vim.keymap.set("n", "<F5>", function() require("dap").continue() end, { desc = "Continue" })
vim.keymap.set("n", "<F10>", function() require("dap").step_over() end, { desc = "Step Over" })
vim.keymap.set("n", "<F11>", function() require("dap").step_into() end, { desc = "Step Into" })
vim.keymap.set("n", "<F12>", function() require("dap").step_out() end, { desc = "Step Out" })

-- Telescope / Find
vim.keymap.set("n", "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Find in Buffer" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find Buffer" })
vim.keymap.set("n", "<leader>fc", "<cmd>Telescope commands<cr>", { desc = "Find Commands" })
vim.keymap.set("n", "<leader>fC", function() require("telescope.builtin").find_files({cwd = vim.fn.stdpath("config")}) end, { desc = "Find Config Files" })
vim.keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Find Document Diagnostics" })
vim.keymap.set("n", "<leader>fD", "<cmd>Telescope diagnostics<cr>", { desc = "Find Workspace Diagnostics" })
vim.keymap.set("n", "<leader>fe", "<cmd>Telescope file_browser<cr>", { desc = "File Browser" })
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Find Text (Grep)" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find Help" })
vim.keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find Keymaps" })
vim.keymap.set("n", "<leader>fo", "<cmd>Telescope vim_options<cr>", { desc = "Find Options" })
vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Find Projects" })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fR", "<cmd>Telescope frecency<cr>", { desc = "Frecent Files" })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Find Document Symbols" })
vim.keymap.set("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", { desc = "Find Workspace Symbols" })
vim.keymap.set("n", "<leader>ft", "<cmd>Telescope filetypes<cr>", { desc = "Find Filetypes" })
vim.keymap.set("n", "<leader>fT", "<cmd>Telescope builtin<cr>", { desc = "Find Telescope Pickers" })
vim.keymap.set("n", "<leader>f.", "<cmd>Telescope resume<cr>", { desc = "Resume Last Search" })
vim.keymap.set("n", "<leader>fn", "<cmd>Telescope file_browser<cr>", { desc = "Browse Next.js Project" })

-- Git commands
vim.keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Git Commits" })
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "DiffView Open" })
vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "DiffView Close" })
vim.keymap.set("n", "<leader>ge", "<cmd>Neotree git_status reveal float<cr>", { desc = "Git Explorer" })
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Lazygit" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File History" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Project History" })
vim.keymap.set("n", "<leader>gl", "<cmd>Git pull<cr>", { desc = "Git Pull" })
vim.keymap.set("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git Push" })
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Git Status" })
vim.keymap.set("n", "<leader>go", "<cmd>Octo<cr>", { desc = "Octo" })
vim.keymap.set("n", "<leader>gr", "<cmd>Octo pr list<cr>", { desc = "PR List" })
vim.keymap.set("n", "<leader>gi", "<cmd>Octo issue list<cr>", { desc = "Issue List" })

-- Git Signs / Hunks 
vim.keymap.set("n", "<leader>hb", function() require("gitsigns").blame_line({ full = true }) end, { desc = "Blame Line" })
vim.keymap.set("n", "<leader>hB", function() require("gitsigns").toggle_current_line_blame() end, { desc = "Toggle Line Blame" })
vim.keymap.set("n", "<leader>hd", function() require("gitsigns").diffthis() end, { desc = "Diff This" })
vim.keymap.set("n", "<leader>hD", function() require("gitsigns").diffthis("~") end, { desc = "Diff This ~" })
vim.keymap.set("n", "<leader>hp", function() require("gitsigns").preview_hunk() end, { desc = "Preview Hunk" })
vim.keymap.set("n", "<leader>hr", function() require("gitsigns").reset_hunk() end, { desc = "Reset Hunk" })
vim.keymap.set("n", "<leader>hR", function() require("gitsigns").reset_buffer() end, { desc = "Reset Buffer" })
vim.keymap.set("n", "<leader>hs", function() require("gitsigns").stage_hunk() end, { desc = "Stage Hunk" })
vim.keymap.set("n", "<leader>hS", function() require("gitsigns").stage_buffer() end, { desc = "Stage Buffer" })
vim.keymap.set("n", "<leader>hu", function() require("gitsigns").undo_stage_hunk() end, { desc = "Undo Stage Hunk" })

-- Noice and notifications
vim.keymap.set("n", "<leader>na", function() require("noice").cmd("all") end, { desc = "Noice All" })
vim.keymap.set("n", "<leader>nd", function() require("noice").cmd("dismiss") end, { desc = "Dismiss All" })
vim.keymap.set("n", "<leader>nh", function() require("noice").cmd("history") end, { desc = "Noice History" })
vim.keymap.set("n", "<leader>nl", function() require("noice").cmd("last") end, { desc = "Noice Last Message" })
vim.keymap.set("n", "<leader>ne", function() require("noice").cmd("errors") end, { desc = "Noice Errors" })
vim.keymap.set("n", "<leader>nn", function() require("noice").cmd("telescope") end, { desc = "Telescope Noice" })

-- Explorer keymaps (for both Oil and Neo-tree)
vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "File Explorer (Oil)" })
vim.keymap.set("n", "<leader>E", "<CMD>Oil --float<CR>", { desc = "File Explorer Floating (Oil)" })
vim.keymap.set("n", "<leader>o", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>O", "<CMD>Oil .<CR>", { desc = "Open project root" })
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "_", "<CMD>Oil .<CR>", { desc = "Open project root directory" })

-- Quick exit and sessions
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
vim.keymap.set("n", "<leader>qw", "<cmd>wqa<cr>", { desc = "Save and Quit All" })
vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore Session" })
vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore Last Session" })
vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't Save Current Session" })

-- Stack-specific commands
vim.keymap.set("n", "<leader>sg<leader>f", "<cmd>StackFocus goth<cr>", { desc = "Focus GOTH Stack" })
vim.keymap.set("n", "<leader>sn<leader>f", "<cmd>StackFocus nextjs<cr>", { desc = "Focus Next.js Stack" })

-- GOTH stack commands
vim.keymap.set("n", "<leader>sgn", function()
  vim.ui.input({ prompt = "Project name: " }, function(name)
    if name and name ~= "" then
      local Terminal = require("toggleterm.terminal").Terminal
      local goth_init = Terminal:new({
        cmd = string.format("mkdir -p %s && cd %s && go mod init %s && mkdir -p components handlers static", name, name, name),
        hidden = false,
        direction = "float",
        on_exit = function()
          vim.cmd("cd " .. name)
          vim.notify("GOTH project '" .. name .. "' initialized!", vim.log.levels.INFO)
        end,
      })
      goth_init:toggle()
    end
  end)
end, { desc = "New GOTH Project" })

vim.keymap.set("n", "<leader>sgr", function()
  local Terminal = require("toggleterm.terminal").Terminal
  local goth_run = Terminal:new({
    cmd = "templ generate && go run .",
    hidden = false,
    direction = "horizontal",
  })
  goth_run:toggle()
end, { desc = "Run GOTH Project" })

vim.keymap.set("n", "<leader>sgd", "<cmd>DebugGOTHApp<cr>", { desc = "Debug GOTH App" })
vim.keymap.set("n", "<leader>sgg", "<cmd>!templ generate<cr>", { desc = "Generate Templ Files" })
vim.keymap.set("n", "<leader>sgc", function() require("config.utils").new_templ_component() end, { desc = "New Templ Component" })
vim.keymap.set("n", "<leader>sgt", "<cmd>!go test ./...<cr>", { desc = "Run Go Tests" })
vim.keymap.set("n", "<leader>sgm", "<cmd>!go mod tidy<cr>", { desc = "Go Mod Tidy" })
vim.keymap.set("n", "<leader>sgb", "<cmd>!go build<cr>", { desc = "Go Build" })
vim.keymap.set("n", "<leader>sgp", "<cmd>StackFocus goth<cr>", { desc = "Focus GOTH Stack" })
vim.keymap.set("n", "<leader>sg<leader>e", function()
  vim.g.current_stack = "goth"
  vim.cmd("Oil")
end, { desc = "File Explorer (GOTH focus)" })

-- Next.js stack commands
vim.keymap.set("n", "<leader>snn", function()
  vim.ui.input({ prompt = "Project name: " }, function(name)
    if name and name ~= "" then
      local Terminal = require("toggleterm.terminal").Terminal
      local nextjs_init = Terminal:new({
        cmd = string.format("npx create-next-app@latest %s --typescript --eslint --tailwind --app --src-dir --import-alias '@/*'", name),
        hidden = false,
        direction = "float",
      })
      nextjs_init:toggle()
    end
  end)
end, { desc = "New Next.js Project" })

vim.keymap.set("n", "<leader>snd", function()
  local Terminal = require("toggleterm.terminal").Terminal
  local nextjs_dev = Terminal:new({
    cmd = "npm run dev",
    hidden = false,
    direction = "horizontal",
  })
  nextjs_dev:toggle()
end, { desc = "Run Development Server" })

vim.keymap.set("n", "<leader>snb", function()
  local Terminal = require("toggleterm.terminal").Terminal
  local nextjs_build = Terminal:new({
    cmd = "npm run build",
    hidden = false,
    direction = "horizontal",
  })
  nextjs_build:toggle()
end, { desc = "Build for Production" })

vim.keymap.set("n", "<leader>sns", function()
  local Terminal = require("toggleterm.terminal").Terminal
  local nextjs_start = Terminal:new({
    cmd = "npm run start",
    hidden = false,
    direction = "horizontal",
  })
  nextjs_start:toggle()
end, { desc = "Start Production Server" })

vim.keymap.set("n", "<leader>snt", function()
  local Terminal = require("toggleterm.terminal").Terminal
  local nextjs_test = Terminal:new({
    cmd = "npm run test",
    hidden = false,
    direction = "horizontal",
  })
  nextjs_test:toggle()
end, { desc = "Run Tests" })

vim.keymap.set("n", "<leader>snl", function()
  local Terminal = require("toggleterm.terminal").Terminal
  local nextjs_lint = Terminal:new({
    cmd = "npm run lint",
    hidden = false,
    direction = "horizontal",
  })
  nextjs_lint:toggle()
end, { desc = "Lint Project" })

vim.keymap.set("n", "<leader>snc", function() require("config.utils").new_nextjs_component("client") end, { desc = "New Client Component" })
vim.keymap.set("n", "<leader>snS", function() require("config.utils").new_nextjs_component("server") end, { desc = "New Server Component" })
vim.keymap.set("n", "<leader>snp", function() require("config.utils").new_nextjs_component("page") end, { desc = "New Page" })
vim.keymap.set("n", "<leader>snL", function() require("config.utils").new_nextjs_component("layout") end, { desc = "New Layout" })
vim.keymap.set("n", "<leader>snf", "<cmd>StackFocus nextjs<cr>", { desc = "Focus Next.js Stack" })
vim.keymap.set("n", "<leader>sn<leader>e", function()
  vim.g.current_stack = "nextjs"
  vim.cmd("Oil")
end, { desc = "File Explorer (Next.js focus)" })

-- Shared commands
vim.keymap.set("n", "<leader>sr", "<cmd>lua _G.toggle_htmx_server()<cr>", { desc = "Run Server" })

-- Terminal commands
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal (float)" })
vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal (horizontal)" })
vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal (vertical)" })
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>tb", function() require("gitsigns").toggle_current_line_blame() end, { desc = "Toggle Line Blame" })
vim.keymap.set("n", "<leader>td", function() require("gitsigns").toggle_deleted() end, { desc = "Toggle Deleted" })
vim.keymap.set("n", "<leader>tn", function() _G.toggle_node() end, { desc = "Node Terminal" })
vim.keymap.set("n", "<leader>tp", function() _G.toggle_python() end, { desc = "Python Terminal" })
vim.keymap.set("n", "<leader>tg", function() _G.toggle_go() end, { desc = "Go Terminal" })
vim.keymap.set("n", "<leader>ts", function() _G.toggle_htmx_server() end, { desc = "HTMX Server" })
vim.keymap.set("n", "<leader>tc", function() require("config.utils").toggle_colorcolumn() end, { desc = "Toggle Color Column" })
vim.keymap.set("n", "<leader>tw", function() vim.wo.wrap = not vim.wo.wrap; vim.notify("Wrap " .. (vim.wo.wrap and "enabled" or "disabled")) end, { desc = "Toggle Wrap" })
vim.keymap.set("n", "<leader>ta", "<cmd>FormatToggle<cr>", { desc = "Toggle Auto Format (global)" })
vim.keymap.set("n", "<leader>tA", "<cmd>FormatToggleBuffer<cr>", { desc = "Toggle Auto Format (buffer)" })

-- UI toggles and commands
vim.keymap.set("n", "<leader>uc", "<cmd>ColorSchemeToggle<cr>", { desc = "Toggle Colorscheme" })
vim.keymap.set("n", "<leader>un", function() require("notify").dismiss({ silent = true, pending = true }) end, { desc = "Dismiss Notifications" })
vim.keymap.set("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redraw / Clear Highlight" })
vim.keymap.set("n", "<leader>ut", "<cmd>ToggleTransparency<cr>", { desc = "Toggle Transparency" })
vim.keymap.set("n", "<leader>uT", "<cmd>ToggleTransparency<cr>", { desc = "Toggle Transparency" })
vim.keymap.set("n", "<leader>ul", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })
vim.keymap.set("n", "<leader>uL", "<cmd>LazyUpdate<cr>", { desc = "Update Plugins" })
vim.keymap.set("n", "<leader>um", "<cmd>Mason<cr>", { desc = "Mason LSP Manager" })
vim.keymap.set("n", "<leader>uM", "<cmd>MasonUpdate<cr>", { desc = "Update LSP Servers" })
vim.keymap.set("n", "<leader>uh", "<cmd>ToggleInlayHints<CR>", { desc = "Toggle inlay hints" })

-- Windows management
vim.keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split window below" })
vim.keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split window right" })
vim.keymap.set("n", "<leader>w2", "<C-W>v", { desc = "Layout double columns" })
vim.keymap.set("n", "<leader>wh", "<C-W>h", { desc = "Go to left window" })
vim.keymap.set("n", "<leader>wj", "<C-W>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<leader>wk", "<C-W>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<leader>wl", "<C-W>l", { desc = "Go to right window" })
vim.keymap.set("n", "<leader>wq", "<C-W>q", { desc = "Close window" })
vim.keymap.set("n", "<leader>ww", "<C-W>w", { desc = "Other window" })
vim.keymap.set("n", "<leader>w=", "<C-W>=", { desc = "Balance windows" })

-- Diagnostics and quickfix
vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Toggle Trouble" })
vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", { desc = "Document Diagnostics" })
vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { desc = "Location List" })
vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { desc = "Quickfix List" })
vim.keymap.set("n", "<leader>xt", "<cmd>TodoTrouble<cr>", { desc = "Todo Trouble" })
vim.keymap.set("n", "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", { desc = "Todo/Fix/Fixme Trouble" })
vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { desc = "Workspace Diagnostics" })
vim.keymap.set("n", "<leader>xf", function() require("config.utils").toggle_qf() end, { desc = "Toggle Quickfix" })

-- Navigation key pairs 
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
vim.keymap.set("n", "[c", function() require("gitsigns").prev_hunk() end, { desc = "Previous Hunk" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "[l", "<cmd>lprev<cr>", { desc = "Previous Location" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { desc = "Previous Quickfix" })
vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous Todo" })

vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "]c", function() require("gitsigns").next_hunk() end, { desc = "Next Hunk" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "]l", "<cmd>lnext<cr>", { desc = "Next Location" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next Quickfix" })
vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next Todo" })

-- Layout switching keymaps
vim.keymap.set("n", "<leader>L1", "<cmd>Layout coding<cr>", { desc = "Coding Layout" })
vim.keymap.set("n", "<leader>L2", "<cmd>Layout terminal<cr>", { desc = "Terminal Layout" })
vim.keymap.set("n", "<leader>L3", "<cmd>Layout writing<cr>", { desc = "Writing Layout" })
vim.keymap.set("n", "<leader>L4", "<cmd>Layout debug<cr>", { desc = "Debug Layout" })

-- LSP related keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
vim.keymap.set("n", "gr", function() require("telescope.builtin").lsp_references() end, { desc = "Go to References" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Type Definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show Documentation" })
vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

-- Move Lines (normal mode)
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })

-- Move Lines (insert mode)
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })

-- Move Lines (visual mode)
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

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

-- Clear search with <esc>
vim.keymap.set({"i", "n"}, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Save file
vim.keymap.set({"i", "x", "n", "s"}, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Unindent line" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent line" })

-- Paste over currently selected text without yanking it
vim.keymap.set("v", "p", '"_dP', { desc = "Better paste" })

-- Maintain cursor position when joining lines
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and maintain cursor position" })

-- Better navigation
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half a page and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half a page and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Flash.nvim keymaps
vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })
vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash treesitter" })
vim.keymap.set("o", "r", function() require("flash").remote() end, { desc = "Flash remote" })
vim.keymap.set({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Flash treesitter search" })
vim.keymap.set("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle flash search" })
