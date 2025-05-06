-- lua/config/commands.lua
-- Centralized Neovim user commands (ReloadConfig, ExplorerToggle, HlsLensToggle, and Layout)

local M = {}
local api = vim.api

-- Utility to safely require modules
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[Commands] Could not load '%s': %s", mod, m), vim.log.levels.WARN)
    return nil
  end
  return m
end

function M.setup()
  -- Lazygit toggle with fallback
  api.nvim_create_user_command("LazyGit", function()
    local ok, term = pcall(require, "toggleterm.terminal")
    if ok then
      if _G.toggle_lazygit then
        _G.toggle_lazygit()
      else
        local Terminal = term.Terminal or error("Toggleterm missing Terminal class")
        _G.toggle_lazygit = Terminal:new({
          cmd = "lazygit",
          direction = "float",
          float_opts = { border = "rounded" },
          on_exit = function()
            -- Try to refresh gitsigns if available
            pcall(function()
              require("gitsigns").refresh()
            end)
          end,
        }).toggle
        _G.toggle_lazygit()
      end
    else
      vim.cmd("!lazygit")
    end
  end, { desc = "Open Lazygit" })
  -- Update all plugins and Mason packages
  api.nvim_create_user_command("UpdateAll", function()
    vim.cmd("Lazy update")
    if package.loaded["mason"] then
      vim.cmd("MasonUpdate")
    end
    vim.notify("Updated plugins and Mason packages", vim.log.levels.INFO)
  end, { desc = "Update all plugins and Mason packages" })

  -- Check and display plugin errors
  api.nvim_create_user_command("PluginCheck", function()
    local plugins = require("lazy.core.config").plugins
    local errors = {}

    for name, plugin in pairs(plugins) do
      if plugin._.error then
        table.insert(errors, { name = name, error = plugin._.error })
      end
    end

    if #errors == 0 then
      vim.notify("No plugin errors detected!", vim.log.levels.INFO, { title = "Plugin Check" })
    else
      vim.notify("Found errors in " .. #errors .. " plugins", vim.log.levels.ERROR, { title = "Plugin Check" })
      for _, err in ipairs(errors) do
        vim.notify(err.name .. ": " .. err.error, vim.log.levels.ERROR)
      end
    end
  end, { desc = "Check for plugin errors" })

  -- ReloadConfig: clear loaded config/plugins and re-source init.lua
  api.nvim_create_user_command("ReloadConfig", function()
    for name, _ in pairs(package.loaded) do
      if name:match("^(config)\\.") or name:match("^(plugins)\\.") then
        package.loaded[name] = nil
      end
    end
    dofile(vim.fn.stdpath("config") .. "/init.lua")
    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO, { title = "Config" })
  end, { desc = "Reload Neovim configuration" })
end

return M
