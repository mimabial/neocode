-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Import utility functions
_G.Util = require("config.utils")

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- Import all plugins from lua/plugins directory
    { import = "plugins" },
    -- Uncomment these if you want to load specific plugin groups
    -- { import = "plugins.extras.lang.typescript" },
    -- { import = "plugins.extras.lang.json" },
    -- { import = "plugins.extras.lang.python" },
    -- { import = "plugins.extras.lang.rust" },
    -- { import = "plugins.extras.lang.go" },
    -- { import = "plugins.extras.ui.mini-starter" },
    -- { import = "plugins.extras.coding.copilot" },
  },
  defaults = {
    lazy = false, -- Load plugins eagerly instead of lazy-loading by default
    version = false, -- Always use the latest git commit
  },
  install = {
    colorscheme = { "gruvbox-material" }, -- Try to load this colorscheme first
    missing = true, -- Install missing plugins on startup
  },
  ui = {
    border = "rounded", -- Use rounded borders in the lazy UI
    size = {
      width = 0.8,
      height = 0.8,
    },
    icons = {
      loaded = "●",
      not_loaded = "○",
      cmd = " ",
      config = " ",
      event = " ",
      ft = " ",
      init = " ",
      keys = " ",
      plugin = " ",
      runtime = " ",
      require = " ",
      source = " ",
      start = " ",
      task = " ",
      lazy = "󰒲 ",
    },
  },
  checker = {
    enabled = true, -- Check for updates automatically
    notify = false, -- Don't notify about updates
    frequency = 3600, -- Check once every hour
  },
  change_detection = {
    enabled = true, -- Auto reload config when plugins change
    notify = false, -- Don't notify about config changes
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
    cache = {
      enabled = true,
    },
    reset_packpath = true, -- Reset packpath
    reset_rtp = false, -- Don't reset rtp
  },
  dev = {
    -- Directory where you store your local plugin projects
    path = "~/projects/nvim-plugins",
    -- Patterns to detect plugin directories
    patterns = {}, -- For example {"folke"}
    -- Create symlink instead of cloning the plugin
    fallback = false,
  },
  debug = false,
})

-- Auto-load additional utilities for specific file types
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    -- Add vim.inspect pretty printer to Lua files
    _G.P = function(v)
      print(vim.inspect(v))
      return v
    end
  end,
})

-- Set up custom commands
vim.api.nvim_create_user_command("LazyGit", function()
  -- Check if toggleterm is available
  if _G.utils.has_plugin("toggleterm.nvim") then
    if _G.toggle_lazygit then
      _G.toggle_lazygit()
    else
      vim.notify("Lazygit is not properly configured.", vim.log.levels.WARN)
    end
  else
    -- Fallback to system command if toggleterm is not available
    vim.cmd([[!lazygit]])
  end
end, { desc = "Open Lazygit" })

-- Create a command to update plugins and Mason packages
vim.api.nvim_create_user_command("UpdateAll", function()
  -- Update plugins
  vim.cmd("Lazy update")
  
  -- Check if Mason is available
  if _G.utils.has_plugin("mason.nvim") then
    vim.cmd("MasonUpdate")
  end
  
  vim.notify("Updated plugins and Mason packages", vim.log.levels.INFO)
end, { desc = "Update all plugins and Mason packages" })

-- Create a command to profile startup time
vim.api.nvim_create_user_command("Profile", function()
  -- Check existing profile data
  local has_plenary, plenary_profile = pcall(require, "plenary.profile")
  if not has_plenary then
    vim.notify("Plenary is required for profiling", vim.log.levels.ERROR)
    return
  end
  
  plenary_profile.start("profile.log")
  vim.notify("Profiling started, restart Neovim to generate profile.log", vim.log.levels.INFO)
end, { desc = "Start profiling Neovim" })
