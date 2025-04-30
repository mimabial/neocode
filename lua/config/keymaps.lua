-- Define keymaps using vim.keymap.set directly
-- Instead of defining keymaps through which-key, let which-key detect them

-- Buffer management
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bf", "<cmd>bfirst<cr>", { desc = "First Buffer" })
vim.keymap.set("n", "<leader>bl", "<cmd>blast<cr>", { desc = "Last Buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>be", "<cmd>Oil<cr>", { desc = "Buffer Explorer (Oil)" })

-- Buffer navigation with Shift
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- LSP and Code actions
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "<leader>cf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format" })
vim.keymap.set("n", "<leader>cF", "<cmd>FormatToggle<CR>", { desc = "Toggle Format on Save" })
vim.keymap.set("n", "<leader>ci", "<cmd>LspInfo<cr>", { desc = "LSP Info" })
vim.keymap.set("n", "<leader>cl", "<cmd>lua require('lint').try_lint()<cr>", { desc = "Trigger Linting" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set("n", "<leader>cR", "<cmd>ReloadConfig<cr>", { desc = "Reload Config" })

-- GOTH stack specific
vim.keymap.set("n", "<leader>cgc", function()
  if require("config.utils").new_templ_component then
    require("config.utils").new_templ_component()
  else
    vim.notify("Templ component creator not found", vim.log.levels.ERROR)
  end
end, { desc = "New Templ Component" })
vim.keymap.set("n", "<leader>cgt", "<cmd>!go test ./...<cr>", { desc = "Run Go Tests" })
vim.keymap.set("n", "<leader>cgm", "<cmd>!go mod tidy<cr>", { desc = "Go Mod Tidy" })
vim.keymap.set("n", "<leader>cgb", "<cmd>!go build<cr>", { desc = "Go Build" })
vim.keymap.set("n", "<leader>cgr", "<cmd>!go run .<cr>", { desc = "Go Run" })

-- Next.js specific
vim.keymap.set("n", "<leader>cnc", function()
  if require("config.utils").new_nextjs_component then
    require("config.utils").new_nextjs_component("client")
  else
    vim.notify("Next.js component creator not found", vim.log.levels.ERROR)
  end
end, { desc = "New Client Component" })
vim.keymap.set("n", "<leader>cns", function()
  if require("config.utils").new_nextjs_component then
    require("config.utils").new_nextjs_component("server")
  else
    vim.notify("Next.js component creator not found", vim.log.levels.ERROR)
  end
end, { desc = "New Server Component" })
vim.keymap.set("n", "<leader>cnp", function()
  if require("config.utils").new_nextjs_component then
    require("config.utils").new_nextjs_component("page")
  else
    vim.notify("Next.js component creator not found", vim.log.levels.ERROR)
  end
end, { desc = "New Page" })
vim.keymap.set("n", "<leader>cnl", function()
  if require("config.utils").new_nextjs_component then
    require("config.utils").new_nextjs_component("layout")
  else
    vim.notify("Next.js component creator not found", vim.log.levels.ERROR)
  end
end, { desc = "New Layout" })
vim.keymap.set("n", "<leader>cnd", "<cmd>!npm run dev<cr>", { desc = "Next.js Dev" })
vim.keymap.set("n", "<leader>cnb", "<cmd>!npm run build<cr>", { desc = "Next.js Build" })
vim.keymap.set("n", "<leader>cnt", "<cmd>!npm test<cr>", { desc = "Run Tests" })
vim.keymap.set("n", "<leader>cni", "<cmd>!npm install<cr>", { desc = "NPM Install" })

-- Debug mode keymaps
vim.keymap.set("n", "<leader>db", function()
  if package.loaded["dap"] then
    require("dap").toggle_breakpoint()
  end
end, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
  if package.loaded["dap"] then
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end
end, { desc = "Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dc", function()
  if package.loaded["dap"] then
    require("dap").continue()
  end
end, { desc = "Continue" })
vim.keymap.set("n", "<leader>dC", function()
  if package.loaded["dap"] then
    require("dap").run_to_cursor()
  end
end, { desc = "Run to Cursor" })
vim.keymap.set("n", "<leader>de", function()
  if package.loaded["dapui"] then
    require("dapui").eval()
  end
end, { desc = "Evaluate Expression" })
vim.keymap.set("n", "<leader>di", function()
  if package.loaded["dap"] then
    require("dap").step_into()
  end
end, { desc = "Step Into" })
vim.keymap.set("n", "<leader>do", function()
  if package.loaded["dap"] then
    require("dap").step_over()
  end
end, { desc = "Step Over" })
vim.keymap.set("n", "<leader>dO", function()
  if package.loaded["dap"] then
    require("dap").step_out()
  end
end, { desc = "Step Out" })
vim.keymap.set("n", "<leader>dr", function()
  if package.loaded["dap"] then
    require("dap").repl.toggle()
  end
end, { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>dR", function()
  if package.loaded["dap"] then
    require("dap").restart()
  end
end, { desc = "Restart" })
vim.keymap.set("n", "<leader>dt", function()
  if package.loaded["dap"] then
    require("dap").terminate()
  end
end, { desc = "Terminate" })
vim.keymap.set("n", "<leader>du", function()
  if package.loaded["dapui"] then
    require("dapui").toggle()
  end
end, { desc = "Toggle UI" })
vim.keymap.set("n", "<leader>dg", function()
  if _G.debug_goth_app then
    _G.debug_goth_app()
  end
end, { desc = "Debug GOTH App" })

-- Function keys for debugging
vim.keymap.set("n", "<F5>", function()
  if package.loaded["dap"] then
    require("dap").continue()
  end
end, { desc = "Continue" })
vim.keymap.set("n", "<F10>", function()
  if package.loaded["dap"] then
    require("dap").step_over()
  end
end, { desc = "Step Over" })
vim.keymap.set("n", "<F11>", function()
  if package.loaded["dap"] then
    require("dap").step_into()
  end
end, { desc = "Step Into" })
vim.keymap.set("n", "<F12>", function()
  if package.loaded["dap"] then
    require("dap").step_out()
  end
end, { desc = "Step Out" })

-- Snacks Finder keymaps (for file finding, not explorer)
vim.keymap.set("n", "<leader>ff", function()
  if package.loaded["snacks.picker"] then
    require("snacks.picker").files()
  end
end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function()
  if package.loaded["snacks.picker"] then
    require("snacks.picker").grep()
  end
end, { desc = "Find Text (Grep)" })
vim.keymap.set("n", "<leader>fb", function()
  if package.loaded["snacks.picker"] then
    require("snacks.picker").buffers()
  end
end, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fh", function()
  if package.loaded["snacks.picker"] then
    require("snacks.picker").help()
  end
end, { desc = "Find Help" })
vim.keymap.set("n", "<leader>fr", function()
  if package.loaded["snacks.picker"] then
    require("snacks.picker").recent()
  end
end, { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fR", function()
  if package.loaded["snacks.picker"] then
    require("snacks.picker").smart()
  end
end, { desc = "Frecent Files" })
vim.keymap.set("n", "<leader>fp", function()
  if package.loaded["snacks.picker"] then
    require("snacks.picker").projects()
  end
end, { desc = "Find Projects" })

-- Oil explorer keymaps (primary file explorer)
vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Oil Explorer" })
vim.keymap.set("n", "<leader>E", "<CMD>Oil --float<CR>", { desc = "Oil Explorer (float)" })
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "_", "<CMD>Oil .<CR>", { desc = "Open project root" })

-- Git commands
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "DiffView Open" })
vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "DiffView Close" })
vim.keymap.set("n", "<leader>ge", "<cmd>Oil<cr>", { desc = "Git Explorer (Oil)" })
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Lazygit" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File History" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Project History" })
vim.keymap.set("n", "<leader>gl", "<cmd>Git pull<cr>", { desc = "Git Pull" })
vim.keymap.set("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git Push" })
vim.keymap.set("n", "<leader>gs", function()
  if package.loaded["snacks.picker"] then
    require("snacks.picker").git_status()
  else
    vim.cmd("Git")
  end
end, { desc = "Git Status" })

