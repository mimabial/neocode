-- Centralized commands with Telescope integration and improved error handling

local M = {}

-- Utility to safely require modules
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[Commands] Could not load '%s'", mod), vim.log.levels.WARN)
    return nil
  end
  return m
end

function M.setup()
  -- Explorer toggle command - prioritizes Oil
  vim.api.nvim_create_user_command("ExplorerToggle", function(opts)
    local explorer = opts.args ~= "" and opts.args or vim.g.default_explorer or "oil"

    if explorer == "oil" then
      local oil = safe_require("oil")
      if oil then
        oil.open()
      else
        -- Fallback to netrw if oil not available
        vim.notify("Oil not found, falling back to built-in explorer", vim.log.levels.WARN)
        vim.cmd("Explore")
      end
    end
  end, {
    nargs = "?",
    complete = function()
      return { "oil", "snacks" }
    end,
    desc = "Toggle file explorer (oil or snacks)",
  })

  -- Finder toggle command - prioritizes Telescope
  vim.api.nvim_create_user_command("FinderToggle", function(opts)
    local picker = opts.args ~= "" and opts.args or vim.g.default_picker or "telescope"
    local finder = opts.fargs[2] or "files"

    if picker == "telescope" then
      local telescope = safe_require("telescope.builtin")
      if telescope then
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
      else
        -- Fallback to snacks or built-in commands
        local snacks = safe_require("snacks.picker")
        if snacks then
          if finder == "files" then
            snacks.files()
          elseif finder == "grep" then
            snacks.grep()
          elseif finder == "buffers" then
            snacks.buffers()
          else
            snacks.files()
          end
        else
          -- Ultimate fallback to built-in commands
          if finder == "files" then
            vim.cmd("find")
          elseif finder == "grep" then
            vim.ui.input({ prompt = "Search pattern: " }, function(input)
              if input and input ~= "" then
                vim.cmd("vimgrep " .. input .. " **/*")
                vim.cmd("copen")
              end
            end)
          elseif finder == "buffers" then
            vim.cmd("ls")
          else
            vim.cmd("find")
          end
        end
      end
    elseif picker == "snacks" then
      local snacks = safe_require("snacks.picker")
      if snacks then
        if finder == "files" then
          snacks.files()
        elseif finder == "grep" then
          snacks.grep()
        elseif finder == "buffers" then
          snacks.buffers()
        else
          snacks.files()
        end
      else
        -- Fallback to telescope or built-in commands
        local telescope = safe_require("telescope.builtin")
        if telescope then
          if finder == "files" then
            telescope.find_files()
          elseif finder == "grep" then
            telescope.live_grep()
          elseif finder == "buffers" then
            telescope.buffers()
          else
            telescope.find_files()
          end
        else
          -- Ultimate fallback to built-in commands
          if finder == "files" then
            vim.cmd("find")
          elseif finder == "grep" then
            vim.ui.input({ prompt = "Search pattern: " }, function(input)
              if input and input ~= "" then
                vim.cmd("vimgrep " .. input .. " **/*")
                vim.cmd("copen")
              end
            end)
          elseif finder == "buffers" then
            vim.cmd("ls")
          else
            vim.cmd("find")
          end
        end
      end
    end
  end, {
    nargs = "*",
    complete = function(_, _, _)
      return { "telescope", "snacks", "files", "grep", "buffers", "help" }
    end,
    desc = "Toggle finder (telescope or snacks)",
  })

  -- Layout presets with robust fallbacks
  vim.api.nvim_create_user_command("Layout", function(opts)
    local layout = opts.args

    -- Helper to open file explorer
    local function open_explorer()
      local oil = safe_require("oil")
      if oil then
        oil.open()
      else
        vim.cmd("Explore")
      end
    end

    -- Helper to open terminal via toggleterm
    local function open_terminal(size)
      local toggleterm = safe_require("toggleterm")
      if toggleterm and toggleterm.toggle then
        toggleterm.toggle(1, size or 15, nil, "horizontal")
      else
        vim.cmd("terminal")
      end
    end

    -- Apply the selected layout
    if layout == "coding" then
      open_explorer()
      vim.api.nvim_command("wincmd l")
    elseif layout == "terminal" then
      open_explorer()
      vim.api.nvim_command("wincmd l")
      open_terminal()
    elseif layout == "writing" then
      vim.api.nvim_command("only")
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
      -- Center buffer if available
      if _G.Util and _G.Util.center_buffer then
        _G.Util.center_buffer()
      end
    elseif layout == "debug" then
      vim.api.nvim_command("only")
      local dapui = safe_require("dapui")
      if dapui and dapui.open then
        dapui.open()
      else
        vim.notify("DAP UI is not loaded", vim.log.levels.WARN)
      end
    else
      vim.notify("Available layouts: coding, terminal, writing, debug", vim.log.levels.INFO)
    end
  end, {
    nargs = "?",
    complete = function()
      return { "coding", "terminal", "writing", "debug" }
    end,
    desc = "Switch workspace layout",
  })

  -- Lazygit toggle with fallback
  vim.api.nvim_create_user_command("LazyGit", function()
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
      -- Fallback to system command
      vim.cmd("!lazygit")
    end
  end, { desc = "Open Lazygit" })

  -- Command to check plugin status
  vim.api.nvim_create_user_command("PluginCheck", function()
    local plugins = require("lazy.core.config").plugins
    local errors = {}
    local warnings = {}

    for name, plugin in pairs(plugins) do
      if plugin._.error then
        table.insert(errors, { name = name, error = plugin._.error })
      end

      -- Check for dependency issues
      if plugin._.dep_errors and #plugin._.dep_errors > 0 then
        for _, dep_error in ipairs(plugin._.dep_errors) do
          table.insert(warnings, { name = name, warning = "Dependency issue: " .. dep_error })
        end
      end
    end

    if #errors == 0 and #warnings == 0 then
      vim.notify("No plugin issues detected!", vim.log.levels.INFO, { title = "Plugin Check" })
    else
      if #errors > 0 then
        vim.notify("Found errors in " .. #errors .. " plugins", vim.log.levels.ERROR, { title = "Plugin Check" })
        for _, err in ipairs(errors) do
          vim.notify(err.name .. ": " .. err.error, vim.log.levels.ERROR)
        end
      end

      if #warnings > 0 then
        vim.notify("Found warnings in " .. #warnings .. " plugins", vim.log.levels.WARN, { title = "Plugin Check" })
        for _, warning in ipairs(warnings) do
          vim.notify(warning.name .. ": " .. warning.warning, vim.log.levels.WARN)
        end
      end
    end
  end, { desc = "Check for plugin errors and warnings" })

  -- ReloadConfig: clear loaded config/plugins and re-source init.lua
  vim.api.nvim_create_user_command("ReloadConfig", function()
    for name, _ in pairs(package.loaded) do
      if name:match("^(config)%.") or name:match("^(plugins)%.") then
        package.loaded[name] = nil
      end
    end
    dofile(vim.fn.stdpath("config") .. "/init.lua")
    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO, { title = "Config" })
  end, { desc = "Reload Neovim configuration" })

  -- Toggle diagnostic display
  vim.api.nvim_create_user_command("DiagnosticsToggle", function()
    local current_config = vim.diagnostic.config()
    local new_config = {
      virtual_text = not current_config.virtual_text,
      signs = not current_config.signs,
      underline = not current_config.underline,
    }
    vim.diagnostic.config(new_config)

    local status = new_config.virtual_text and "enabled" or "disabled"
    vim.notify("Diagnostics " .. status, vim.log.levels.INFO)
  end, { desc = "Toggle diagnostic display" })
end

return M
