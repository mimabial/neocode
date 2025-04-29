-- Set leader key before anything else
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set snacks as the default explorer and picker early
vim.g.default_explorer = "oil"
vim.g.default_picker = "snacks"

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
  else
    -- Default to snacks
    vim.g.default_explorer = "snacks"
    require("snacks.explorer").toggle()
  end
  vim.notify("Default explorer set to: " .. vim.g.default_explorer, vim.log.levels.INFO)
end, { nargs = "?", complete = function() return {"oil", "snacks"} end, desc = "Set default explorer" })

-- Add command to toggle between pickers
vim.api.nvim_create_user_command("PickerToggle", function(args)
  local picker_type = args.args
  -- Default to snacks
  vim.g.default_picker = "snacks"
  vim.notify("Default picker set to: " .. vim.g.default_picker, vim.log.levels.INFO)
end, { nargs = "?", complete = function() return {"snacks"} end, desc = "Set default picker" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove("cro") 
  end,
})
