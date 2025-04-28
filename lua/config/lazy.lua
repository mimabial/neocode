-- Enhanced lazy.nvim bootstrap with better error handling
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  
  vim.notify("Bootstrapping lazy.nvim...", vim.log.levels.INFO)
  
  -- Attempt to clone with detailed error reporting
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  }
  
  local out = vim.fn.system(clone_cmd)
  
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPlease check your internet connection and git installation.", "ErrorMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
  
  vim.notify("lazy.nvim installed successfully!", vim.log.levels.INFO)
end
vim.opt.rtp:prepend(lazypath)

-- Import utility functions
_G.Util = require("config.utils")

-- Setup lazy.nvim with enhanced configuration
require("lazy").setup({
  spec = {
    -- Import all plugins from lua/plugins directory
    { import = "plugins" },
    -- Stack-specific configurations
    { import = "plugins.goth" },    -- Go + Templ + HTMX stack
    { import = "plugins.nextjs" },  -- Next.js stack
  },
  defaults = {
    lazy = true, -- Default to lazy-loading
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
    wrap = true, -- Wrap line text
    throttle = 20, -- Throttle UI updates (ms)
  },
  checker = {
    enabled = true, -- Check for updates automatically
    notify = false, -- Don't notify about updates
    frequency = 3600, -- Check once every hour
    check_pinned = false, -- Don't check pinned plugins
  },
  change_detection = {
    enabled = true, -- Auto reload config when plugins change
    notify = false, -- Don't notify about config changes
  },
  performance = {
    cache = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/lazy/cache",
      disable_events = { "UIEnter", "BufReadPre" },
      ttl = 3600 * 24 * 7, -- 1 week cache
    },
    reset_packpath = true, -- Reset packpath
    rtp = {
      reset = true, -- Reset runtime path
      -- Disable unused built-in Vim plugins
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrwPlugin",
        "matchit",
        "matchparen", -- We'll use a tree-sitter based plugin for this
      },
    },
    -- Process startup chunk size (reduce for lower latency, higher for better throughput)
    fast_event_priority = 5, -- Higher priority for events
  },
  -- Define module loader options
  loader = {
    concurrency = 10, -- Load up to 10 modules in parallel
    reload = "immediate", -- Reload immediately when changes detected
  },
  -- For local plugin development
  dev = {
    -- Directory where you store your local plugin projects
    path = "~/projects/nvim-plugins",
    -- Patterns to detect plugin directories
    patterns = {}, 
    -- Fallback if pattern doesn't match
    fallback = false,
  },
  -- Debug mode
  debug = false,
  -- Profiling settings
  profiling = {
    -- Enable plugin load time profiling
    loader = false,
    -- Enable require() profiling
    require = false,
  },
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
    
    -- Add reload function to Lua files
    _G.RELOAD = function(module)
      package.loaded[module] = nil
      return require(module)
    end
  end,
})

-- Enhanced LazyGit command with better terminal handling
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
        float_opts = {
          border = "rounded",
          width = math.floor(vim.o.columns * 0.9),
          height = math.floor(vim.o.lines * 0.9),
        },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
        end,
        -- Add hook to refresh Git status when terminal exits
        on_exit = function()
          if package.loaded["gitsigns"] then
            require("gitsigns").refresh()
          end
        end,
      }).toggle
      _G.toggle_lazygit()
    end
  else
    -- Fallback to system command if toggleterm is not available
    vim.cmd([[!lazygit]])
  end
end, { desc = "Open Lazygit" })

-- Enhanced update command that handles both plugins and Mason packages
vim.api.nvim_create_user_command("UpdateAll", function()
  -- Create function to show progress
  local function show_progress(msg, level)
    level = level or vim.log.levels.INFO
    vim.notify(msg, level)
  end
  
  show_progress("Starting update of all plugins and packages...")
  
  -- First update plugins with Lazy
  show_progress("Updating plugins with lazy.nvim...")
  require("lazy").update({ show = false, wait = true })
  
  -- Then update Mason packages if available
  if _G.utils and _G.utils.has_plugin("mason.nvim") then
    show_progress("Updating Mason packages...")
    
    -- Try to get list of outdated packages
    local registry_avail, registry = pcall(require, "mason-registry")
    if registry_avail then
      registry.refresh()
      registry.update()
      
      -- Check for outdated packages
      local outdated_pkgs = {}
      for _, pkg in ipairs(registry.get_installed_packages()) do
        if pkg:is_installed() and pkg:has_new_version() then
          table.insert(outdated_pkgs, pkg.name)
          pkg:install()
        end
      end
      
      if #outdated_pkgs > 0 then
        show_progress("Updated Mason packages: " .. table.concat(outdated_pkgs, ", "))
      else
        show_progress("All Mason packages are up-to-date")
      end
    else
      -- Fallback to direct MasonUpdate command
      vim.cmd("MasonUpdate")
    end
  end
  
  show_progress("Update completed successfully!", vim.log.levels.INFO)
end, { desc = "Update all plugins and Mason packages" })

