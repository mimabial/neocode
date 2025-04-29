-- Set leader key before anything else
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set oil as the default explorer early
vim.g.default_explorer = "oil"

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

-- Add command to toggle between explorers
vim.api.nvim_create_user_command("ExplorerToggle", function(args)
  local explorer_type = args.args
  if explorer_type == "oil" then
    vim.g.default_explorer = "oil"
    vim.cmd("Oil")
  elseif explorer_type == "neo-tree" or explorer_type == "neotree" then
    vim.g.default_explorer = "neo-tree"
    vim.cmd("Neotree toggle")
  else
    vim.cmd("Oil")
  end
  vim.notify("Default explorer set to: " .. vim.g.default_explorer, vim.log.levels.INFO)
end, { nargs = "?", complete = function() return {"oil", "neo-tree"} end, desc = "Set default explorer" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})
