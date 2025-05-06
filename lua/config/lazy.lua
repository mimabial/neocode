-- lua/config/lazy.lua – Lazy.nvim configuration with enhanced error handling and plugin management
local M = {}

-- 1) Helper for safe loads (avoid dependency on config.utils.safe_require)
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[Warning] Could not load '%s': %s", mod, m), vim.log.levels.WARN)
    return nil
  end
  return m
end

-- 2) Bootstrap Lazy.nvim if missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- use isdirectory to avoid undefined fs_stat
if vim.fn.isdirectory(lazypath) == 0 then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 3) Load Lazy
local lazy = safe_require("lazy")
if not lazy then
  return
end

function M.setup()
  -- 4) Plugin specification
  require("lazy").setup({
    spec = {
      { import = "plugins" },
    },
    defaults = { lazy = true, version = false },
    install = {
      colorscheme = { "gruvbox-material" },
      missing = true,
    },
    checker = { enabled = true, notify = false, frequency = 3600 },
    change_detection = { enabled = true, notify = false },
    performance = {
      rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
      cache = { enabled = true },
      reset_packpath = true,
      reset_rtp = false,
    },
    -- Enhanced debugging for troubleshooting
    debug = false,
  })
end

return M
