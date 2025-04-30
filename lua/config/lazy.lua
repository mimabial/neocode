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

-- Setup lazy.nvim with conditional imports and explicit priorities
require("lazy").setup({
  spec = {
    -- 1) import everything under lua/plugins/*.lua
    { import = "plugins" },

    -- 2) then list your high-priority overrides at the top level
    { "sainnhe/gruvbox-material", lazy = false, priority = 1000 },
    { "nvim-tree/nvim-web-devicons", lazy = false, priority = 950 },
    { "rcarriga/nvim-notify", lazy = false, priority = 940 },
    { "folke/tokyonight.nvim", lazy = true, priority = 900 },
    { "nvim-lua/plenary.nvim", lazy = false, priority = 900 },
    { "stevearc/oil.nvim", lazy = false, priority = 850 },
    { "folke/which-key.nvim", event = "VeryLazy", priority = 820 },
    { "folke/snacks.nvim", event = "VeryLazy", priority = 800 },
    { "neovim/nvim-lspconfig", priority = 700 },
    { "hrsh7th/nvim-cmp", priority = 600 },
    { "kevinhwang91/nvim-hlslens", priority = 60 },

    -- 3) conditional imports
    {
      import = "plugins.goth",
      cond = function()
        return vim.g.current_stack ~= "nextjs"
      end,
    },
    {
      import = "plugins.nextjs",
      cond = function()
        return vim.g.current_stack ~= "goth"
      end,
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
})

-- Set up custom commands
vim.api.nvim_create_user_command("LazyGit", function()
  -- Check if toggleterm is available
  if package.loaded["toggleterm"] then
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
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
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
  if package.loaded["mason"] then
    vim.cmd("MasonUpdate")
  end
  vim.notify("Updated plugins and Mason packages", vim.log.levels.INFO)
end, { desc = "Update all plugins and Mason packages" })

-- Command for switching between stacks with auto-detection
vim.api.nvim_create_user_command("StackFocus", function(opts)
  -- Call the stack module's configure function
  require("config.stack").configure_stack(opts.args)
end, {
  nargs = "?",
  desc = "Focus on a specific tech stack",
  complete = function()
    return { "goth", "nextjs" }
  end,
})

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
    if package.loaded["oil"] then
      require("oil").open()
    else
      vim.cmd("Lazy load oil.nvim")
      vim.defer_fn(function()
        if package.loaded["oil"] then
          require("oil").open()
        end
      end, 100)
    end
    vim.cmd("wincmd l") -- Move to the right window (main buffer)
  elseif layout == "terminal" then
    if package.loaded["oil"] then
      require("oil").open()
    else
      vim.cmd("Lazy load oil.nvim")
    end
    vim.cmd("wincmd l") -- Ensure we're in the main window
    if package.loaded["toggleterm"] then
      require("toggleterm").toggle(1, 15, nil, "horizontal")
    else
      vim.cmd("Lazy load toggleterm.nvim")
      vim.defer_fn(function()
        if package.loaded["toggleterm"] then
          require("toggleterm").toggle(1, 15, nil, "horizontal")
        end
      end, 100)
    end
  elseif layout == "writing" then
    vim.cmd("only") -- Close all other windows
    vim.cmd("set wrap linebreak")
    if _G.Util and _G.Util.center_buffer then
      _G.Util.center_buffer()
    end
  elseif layout == "debug" then
    vim.cmd("only") -- Close all other windows
    if package.loaded["dapui"] then
      require("dapui").open()
    else
      vim.cmd("Lazy load nvim-dap-ui")
      vim.defer_fn(function()
        if package.loaded["dapui"] then
          require("dapui").open()
        else
          vim.notify("DAP UI is not loaded", vim.log.levels.WARN)
        end
      end, 100)
    end
  else
    vim.notify("Available layouts: coding, terminal, writing, debug", vim.log.levels.INFO)
  end
end, {
  nargs = "?",
  desc = "Switch workspace layout",
  complete = function()
    return { "coding", "terminal", "writing", "debug" }
  end,
})

-- Create ColorSchemeToggle command
vim.api.nvim_create_user_command("ColorSchemeToggle", function()
  local current = vim.g.colors_name
  if current == "gruvbox-material" then
    vim.cmd("colorscheme tokyonight")
    vim.notify("Switched to TokyoNight theme", vim.log.levels.INFO)
  else
    vim.cmd("colorscheme gruvbox-material")
    vim.notify("Switched to Gruvbox Material theme", vim.log.levels.INFO)
  end
end, { desc = "Toggle between color schemes" })