-- Git Signs / Hunks
vim.keymap.set("n", "<leader>hb", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").blame_line({ full = true })
  end
end, { desc = "Blame Line" })
vim.keymap.set("n", "<leader>hB", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").toggle_current_line_blame()
  end
end, { desc = "Toggle Line Blame" })
vim.keymap.set("n", "<leader>hd", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").diffthis()
  end
end, { desc = "Diff This" })
vim.keymap.set("n", "<leader>hD", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").diffthis("~")
  end
end, { desc = "Diff This ~" })
vim.keymap.set("n", "<leader>hp", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").preview_hunk()
  end
end, { desc = "Preview Hunk" })
vim.keymap.set("n", "<leader>hr", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").reset_hunk()
  end
end, { desc = "Reset Hunk" })
vim.keymap.set("n", "<leader>hR", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").reset_buffer()
  end
end, { desc = "Reset Buffer" })
vim.keymap.set("n", "<leader>hs", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").stage_hunk()
  end
end, { desc = "Stage Hunk" })
vim.keymap.set("n", "<leader>hS", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").stage_buffer()
  end
end, { desc = "Stage Buffer" })
vim.keymap.set("n", "<leader>hu", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").undo_stage_hunk()
  end
end, { desc = "Undo Stage Hunk" })

-- Noice and notifications
vim.keymap.set("n", "<leader>na", function()
  if package.loaded["noice"] then
    require("noice").cmd("all")
  end
end, { desc = "Noice All" })
vim.keymap.set("n", "<leader>nd", function()
  if package.loaded["noice"] then
    require("noice").cmd("dismiss")
  end
end, { desc = "Dismiss All" })
vim.keymap.set("n", "<leader>nh", function()
  if package.loaded["noice"] then
    require("noice").cmd("history")
  end
end, { desc = "Noice History" })
vim.keymap.set("n", "<leader>nl", function()
  if package.loaded["noice"] then
    require("noice").cmd("last")
  end
end, { desc = "Noice Last Message" })
vim.keymap.set("n", "<leader>ne", function()
  if package.loaded["noice"] then
    require("noice").cmd("errors")
  end
end, { desc = "Noice Errors" })

