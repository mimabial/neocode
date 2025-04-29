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
require("config.diagnostics").setup()
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
    local v = vim.version()
    vim.notify(
      string.format(
        "Neovim v%d.%d.%d loaded %d/%d plugins in %sms",
        v.major, v.minor, v.patch,
        stats.loaded, stats.count, ms
      ),
      vim.log.levels.INFO, { title = "Neovim Loaded" }
    )
  end,
})

-- ReloadConfig command
vim.api.nvim_create_user_command("ReloadConfig", function()
  for name,_ in pairs(package.loaded) do
    if name:match("^config") or name:match("^plugins") then
      package.loaded[name] = nil
    end
  end
  dofile(vim.fn.stdpath("config") .. "/init.lua")
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO, { title = "Config" })
end, { desc = "Reload Neovim configuration" })

-- ExplorerToggle command
vim.api.nvim_create_user_command("ExplorerToggle", function(opts)
  local ex = opts.args
  if ex == "snacks" then
    vim.g.default_explorer = "snacks"
    -- open snacks explorer
    require("snacks.explorer").open()
    vim.notify("Default explorer set to: Snacks", vim.log.levels.INFO)
  else
    -- default to oil
    vim.g.default_explorer = "oil"
    if package.loaded["oil"] then
      require("oil").open()
    else
      require("lazy").load({ plugins = { "oil.nvim" } })
      vim.defer_fn(function()
        if package.loaded["oil"] then require("oil").open() end
      end, 100)
    end
    vim.notify("Default explorer set to: Oil", vim.log.levels.INFO)
  end
end, {
  nargs = "?",
  complete = function() return { "oil", "snacks" } end,
  desc = "Set and open default explorer (oil or snacks)",
})

-- Disable formatoptions that automatically continue comments
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- remove c, r and o flags in one call
    vim.opt_local.formatoptions:remove("cro")
  end,
  desc = "Disable auto comment continuation",
})

