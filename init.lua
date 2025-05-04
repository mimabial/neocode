-- init.lua – Neovim entrypoint with robust module loading, error handling, and stack detection

-- 0) Leader & feature flags
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.default_explorer = "oil"
vim.g.default_picker = "snacks"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Version check
if vim.fn.has("nvim-0.8") == 0 then
  vim.notify("⚠️ Neovim 0.8 or higher is required for this configuration.", vim.log.levels.ERROR)
  return
end

-- Helper for safe module loading with error handling
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("⚠️ Could not load '%s': %s", mod, m), vim.log.levels.WARN)
    return nil
  end
  return m
end

-- Load core settings with error handling
local function load_module(name, setup_fn)
  local mod = safe_require(name)
  if mod then
    -- Check if mod is a table and has the specified function
    if type(mod) == "table" and type(mod[setup_fn]) == "function" then
      local ok, err = pcall(mod[setup_fn])
      if not ok then
        vim.notify(string.format("❌ Failed to run %s.%s: %s", name, setup_fn, err), vim.log.levels.ERROR)
      end
      return mod
    elseif type(mod) ~= "table" then
      vim.notify(string.format("⚠️ Module '%s' is not a table (got %s)", name, type(mod)), vim.log.levels.WARN)
    elseif type(mod[setup_fn]) ~= "function" then
      vim.notify(string.format("⚠️ Function '%s.%s' not found", name, setup_fn), vim.log.levels.WARN)
    end
  end
  return nil
end

-- Apply core options
load_module("config.options", "setup")

-- Initialize plugin manager (Lazy.nvim)
-- Bootstrap Lazy.nvim if missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.fn.isdirectory(lazypath) == 0 then
  vim.notify("📦 Installing lazy.nvim...", vim.log.levels.INFO)
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  vim.notify("✅ lazy.nvim installed successfully", vim.log.levels.INFO)
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins through config.lazy
require("config.lazy")

-- Load ui configuration
load_module("config.ui", "setup")

-- Detect and configure tech stack (Must run before any other modules that depend on stack)
load_module("config.stacks", "setup")

-- Load stack-specific commands
load_module("config.stack_commands", "setup")

-- Load key mappings
load_module("config.keymaps", "setup")

-- Load autocommands
load_module("config.autocmds", "setup")

-- Load custom commands
load_module("config.commands", "setup")

-- Load diagnostics
load_module("config.diagnostics", "setup")

-- Load LSP configuration
load_module("config.lsp", "setup")

-- Set default colorscheme if not already set
if not vim.g.colors_name then
  pcall(vim.api.nvim_command, "colorscheme gruvbox-material")
end

-- Print startup success message
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    local lazy_stats = require("lazy").stats()
    local ms = math.floor(lazy_stats.startuptime * 100 + 0.5) / 100
    local v = vim.version()

    local stack_icon = ""
    if vim.g.current_stack == "goth" then
      stack_icon = "󰟓 "
    elseif vim.g.current_stack == "nextjs" then
      stack_icon = " "
    elseif vim.g.current_stack == "goth+nextjs" then
      stack_icon = "󰡄 "
    end

    local msg = string.format(
      "⚡ Neovim v%d.%d.%d loaded %d/%d plugins in %.2fms %s",
      v.major,
      v.minor,
      v.patch,
      lazy_stats.loaded,
      lazy_stats.count,
      ms,
      stack_icon
    )
    vim.notify(msg, vim.log.levels.INFO, { title = "Neovim Started" })

    -- Open dashboard if enabled
    if package.loaded["snacks.dashboard"] and vim.fn.argc() == 0 then
      vim.cmd("Dashboard")
    end
  end,
})

-- Try to load project-specific configuration if it exists
local project_init = vim.fn.getcwd() .. "/.nvim/init.lua"
if vim.fn.filereadable(project_init) == 1 then
  vim.notify("📝 Loading project-specific configuration", vim.log.levels.INFO)
  local ok, err = pcall(dofile, project_init)
  if not ok then
    vim.notify("❌ Error in project config: " .. err, vim.log.levels.ERROR)
  end
end