-- Stack-specific commands
vim.keymap.set("n", "<leader>sg<leader>f", "<cmd>StackFocus goth<cr>", { desc = "Focus GOTH Stack" })
vim.keymap.set("n", "<leader>sn<leader>f", "<cmd>StackFocus nextjs<cr>", { desc = "Focus Next.js Stack" })

-- GOTH stack commands
vim.keymap.set("n", "<leader>sgn", function()
  vim.ui.input({ prompt = "Project name: " }, function(name)
    if name and name ~= "" then
      local ok, Terminal = pcall(require, "toggleterm.terminal")
      if ok then
        local Terminal = Terminal.Terminal
        local goth_init = Terminal:new({
          cmd = string.format(
            "mkdir -p %s && cd %s && go mod init %s && mkdir -p components handlers static",
            name,
            name,
            name
          ),
          hidden = false,
          direction = "float",
          on_exit = function()
            vim.cmd("cd " .. name)
            vim.notify("GOTH project '" .. name .. "' initialized!", vim.log.levels.INFO)
          end,
        })
        goth_init:toggle()
      else
        vim.notify("toggleterm.nvim not available for GOTH project initialization", vim.log.levels.ERROR)
      end
    end
  end)
end, { desc = "New GOTH Project" })

vim.keymap.set("n", "<leader>sgr", function()
  local ok, Terminal = pcall(require, "toggleterm.terminal")
  if ok then
    local Terminal = Terminal.Terminal
    local goth_run = Terminal:new({
      cmd = "templ generate && go run .",
      hidden = false,
      direction = "horizontal",
    })
    goth_run:toggle()
  else
    -- Fallback to system command
    vim.cmd("!templ generate && go run .")
  end
end, { desc = "Run GOTH Project" })

vim.keymap.set("n", "<leader>sgd", "<cmd>DebugGOTHApp<cr>", { desc = "Debug GOTH App" })
vim.keymap.set("n", "<leader>sgg", "<cmd>!templ generate<cr>", { desc = "Generate Templ Files" })
vim.keymap.set("n", "<leader>sgc", function()
  if require("config.utils").new_templ_component then
    require("config.utils").new_templ_component()
  end
end, { desc = "New Templ Component" })
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
      local ok, Terminal = pcall(require, "toggleterm.terminal")
      if ok then
        local Terminal = Terminal.Terminal
        local nextjs_init = Terminal:new({
          cmd = string.format(
            "npx create-next-app@latest %s --typescript --eslint --tailwind --app --src-dir --import-alias '@/*'",
            name
          ),
          hidden = false,
          direction = "float",
        })
        nextjs_init:toggle()
      else
        -- Fallback
        vim.cmd(
          "!npx create-next-app@latest "
            .. name
            .. " --typescript --eslint --tailwind --app --src-dir --import-alias '@/*'"
        )
      end
    end
  end)
end, { desc = "New Next.js Project" })

vim.keymap.set("n", "<leader>snd", function()
  local ok, Terminal = pcall(require, "toggleterm.terminal")
  if ok then
    local Terminal = Terminal.Terminal
    local nextjs_dev = Terminal:new({
      cmd = "npm run dev",
      hidden = false,
      direction = "horizontal",
    })
    nextjs_dev:toggle()
  else
    -- Fallback
    vim.cmd("!npm run dev")
  end
end, { desc = "Run Development Server" })

