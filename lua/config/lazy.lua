-- lua/config/lazy.lua (modified)
local M = {}

-- Helper for safe loads
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[Warning] Could not load '%s': %s", mod, m), vim.log.levels.WARN)
    return nil
  end
  return m
end

function M.setup()
  -- Plugin specification
  require("lazy").setup({
    spec = {
      { import = "plugins" },
    },
    defaults = { lazy = true, version = false },
    install = {
      colorscheme = { "gruvbox-material" },
      missing = true,
    },
    ui = {
      border = "single",
      size = { width = 0.8, height = 0.8 },
      icons = {
        loaded = "●",
        not_loaded = "○",
        lazy = "󰒲 ",
        cmd = " ",
        config = "",
        event = "",
        ft = " ",
        init = " ",
        keys = " ",
        plugin = " ",
        runtime = " ",
        require = "󰢱 ",
        source = " ",
        start = "",
        task = "✓",
        list = {
          "●",
          "➜",
          "★",
          "‒",
        },
      },
    },
    checker = { enabled = true, notify = false, frequency = 3600 },
    change_detection = { enabled = true, notify = false },
    performance = {
      rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
      cache = { enabled = true },
      reset_packpath = true,
      reset_rtp = false,
    },
    -- Enhanced debugging for troubleshooting
    debug = false,
  })

  -- 6) Custom user commands
  local api = vim.api

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

  -- Reload configuration command
  api.nvim_create_user_command("ReloadConfig", function()
    -- Clear loaded modules
    for name, _ in pairs(package.loaded) do
      if name:match("^(config)\\.") or name:match("^(plugins)\\.") then
        package.loaded[name] = nil
      end
    end
    -- Reload init.lua
    dofile(vim.fn.stdpath("config") .. "/init.lua")
    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO, { title = "Config" })
  end, { desc = "Reload Neovim configuration" })

  -- Stack switching command
  api.nvim_create_user_command("StackFocus", function(opts)
    local stack_module = safe_require("config.stacks")
    if stack_module then
      stack_module.configure_stack(opts.args)
    else
      vim.notify("Stack module not available", vim.log.levels.ERROR)
    end
  end, {
    nargs = "?",
    desc = "Focus on a specific tech stack",
    complete = function()
      return { "goth", "nextjs", "both" }
    end,
  })

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

  -- Treesitter parser installation command
  api.nvim_create_user_command("InstallTSParsers", function()
    -- List of parsers to install for both stacks
    local parsers = {
      "javascript",
      "typescript",
      "tsx",
      "jsx",
      "go",
      "gomod",
      "templ",
      "html",
      "css",
      "json",
    }

    local install_cmd = "TSInstall " .. table.concat(parsers, " ")
    local ok, err = pcall(vim.api.nvim_command, install_cmd)

    if ok then
      vim.notify("Successfully installed TreeSitter parsers", vim.log.levels.INFO)
    else
      vim.notify("Error installing TreeSitter parsers: " .. tostring(err), vim.log.levels.ERROR)
    end
  end, { desc = "Install TreeSitter parsers for both stacks" })
end

return M
