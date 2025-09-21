local M = {}

-- Available extras
M.extras = {
  -- Language extras
  ["lang.go"] = "lua/extras/lang/go.lua",
  ["lang.typescript"] = "lua/extras/lang/typescript.lua",
  ["lang.python"] = "lua/extras/lang/python.lua",

  -- UI extras
  ["ui.animations"] = "lua/extras/ui/animations.lua",
  ["ui.dashboard"] = "lua/extras/ui/dashboard.lua",
  ["ui.winbar"] = "lua/extras/ui/winbar.lua",

  -- Editor extras
  ["editor.navic"] = "lua/extras/editor/navic.lua",
  ["editor.outline"] = "lua/extras/editor/outline.lua",
  ["editor.flash"] = "lua/extras/editor/flash.lua",

  -- Coding extras
  ["coding.luasnip"] = "lua/extras/coding/luasnip.lua",
  ["coding.copilot-chat"] = "lua/extras/coding/copilot-chat.lua",

  -- Tools extras
  ["tools.docker"] = "lua/extras/tools/docker.lua",
  ["tools.rest"] = "lua/extras/tools/rest.lua",

  -- Debug extras
  ["dap.core"] = "lua/extras/dap/core.lua",
  ["dap.go"] = "lua/extras/dap/go.lua",
  ["dap.node"] = "lua/extras/dap/node.lua",
}

-- Load extra
M.load_extra = function(name)
  local path = M.extras[name]
  if not path then
    vim.notify("Extra '" .. name .. "' not found", vim.log.levels.ERROR)
    return false
  end

  local extra_path = vim.fn.stdpath("config") .. "/" .. path
  if vim.fn.filereadable(extra_path) == 0 then
    vim.notify("Extra file not found: " .. extra_path, vim.log.levels.ERROR)
    return false
  end

  local ok, result = pcall(dofile, extra_path)
  if not ok then
    vim.notify("Failed to load extra '" .. name .. "': " .. result, vim.log.levels.ERROR)
    return false
  end

  vim.notify("Loaded extra: " .. name, vim.log.levels.INFO)
  return true
end

-- List available extras
M.list_extras = function()
  print("Available extras:")
  for name, path in pairs(M.extras) do
    local installed = vim.fn.filereadable(vim.fn.stdpath("config") .. "/" .. path) == 1
    local status = installed and "✅" or "⭕"
    print("  " .. status .. " " .. name)
  end
end

-- Telescope picker for extras
M.pick_extra = function()
  local has_telescope = pcall(require, "telescope")
  if not has_telescope then
    vim.notify("Telescope not available", vim.log.levels.WARN)
    M.list_extras()
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local extras_list = {}
  for name, path in pairs(M.extras) do
    local installed = vim.fn.filereadable(vim.fn.stdpath("config") .. "/" .. path) == 1
    table.insert(extras_list, {
      name = name,
      path = path,
      installed = installed,
      display = (installed and "✅ " or "⭕ ") .. name
    })
  end

  pickers.new({}, {
    prompt_title = "Available Extras",
    finder = finders.new_table({
      results = extras_list,
      entry_maker = function(entry)
        return {
          value = entry.name,
          display = entry.display,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        M.load_extra(selection.value)
      end)
      return true
    end,
  }):find()
end

-- Auto-enable recommended extras based on current directory
M.auto_enable_recommended = function()
  local cwd = vim.fn.getcwd()

  -- Check for Go project
  if vim.fn.filereadable(cwd .. "/go.mod") == 1 then
    M.load_extra("lang.go")
  end

  -- Check for TypeScript/JavaScript project
  if vim.fn.filereadable(cwd .. "/package.json") == 1 then
    M.load_extra("lang.typescript")
  end

  -- Check for Python project
  if vim.fn.filereadable(cwd .. "/requirements.txt") == 1 or
      vim.fn.filereadable(cwd .. "/pyproject.toml") == 1 then
    M.load_extra("lang.python")
  end

  -- Check for Docker
  if vim.fn.filereadable(cwd .. "/Dockerfile") == 1 or
      vim.fn.filereadable(cwd .. "/docker-compose.yml") == 1 then
    M.load_extra("tools.docker")
  end
end

-- Commands
vim.api.nvim_create_user_command("Extras", M.pick_extra, {
  desc = "Browse and enable extras"
})

vim.api.nvim_create_user_command("ExtrasList", M.list_extras, {
  desc = "List available extras"
})

vim.api.nvim_create_user_command("ExtrasAuto", M.auto_enable_recommended, {
  desc = "Auto-enable recommended extras"
})

return M
