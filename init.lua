-- init.lua – Neovim entrypoint with robust module loading and error handling

-- 0) Leader & feature flags
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.default_explorer = "oil"
vim.g.default_picker = "snacks"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 1) Version check
if vim.fn.has("nvim-0.8") == 0 then
  vim.notify("Error: Neovim 0.8 or higher is required for this config.")
  return
end

-- 2) Helper for safe module loading with error handling
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[Warning] Could not load '%s': %s", mod, m), vim.log.levels.WARN)
    return nil
  end
  return m
end

-- 3) Load core settings with error handling
local function load_module(name, setup_fn)
  local mod = safe_require(name)
  if mod and type(mod[setup_fn]) == "function" then
    local ok, err = pcall(mod[setup_fn])
    if not ok then
      vim.notify(string.format("[Error] Failed to run %s.%s: %s", name, setup_fn, err), vim.log.levels.ERROR)
    end
    return mod
  end
  return nil
end

-- Apply core options
load_module("config.options", "setup")

-- 4) Initialize plugin manager (Lazy.nvim)
safe_require("config.lazy")
-- config.lazy handles bootstrap and setup

-- 5) Detect and configure tech stack
load_module("config.stacks", "setup")

-- 6) Load key mappings
load_module("config.keymaps", "setup")

-- 7) Load autocommands
load_module("config.autocmds", "setup")

-- 8) Load custom commands
load_module("config.commands", "setup")

-- 9) Load stack-specific commands
load_module("config.stack_commands", "setup")

-- 10) Load diagnostics
load_module("config.diagnostics", "setup")

-- 11) Load LSP configuration
load_module("config.lsp", "setup")

-- 12) Load utility modules
safe_require("utils.init")
safe_require("utils.format")
safe_require("utils.goth")
safe_require("utils.extras")

-- 13) Set default colorscheme if not already set
if not vim.g.colors_name then
  pcall(vim.cmd, "colorscheme gruvbox-material")
end

-- 14) Print startup success message
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    local lazy_stats = require("lazy").stats()
    local ms = math.floor(lazy_stats.startuptime * 100 + 0.5) / 100
    local v = vim.version()
    local msg = string.format(
      "⚡ Neovim v%d.%d.%d loaded %d/%d plugins in %.2fms",
      v.major,
      v.minor,
      v.patch,
      lazy_stats.loaded,
      lazy_stats.count,
      ms
    )
    vim.notify(msg, vim.log.levels.INFO, { title = "Neovim Started" })
  end,
})