-- Enhanced profiling command with better output
vim.api.nvim_create_user_command("Profile", function()
  -- Check existing profile data
  local has_plenary, plenary_profile = pcall(require, "plenary.profile")
  if not has_plenary then
    vim.notify("Plenary is required for profiling", vim.log.levels.ERROR)
    return
  end
  
  -- Define output file location
  local profile_output = vim.fn.stdpath("cache") .. "/profile.log"
  
  -- Start profile
  plenary_profile.start(profile_output)
  
  -- Create autocmd to save profile on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      plenary_profile.stop()
      vim.notify("Profile data saved to " .. profile_output, vim.log.levels.INFO)
    end,
    once = true,
  })
  
  vim.notify("Profiling started. The results will be saved when Neovim exits.", vim.log.levels.INFO)
end, { desc = "Start profiling Neovim" })

-- Enhanced stack focus command with more intelligent handling
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
    
    -- Configure formatters for GOTH stack
    if package.loaded["conform"] then
      local conform = require("conform")
      conform.setup({
        formatters_by_ft = {
          go = { "gofumpt", "goimports" },
          templ = { "templ" },
        }
      })
    end
    
    -- Try to run LspGOTH if exists
    pcall(vim.cmd, "LspGOTH")
    
    -- Set filetype detection for .templ files if not already set
    vim.filetype.add({
      extension = {
        templ = "templ",
      },
    })
    
  elseif stack == "nextjs" then
    -- Next.js stack settings
    vim.notify("Focused on Next.js stack", vim.log.levels.INFO)
    
    -- Set specific configuration for JavaScript/TypeScript development
    vim.g.typescript_indent_disable = 1
    
    -- Configure formatters for Next.js stack
    if package.loaded["conform"] then
      local conform = require("conform")
      conform.setup({
        formatters_by_ft = {
          javascript = { { "prettierd", "prettier" } },
          typescript = { { "prettierd", "prettier" } },
          javascriptreact = { { "prettierd", "prettier" } },
          typescriptreact = { { "prettierd", "prettier" } },
          css = { { "prettierd", "prettier" } },
          json = { { "prettierd", "prettier" } },
          jsonc = { { "prettierd", "prettier" } },
          graphql = { { "prettierd", "prettier" } },
        }
      })
    end
    
    -- Try to run LspNextJS if exists
    pcall(vim.cmd, "LspNextJS")
    
    -- Set enhanced filetype detection for Next.js files
    vim.filetype.add({
      pattern = {
        ["app/.*/page%.[tj]sx"] = "nextjs_page",
        ["app/.*/layout%.[tj]sx"] = "nextjs_layout",
        ["app/api/.*/route%.[tj]s"] = "nextjs_api",
      },
    })
  end
  
  -- Refresh settings in open buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      -- Apply formatters and linters for the current filetype
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      if ft ~= "" then
        -- Trigger linting if available
        if package.loaded["lint"] then
          vim.defer_fn(function()
            require("lint").try_lint()
          end, 100)
        end
      end
    end
  end
  
  -- Reload LSP servers
  vim.cmd("LspRestart")
  
end, { nargs = "?", desc = "Focus on a specific tech stack", complete = function()
  return { "goth", "nextjs" }
end})

-- Enhanced transparency toggle command
vim.api.nvim_create_user_command("ToggleTransparency", function()
  local current_colorscheme = vim.g.colors_name or ""
  
  if current_colorscheme == "gruvbox-material" then
    -- For gruvbox-material
    if vim.g.gruvbox_material_transparent_background == 1 then
      vim.g.gruvbox_material_transparent_background = 0
      vim.notify("Transparency disabled for Gruvbox Material", vim.log.levels.INFO)
    else
      vim.g.gruvbox_material_transparent_background = 1
      vim.notify("Transparency enabled for Gruvbox Material", vim.log.levels.INFO)
    end
  elseif current_colorscheme == "tokyonight" then
    -- For tokyonight
    local has_tokyonight, tokyonight = pcall(require, "tokyonight")
    if has_tokyonight then
      local config = tokyonight.opts or {}
      config.transparent = not (config.transparent or false)
      tokyonight.setup(config)
      vim.notify("Transparency " .. (config.transparent and "enabled" or "disabled") .. " for TokyoNight", vim.log.levels.INFO)
    end
  else
    vim.notify("Transparency toggle not supported for " .. current_colorscheme, vim.log.levels.WARN)
    return
  end
  
  -- Re-apply colorscheme
  vim.cmd("colorscheme " .. current_colorscheme)
  
  -- Refresh statusline if lualine is present
  if package.loaded["lualine"] then
    require("lualine").refresh()
  end
end, { desc = "Toggle background transparency" })

-- Add a keymap for transparency toggle
vim.keymap.set("n", "<leader>uT", "<cmd>ToggleTransparency<cr>", { desc = "Toggle Transparency" })

