-- Centralized commands with Telescope integration and improved error handling

local M = {}

local function open_explorer_beside_editor()
  vim.cmd("topleft vsplit")
  require("oil").open()
  vim.cmd("wincmd p")
end

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
      open_explorer_beside_editor()
    elseif layout == "terminal" then
      open_explorer_beside_editor()
      require("toggleterm").toggle(1, 15, nil, "horizontal")
    elseif layout == "writing" then
      vim.api.nvim_command("only")
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
    elseif layout == "debug" then
      require("lazy").load({ plugins = { "nvim-dap" } })
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

  -- Plugin Management
  vim.api.nvim_create_user_command("UpdateAll", function()
    vim.cmd("Lazy update")
    require("lib.mason_tools").update_installed()
  end, { desc = "Update all plugins and Mason packages" })

  vim.api.nvim_create_user_command("PluginCheck", function()
    local Plugin = require("lazy.core.plugin")
    local failed = {}
    for name, plugin in pairs(require("lazy.core.config").plugins) do
      if Plugin.has_errors(plugin) then
        table.insert(failed, name)
      end
    end

    if #failed == 0 then
      vim.notify("No plugin errors detected!", vim.log.levels.INFO, { title = "Plugin Check" })
    else
      vim.notify(
        ("Found errors in %d plugins:\n  %s\nRun :Lazy for details."):format(#failed, table.concat(failed, ", ")),
        vim.log.levels.ERROR,
        { title = "Plugin Check" }
      )
    end
  end, { desc = "Check for plugin errors" })
end

return M
