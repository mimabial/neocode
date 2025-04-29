-- Set leader key before anything else
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set Oil as the default explorer and snacks as the default picker
vim.g.default_explorer = "oil"
vim.g.default_picker = "snacks"

-- Disable some unused plugins early
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Load configurations
require("config.options")      -- Load options
require("config.autocmds")     -- Load autocommands
require("config.stack").setup() -- Set up stack detection before plugins
require("config.lazy")         -- Load lazy.nvim configuration
require("config.keymaps")      -- Load keymaps

-- Print a startup message
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    local stats = require("lazy").stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    local version = vim.version()
    local nvim_version_info = "v" .. version.major .. "." .. version.minor .. "." .. version.patch
    
    vim.notify(string.format(
      "Neovim %s loaded %s/%s plugins in %sms",
      nvim_version_info, stats.loaded, stats.count, ms
    ), vim.log.levels.INFO, { title = "Neovim Loaded" })
  end,
})

-- Add custom commands
vim.api.nvim_create_user_command("ReloadConfig", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^config") or name:match("^plugins") then
      package.loaded[name] = nil
    end
  end
  dofile(vim.fn.stdpath("config") .. "/init.lua")
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO, { title = "Config" })
end, { desc = "Reload Neovim configuration" })

-- Add command to toggle between explorers (with explicit preference for Oil)
vim.api.nvim_create_user_command("ExplorerToggle", function(args)
  local explorer_type = args.args
  if explorer_type == "oil" or explorer_type == "" then
    vim.g.default_explorer = "oil"
    vim.cmd("Oil")
    vim.notify("Default explorer set to: Oil", vim.log.levels.INFO)
  elseif explorer_type == "snacks" then
    -- Oil is strongly preferred, but allow snacks if specifically requested
    vim.g.default_explorer = "snacks"
    if package.loaded["snacks.explorer"] then
      require("snacks.explorer").toggle()
      vim.notify("Default explorer set to: Snacks", vim.log.levels.INFO)
    else
      vim.notify("Snacks explorer not available, using Oil instead", vim.log.levels.WARN)
      vim.g.default_explorer = "oil"
      vim.cmd("Oil")
    end
  else
    -- When toggling, prefer Oil
    if vim.g.default_explorer ~= "oil" then
      vim.g.default_explorer = "oil"
      vim.cmd("Oil")
    elseif package.loaded["snacks.explorer"] then
      vim.g.default_explorer = "snacks"
      require("snacks.explorer").toggle()
    else
      vim.cmd("Oil")
    end
    vim.notify("Default explorer set to: " .. vim.g.default_explorer, vim.log.levels.INFO)
  end
end, { nargs = "?", complete = function() return {"oil", "snacks"} end, desc = "Set default explorer" })

-- Disable formatoptions that automatically continue comments
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})
