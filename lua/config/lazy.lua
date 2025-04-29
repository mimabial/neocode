-- lua/config/lazy.lua
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

-- Use stack detection from config.stack module
local stack = require("config.stack")

-- Check project type if not already detected by stack.setup()
if vim.g.current_stack == nil then
  local project_type = stack.detect_stack()
  if project_type then
    vim.g.current_stack = project_type
    print("Detected project type: " .. project_type)
  end
end

-- Explicitly set Oil as default explorer
vim.g.default_explorer = "oil"

-- Setup lazy.nvim with conditional imports and explicit priorities
require("lazy").setup({
  spec = {
    -- Core UI plugins with explicit loading priorities
    { 
      { "nvim-tree/nvim-web-devicons", priority = 1000 },
      { "sainnhe/gruvbox-material", priority = 950 },
      { "folke/tokyonight.nvim", priority = 940 },
      -- Make Oil load before other explorers/pickers
      { "stevearc/oil.nvim", priority = 900 },
      -- Keep snacks.nvim for picker functionality only
      { "folke/snacks.nvim", priority = 800 },
      { "folke/which-key.nvim", priority = 700 },
      import = "plugins.ui" 
    },
    
    -- Explicitly disable Neo-tree plugin
    {
      "nvim-neo-tree/neo-tree.nvim",
      enabled = false,
    },
    
    -- Explicitly disable telescope.nvim
    {
      "nvim-telescope/telescope.nvim",
      enabled = false,
    },
    
    -- Import all other plugins from lua/plugins directory
    { import = "plugins" },
    
    -- Stack-specific configurations - conditional imports based on detected project type
    { 
      import = "plugins.goth",
      cond = function()
        return vim.g.current_stack == "goth" or vim.g.current_stack == nil
      end
    },
    { 
      import = "plugins.nextjs",
      cond = function()
        return vim.g.current_stack == "nextjs" or vim.g.current_stack == nil
      end
    },
  },
  defaults = {
    lazy = true, -- Lazy-load plugins by default for better startup time
    version = false, -- Always use the latest git commit
  },
  install = {
    colorscheme = { "gruvbox-material", "tokyonight" },
    missing = true,
  },
  ui = {
    border = "rounded",
    size = { width = 0.8, height = 0.8 },
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
    enabled = true,
    notify = false,
    frequency = 3600,
  },
  change_detection = {
    enabled = true,
    notify = false,
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
    cache = { enabled = true },
    reset_packpath = true,
    reset_rtp = false,
  },
  dev = {
    path = "~/projects/nvim-plugins",
    patterns = {},
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
  if _G.utils and _G.utils.has_plugin("toggleterm.nvim") then
    if _G.toggle_lazygit then
      _G.toggle_lazygit()
    else
      -- Create lazygit terminal if doesn't exist
      local Terminal = require("toggleterm.terminal").Terminal
      _G.toggle_lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = { border = "rounded" },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
        end,
      }).toggle
      _G.toggle_lazygit()
    end
  else
    -- Fallback to system command if toggleterm is not available
    vim.cmd([[!lazygit]])
  end
end, { desc = "Open Lazygit" })

-- Create a command to update plugins and Mason packages
vim.api.nvim_create_user_command("UpdateAll", function()
  vim.cmd("Lazy update")
  if _G.utils and _G.utils.has_plugin("mason.nvim") then
    vim.cmd("MasonUpdate")
  end
  vim.notify("Updated plugins and Mason packages", vim.log.levels.INFO)
end, { desc = "Update all plugins and Mason packages" })

-- Create a command to profile startup time
vim.api.nvim_create_user_command("Profile", function()
  local has_plenary, plenary_profile = pcall(require, "plenary.profile")
  if not has_plenary then
    vim.notify("Plenary is required for profiling", vim.log.levels.ERROR)
    return
  end
  
  plenary_profile.start("profile.log")
  vim.notify("Profiling started, restart Neovim to generate profile.log", vim.log.levels.INFO)
end, { desc = "Start profiling Neovim" })

-- Command for switching between stacks with auto-detection
vim.api.nvim_create_user_command("StackFocus", function(opts)
  -- Delegate to the stack.lua implementation
  stack.configure_stack(opts.args)
end, { nargs = "?", desc = "Focus on a specific tech stack", complete = function()
  return { "goth", "nextjs" }
end})

-- Command to toggle transparency
vim.api.nvim_create_user_command("ToggleTransparency", function()
  if vim.g.gruvbox_material_transparent_background == 1 then
    vim.g.gruvbox_material_transparent_background = 0
    vim.notify("Transparency disabled", vim.log.levels.INFO)
  else
    vim.g.gruvbox_material_transparent_background = 1
    vim.notify("Transparency enabled", vim.log.levels.INFO)
  end
  
  -- Re-apply colorscheme
  vim.cmd("colorscheme " .. vim.g.colors_name)
end, { desc = "Toggle background transparency" })

-- Command to quickly switch between common layouts
vim.api.nvim_create_user_command("Layout", function(opts)
  local layout = opts.args
  
  if layout == "coding" then
    -- Use Oil instead of snacks explorer
    vim.cmd("Oil")
    vim.cmd("wincmd l") -- Move to the right window (main buffer)
  elseif layout == "terminal" then
    vim.cmd("Oil")
    vim.cmd("wincmd l") -- Ensure we're in the main window
    vim.cmd("ToggleTerm direction=horizontal")
  elseif layout == "writing" then
    vim.cmd("only") -- Close all other windows
    vim.cmd("set wrap linebreak")
    if _G.utils and _G.utils.center_buffer then
      _G.utils.center_buffer()
    end
  elseif layout == "debug" then
    vim.cmd("only") -- Close all other windows
    if package.loaded["dapui"] then
      require("dapui").open()
    else
      vim.notify("DAP UI is not loaded", vim.log.levels.WARN)
    end
  else
    vim.notify("Available layouts: coding, terminal, writing, debug", vim.log.levels.INFO)
  end
end, { nargs = "?", desc = "Switch workspace layout", complete = function()
  return { "coding", "terminal", "writing", "debug" }
end})

-- Set explorer toggle command to default to Oil
vim.api.nvim_create_user_command("ExplorerToggle", function(args)
  local explorer_type = args.args
  if explorer_type == "oil" or explorer_type == "" then
    vim.g.default_explorer = "oil"
    vim.cmd("Oil")
    vim.notify("Default explorer set to: Oil", vim.log.levels.INFO)
  elseif explorer_type == "snacks" then
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
    -- Toggle between explorers (though we prefer Oil)
    if vim.g.default_explorer == "oil" then
      if package.loaded["snacks.explorer"] then
        vim.g.default_explorer = "snacks"
        require("snacks.explorer").toggle()
      else
        vim.cmd("Oil")
      end
    else
      vim.g.default_explorer = "oil"
      vim.cmd("Oil")
    end
    vim.notify("Default explorer set to: " .. vim.g.default_explorer, vim.log.levels.INFO)
  end
end, { nargs = "?", complete = function() return {"oil", "snacks"} end, desc = "Set default explorer" })
