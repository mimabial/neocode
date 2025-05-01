-- Define keymaps using vim.keymap.set directly
-- Instead of defining keymaps through which-key, let which-key detect them

local picker = require("snacks.picker")

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

-- Snacks Finder keymaps
vim.keymap.set("n", "<leader>ff", function()
  picker.files()
end, { desc = "Find Files" })

vim.keymap.set("n", "<leader>fg", function()
  picker.grep()
end, { desc = "Find Text (Grep)" })

vim.keymap.set("n", "<leader>fb", function()
  picker.buffers()
end, { desc = "Find Buffers" })

vim.keymap.set("n", "<leader>fh", function()
  picker.help()
end, { desc = "Find Help" })

vim.keymap.set("n", "<leader>fr", function()
  picker.recent()
end, { desc = "Recent Files" })

vim.keymap.set("n", "<leader>fR", function()
  picker.smart()
end, { desc = "Frecent Files" })

vim.keymap.set("n", "<leader>fp", function()
  picker.projects()
end, { desc = "Find Projects" })

vim.keymap.set("n", "<leader>fc", function()
  picker.commands()
end, { desc = "Commands" })

vim.keymap.set("n", "<leader>fk", function()
  picker.keymaps()
end, { desc = "Keymaps" })

vim.keymap.set("n", "<leader>f/", function()
  picker.lines()
end, { desc = "Buffer Fuzzy Find" })

vim.keymap.set("n", "<leader>f.", function()
  picker.resume()
end, { desc = "Resume Search" })

-- Git integration (additional)
vim.keymap.set("n", "<leader>gc", function()
  picker.git_log()
end, { desc = "Git Commits" })

vim.keymap.set("n", "<leader>gb", function()
  picker.git_branches()
end, { desc = "Git Branches" })

-- LSP integration
vim.keymap.set("n", "<leader>fd", function()
  picker.diagnostics({ bufnr = 0 })
end, { desc = "Doc Diagnostics" })

vim.keymap.set("n", "<leader>fD", function()
  picker.diagnostics()
end, { desc = "Workspace Diagnostics" })

vim.keymap.set("n", "<leader>fs", function()
  picker.lsp_symbols()
end, { desc = "Doc Symbols" })

vim.keymap.set("n", "<leader>fS", function()
  picker.lsp_workspace_symbols()
end, { desc = "Workspace Symbols" })

-- Stack-specific
vim.keymap.set("n", "<leader>sgg", function()
  picker.pick("goth_files")
end, { desc = "GOTH Files" })

vim.keymap.set("n", "<leader>sng", function()
  picker.pick("nextjs_files")
end, { desc = "Next.js Files" })

-- Oil explorer keymaps (primary file explorer)
vim.keymap.set("n", "<leader>o", "<CMD>Oil<CR>", { desc = "Oil Explorer" })
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "_", "<CMD>Oil .<CR>", { desc = "Open project root" })

-- Snacks explorer keymaps (alternative file explorer)
vim.keymap.set("n", "<leader>e", function()
  if package.loaded["snacks"] then
    require("snacks").explorer()
  end
end, { desc = "Snacks Explorer" })
