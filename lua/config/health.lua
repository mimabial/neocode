local M = {}

-- Check if required external tools are available
M.check_external_tools = function()
  local tools = {
    { name = "git", required = true, desc = "Version control" },
    { name = "rg", required = true, desc = "Ripgrep for telescope" },
    { name = "fd", required = false, desc = "Fast file finder" },
    { name = "lazygit", required = false, desc = "Git UI" },
    { name = "node", required = false, desc = "Node.js for LSP servers" },
    { name = "go", required = false, desc = "Go development" },
  }

  local issues = {}
  for _, tool in ipairs(tools) do
    if vim.fn.executable(tool.name) == 0 then
      if tool.required then
        table.insert(issues, "❌ Missing required tool: " .. tool.name .. " (" .. tool.desc .. ")")
      else
        table.insert(issues, "⚠️  Missing optional tool: " .. tool.name .. " (" .. tool.desc .. ")")
      end
    end
  end

  return issues
end

-- Check plugin health
M.check_plugins = function()
  local issues = {}
  local plugins = require("lazy.core.config").plugins

  for name, plugin in pairs(plugins) do
    if plugin._.error then
      table.insert(issues, "❌ Plugin error: " .. name .. " - " .. plugin._.error)
    end
  end

  return issues
end

-- Check LSP health
M.check_lsp = function()
  local issues = {}
  local clients = vim.lsp.get_clients()

  if #clients == 0 then
    table.insert(issues, "⚠️  No LSP clients attached")
  end

  return issues
end

-- Check keybinding conflicts
M.check_keybindings = function()
  local issues = {}
  local keymaps = vim.api.nvim_get_keymap("n")
  local seen = {}

  for _, map in ipairs(keymaps) do
    if seen[map.lhs] then
      table.insert(issues, "⚠️  Duplicate keymap: " .. map.lhs)
    end
    seen[map.lhs] = true
  end

  return issues
end

-- Main health check function
M.check = function()
  print("🏥 Running Configuration Health Check...\n")

  local all_issues = {}

  -- Check external tools
  local tool_issues = M.check_external_tools()
  vim.list_extend(all_issues, tool_issues)

  -- Check plugins
  local plugin_issues = M.check_plugins()
  vim.list_extend(all_issues, plugin_issues)

  -- Check LSP
  local lsp_issues = M.check_lsp()
  vim.list_extend(all_issues, lsp_issues)

  -- Check keybindings
  local keymap_issues = M.check_keybindings()
  vim.list_extend(all_issues, keymap_issues)

  if #all_issues == 0 then
    print("✅ All health checks passed!")
  else
    print("Found " .. #all_issues .. " issues:")
    for _, issue in ipairs(all_issues) do
      print("  " .. issue)
    end
  end

  return #all_issues == 0
end

-- Create health check command
vim.api.nvim_create_user_command("ConfigHealth", M.check, {
  desc = "Run configuration health checks",
})

return M