-- Terminal commands
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal (float)" })
vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal (horizontal)" })
vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal (vertical)" })
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>tc", function()
  if require("config.utils").toggle_colorcolumn then
    require("config.utils").toggle_colorcolumn()
  else
    vim.wo.colorcolumn = vim.wo.colorcolumn == "" and "80,100,120" or ""
  end
end, { desc = "Toggle Color Column" })
vim.keymap.set("n", "<leader>tw", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify("Wrap " .. (vim.wo.wrap and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle Wrap" })
vim.keymap.set("n", "<leader>ta", "<cmd>FormatToggle<cr>", { desc = "Toggle Auto Format (global)" })
vim.keymap.set("n", "<leader>tA", "<cmd>FormatToggleBuffer<cr>", { desc = "Toggle Auto Format (buffer)" })

-- UI toggles and commands
vim.keymap.set("n", "<leader>uc", "<cmd>ColorSchemeToggle<cr>", { desc = "Toggle Colorscheme" })
vim.keymap.set("n", "<leader>un", function()
  if package.loaded["notify"] then
    require("notify").dismiss({ silent = true, pending = true })
  end
end, { desc = "Dismiss Notifications" })
vim.keymap.set(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / Clear Highlight" }
)
vim.keymap.set("n", "<leader>ut", "<cmd>ToggleTransparency<cr>", { desc = "Toggle Transparency" })
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
vim.keymap.set("n", "<leader>xf", function()
  if require("config.utils").toggle_qf then
    require("config.utils").toggle_qf()
  else
    -- Fallback toggle
    if vim.fn.getwininfo(vim.fn.win_getid())[1].quickfix == 1 then
      vim.cmd("cclose")
    else
      vim.cmd("copen")
    end
  end
end, { desc = "Toggle Quickfix" })

-- Navigation key pairs
vim.keymap.set("n", "[c", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").prev_hunk()
  end
end, { desc = "Previous Hunk" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "[l", "<cmd>lprev<cr>", { desc = "Previous Location" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { desc = "Previous Quickfix" })
vim.keymap.set("n", "[t", function()
  if package.loaded["todo-comments"] then
    require("todo-comments").jump_prev()
  end
end, { desc = "Previous Todo" })

vim.keymap.set("n", "]c", function()
  if package.loaded["gitsigns"] then
    require("gitsigns").next_hunk()
  end
end, { desc = "Next Hunk" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "]l", "<cmd>lnext<cr>", { desc = "Next Location" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next Quickfix" })
vim.keymap.set("n", "]t", function()
  if package.loaded["todo-comments"] then
    require("todo-comments").jump_next()
  end
end, { desc = "Next Todo" })

-- Layout switching keymaps
vim.keymap.set("n", "<leader>L1", "<cmd>Layout coding<cr>", { desc = "Coding Layout" })
vim.keymap.set("n", "<leader>L2", "<cmd>Layout terminal<cr>", { desc = "Terminal Layout" })
vim.keymap.set("n", "<leader>L3", "<cmd>Layout writing<cr>", { desc = "Writing Layout" })
vim.keymap.set("n", "<leader>L4", "<cmd>Layout debug<cr>", { desc = "Debug Layout" })

-- LSP related keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
vim.keymap.set("n", "gr", function()
  if package.loaded["snacks.picker"] then
    require("snacks.picker").lsp_references()
  else
    vim.lsp.buf.references()
  end
end, { desc = "Go to References" })
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
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Save file
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

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

-- Initialize which-key for displaying keymaps
-- Note: This should be the LAST thing in this file
if package.loaded["which-key"] then
  require("which-key").register({
    ["<leader>b"] = { name = "+Buffer" },
    ["<leader>c"] = { name = "+Code/LSP" },
    ["<leader>d"] = { name = "+Debug" },
    ["<leader>f"] = { name = "+Find" },
    ["<leader>g"] = { name = "+Git" },
    ["<leader>h"] = { name = "+Hunks" },
    ["<leader>L"] = { name = "+Layouts" },
    ["<leader>n"] = { name = "+Notifications" },
    ["<leader>s"] = { name = "+Stack" },
    ["<leader>t"] = { name = "+Terminal/Toggle" },
    ["<leader>u"] = { name = "+UI" },
    ["<leader>w"] = { name = "+Windows" },
    ["<leader>x"] = { name = "+Diagnostics" },

    -- Stack specific groups
    ["<leader>sg"] = { name = "+GOTH Stack" },
    ["<leader>sn"] = { name = "+Next.js Stack" },

    -- LSP groups
    ["<leader>cg"] = { name = "+GOTH" },
    ["<leader>cn"] = { name = "+Next.js" },
  })
end
