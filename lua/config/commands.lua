-- Centralized commands with Telescope integration and improved error handling

local M = {}

function M.setup()
  vim.api.nvim_create_user_command("ExplorerToggle", function()
    require("oil").open()
  end, { desc = "Toggle Oil file explorer" })

  vim.api.nvim_create_user_command("FinderToggle", function(opts)
    local finder = opts.fargs[1] or "files"
    local telescope = require("telescope.builtin")

    if finder == "files" then
      telescope.find_files()
    elseif finder == "grep" then
      telescope.live_grep()
    elseif finder == "buffers" then
      telescope.buffers()
    elseif finder == "help" then
      telescope.help_tags()
    else
      telescope.find_files()
    end
  end, {
    nargs = "*",
    complete = function() return { "files", "grep", "buffers", "help" } end,
    desc = "Open Telescope finder",
  })

  vim.api.nvim_create_user_command("Layout", function(opts)
    local layout = opts.args

    if layout == "coding" then
      require("oil").open()
      vim.api.nvim_command("wincmd l")
    elseif layout == "terminal" then
      require("oil").open()
      vim.api.nvim_command("wincmd l")
      require("toggleterm").toggle(1, 15, nil, "horizontal")
    elseif layout == "writing" then
      vim.api.nvim_command("only")
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
    elseif layout == "debug" then
      vim.api.nvim_command("only")
      require("dapui").open()
    else
      vim.notify("Available layouts: coding, terminal, writing, debug", vim.log.levels.INFO)
    end
  end, {
    nargs = "?",
    complete = function() return { "coding", "terminal", "writing", "debug" } end,
    desc = "Switch workspace layout",
  })

  -- ========================================
  -- Plugin Management
  -- ========================================
  vim.api.nvim_create_user_command("UpdateAll", function()
    vim.cmd("Lazy update")
    if package.loaded["mason"] then
      vim.cmd("MasonUpdate")
    end
    vim.notify("Updated plugins and Mason packages", vim.log.levels.INFO)
  end, { desc = "Update all plugins and Mason packages" })

  vim.api.nvim_create_user_command("PluginCheck", function()
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

  vim.api.nvim_create_user_command("ReloadConfig", function()
    for name, _ in pairs(package.loaded) do
      if name:match("^(config)\\.") or name:match("^(plugins)\\.") then
        package.loaded[name] = nil
      end
    end
    dofile(vim.fn.stdpath("config") .. "/init.lua")
    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO, { title = "Config" })
  end, { desc = "Reload Neovim configuration" })

  -- ========================================
  -- Diagnostics
  -- ========================================
  local function diagnostic_base_config()
    local ok, autocmds = pcall(require, "config.autocmds")
    if ok and autocmds.diagnostic_config then
      return autocmds.diagnostic_config
    end
    return vim.diagnostic.config()
  end

  vim.api.nvim_create_user_command("DiagnosticsToggle", function()
    local current = vim.diagnostic.config()
    local diagnostics_enabled = current.virtual_text ~= false
      or current.signs ~= false
      or current.underline ~= false

    local base = diagnostic_base_config()
    local new_config = vim.deepcopy(base)
    if diagnostics_enabled then
      new_config.virtual_text = false
      new_config.signs = false
      new_config.underline = false
    end

    vim.diagnostic.config(new_config)
    vim.notify("Diagnostics " .. (diagnostics_enabled and "disabled" or "enabled"), vim.log.levels.INFO)
  end, { desc = "Toggle diagnostic display" })
end

return M
