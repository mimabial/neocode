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
    -- Stack-specific configurations
    { import = "plugins.goth" },    -- Go + Templ + HTMX stack
    { import = "plugins.nextjs" },  -- Next.js stack
  },
  defaults = {
    lazy = false, -- Load plugins eagerly instead of lazy-loading by default
    version = false, -- Always use the latest git commit
  },
  install = {
    colorscheme = { "gruvbox-material", "tokyonight" }, -- Try to load these colorschemes in order
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
      -- Create lazygit terminal if doesn't exist
      local Terminal = require("toggleterm.terminal").Terminal
      _G.toggle_lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = {
          border = "rounded",
        },
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

-- Create a command for switching between stacks
vim.api.nvim_create_user_command("StackFocus", function(opts)
  local stack = opts.args
  if stack == "" or not (stack == "goth" or stack == "nextjs") then
    vim.notify("Please specify a valid stack: 'goth' or 'nextjs'", vim.log.levels.ERROR)
    return
  end
  
  -- Store the current stack preference
  vim.g.current_stack = stack
  
  -- Configure specific settings for the selected stack
  if stack == "goth" then
    -- Go + Templ + HTMX stack settings
    vim.notify("Focused on GOTH stack (Go + Templ + HTMX)", vim.log.levels.INFO)
    
    -- Set specific configuration for Go development
    vim.g.go_highlight_types = 1
    vim.g.go_highlight_fields = 1
    vim.g.go_highlight_functions = 1
    vim.g.go_highlight_function_calls = 1
    
    -- Configure linters and formatters
    if _G.utils.has_plugin("null-ls.nvim") then
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.goimports,
          null_ls.builtins.formatting.templ,
        }
      })
    end
    
  elseif stack == "nextjs" then
    -- Next.js stack settings
    vim.notify("Focused on Next.js stack", vim.log.levels.INFO)
    
    -- Set specific configuration for JavaScript/TypeScript development
    vim.g.typescript_indent_disable = 1
    
    -- Configure linters and formatters for JS/TS
    if _G.utils.has_plugin("null-ls.nvim") then
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.diagnostics.eslint,
        }
      })
    end
  end
  
  -- Reload relevant configurations
  vim.cmd("LspRestart")
  
end, { nargs = "?", desc = "Focus on a specific tech stack", complete = function()
  return { "goth", "nextjs" }
end})

-- Create a command to toggle transparency
vim.api.nvim_create_user_command("ToggleTransparency", function()
  -- For gruvbox-material
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

-- Add a keymap for transparency toggle
vim.keymap.set("n", "<leader>uT", "<cmd>ToggleTransparency<cr>", { desc = "Toggle Transparency" })

-- Create a command to quickly switch between common layouts
vim.api.nvim_create_user_command("Layout", function(opts)
  local layout = opts.args
  
  if layout == "coding" then
    -- Setup a coding layout with NeoTree and main buffer
    vim.cmd("Neotree show left")
    vim.cmd("wincmd l") -- Move to the right window (main buffer)
  elseif layout == "terminal" then
    -- Setup for terminal work with main editor and terminal
    vim.cmd("Neotree close")
    vim.cmd("ToggleTerm direction=horizontal")
  elseif layout == "writing" then
    -- Distraction-free writing layout
    vim.cmd("Neotree close")
    vim.cmd("set wrap linebreak")
    -- Center buffer content
    _G.utils.center_buffer()
  elseif layout == "debug" then
    -- Debug layout
    vim.cmd("Neotree close")
    require("dapui").open()
  else
    vim.notify("Available layouts: coding, terminal, writing, debug", vim.log.levels.INFO)
  end
end, { nargs = "?", desc = "Switch workspace layout", complete = function()
  return { "coding", "terminal", "writing", "debug" }
end})