-- Enhanced layout switching command
vim.api.nvim_create_user_command("Layout", function(opts)
  local layout = opts.args
  
  -- Save the window layout for reload
  local windows_before = vim.api.nvim_list_wins()
  
  if layout == "coding" then
    -- Setup a coding layout with NeoTree and main buffer
    if package.loaded["neo-tree"] then
      vim.cmd("Neotree show left")
      vim.cmd("wincmd l") -- Move to the right window (main buffer)
      
      -- Resize NeoTree to appropriate width
      vim.cmd("vertical resize 35")
    else
      vim.notify("NeoTree not available", vim.log.levels.WARN)
    end
  elseif layout == "terminal" then
    -- Setup for terminal work with main editor and terminal
    if package.loaded["neo-tree"] then
      vim.cmd("Neotree close")
    end
    
    if package.loaded["toggleterm"] then
      vim.cmd("ToggleTerm direction=horizontal")
      vim.cmd("resize 15") -- Set height of terminal
    else
      vim.notify("ToggleTerm not available", vim.log.levels.WARN)
    end
  elseif layout == "writing" then
    -- Distraction-free writing layout
    if package.loaded["neo-tree"] then
      vim.cmd("Neotree close")
    end
    
    -- Set appropriate options for writing
    vim.cmd("set wrap linebreak")
    
    -- Enable spell checking for writing
    vim.cmd("setlocal spell spelllang=en_us")
    
    -- Center the content and add some padding
    if _G.utils and _G.utils.center_buffer then
      _G.utils.center_buffer()
    else
      -- Fallback centering mechanism
      local win_width = vim.fn.winwidth(0)
      local margin = math.floor(win_width * 0.2)
      vim.wo.foldcolumn = tostring(margin)
      vim.wo.numberwidth = 1
      vim.wo.signcolumn = "no"
    end
  elseif layout == "debug" then
    -- Debug layout
    if package.loaded["neo-tree"] then
      vim.cmd("Neotree close")
    end
    
    -- Open DAP UI if available
    if package.loaded["dapui"] then
      require("dapui").open()
    else
      vim.notify("DAP UI not available", vim.log.levels.WARN)
    end
  else
    vim.notify("Available layouts: coding, terminal, writing, debug", vim.log.levels.INFO)
  end
  
  -- Evaluate current windows vs previous to see if anything changed
  local windows_after = vim.api.nvim_list_wins()
  if #windows_before == #windows_after and layout ~= "" then
    -- If no visible change, provide feedback
    vim.notify("Switched to " .. layout .. " layout", vim.log.levels.INFO)
  end
end, { nargs = "?", desc = "Switch workspace layout", complete = function()
  return { "coding", "terminal", "writing", "debug" }
end})

-- Define keymaps for layout switching
vim.keymap.set("n", "<leader>L1", "<cmd>Layout coding<cr>", { desc = "Coding Layout" })
vim.keymap.set("n", "<leader>L2", "<cmd>Layout terminal<cr>", { desc = "Terminal Layout" })
vim.keymap.set("n", "<leader>L3", "<cmd>Layout writing<cr>", { desc = "Writing Layout" })
vim.keymap.set("n", "<leader>L4", "<cmd>Layout debug<cr>", { desc = "Debug Layout" })

-- Add a quick command to reload configuration
vim.api.nvim_create_user_command("ReloadConfig", function()
  -- Clear all loaded modules that could be from our config
  for module_name, _ in pairs(package.loaded) do
    if module_name:match("^config%.") or module_name:match("^plugins%.") then
      package.loaded[module_name] = nil
    end
  end
  
  -- Reload init.lua
  dofile(vim.fn.stdpath("config") .. "/init.lua")
  
  -- Refresh colorscheme
  if vim.g.colors_name then
    vim.cmd("colorscheme " .. vim.g.colors_name)
  end
  
  -- Apply user commands that might have been reset
  vim.cmd([[
    silent! source ~/.config/nvim/after/plugin/user_commands.lua
  ]])
  
  vim.notify("Neovim configuration reloaded!", vim.log.levels.INFO)
end, { desc = "Reload Neovim configuration" })

-- Define global data for tracking startup time
if not _G.startup_begin then
  _G.startup_begin = vim.fn.reltime()
end

-- Create autocmd to show startup time
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    local stats = require("lazy").stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    local startup_time = vim.fn.reltimefloat(vim.fn.reltime(_G.startup_begin)) * 1000
    
    local version = vim.version()
    local nvim_version_info = "v" .. version.major .. "." .. version.minor .. "." .. version.patch
    local plugins_count = stats.count
    local plugins_loaded = stats.loaded
    
    -- Store for use in statusline
    vim.g.startup_time = ms
    vim.g.lazy_stats = {
      count = plugins_count,
      loaded = plugins_loaded,
      startuptime = ms,
    }
    
    -- Format a nice startup message
    local message = string.format(
      "Neovim %s loaded %s/%s plugins in %.2fms (lazy: %.2fms)",
      nvim_version_info, plugins_loaded, plugins_count, startup_time, ms
    )
    
    -- Show the startup info in a notification
    vim.notify(message, vim.log.levels.INFO, { title = "Neovim Loaded" })
  end,
})
