-- lua/config/lazy.lua
-- Refactored Lazy.nvim configuration with custom commands for Git, updates, transparency, and theme toggling

-- Utility loader
local safe_require = function(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[Lazy] Could not load '%s': %s", mod, m), vim.log.levels.WARN)
    return nil
  end
  return m
end

-- Bootstrap lazy.nvim if missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

-- Load lazy
local lazy = safe_require("lazy")
if not lazy then
  return
end

-- Global flags
vim.g.use_snacks_ui = true

-- Import utilities
_G.Util = safe_require("config.utils") or {}

-- Plugin specification
lazy.setup({
  spec = {
    { import = "plugins" },
    { "sainnhe/gruvbox-material", lazy = false, priority = 1000 },
    { "nvim-tree/nvim-web-devicons", lazy = false, priority = 950 },
    { "rcarriga/nvim-notify", lazy = false, priority = 940 },
    { "stevearc/oil.nvim", lazy = false, priority = 850 },
    { "folke/which-key.nvim", event = "VeryLazy", priority = 820 },
    { "folke/snacks.nvim", event = "VeryLazy", priority = 800 },
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
  defaults = { lazy = true, version = false },
  install = { colorscheme = { "gruvbox-material", "tokyonight" }, missing = true },
  ui = {
    border = "rounded",
    size = { width = 0.8, height = 0.8 },
    icons = { loaded = "●", not_loaded = "○", lazy = "󰒲 " },
  },
  checker = { enabled = true, notify = false, frequency = 3600 },
  change_detection = { enabled = true, notify = false },
  performance = {
    rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
    cache = { enabled = true },
    reset_packpath = true,
    reset_rtp = false,
  },
})

-- Custom commands
local api = vim.api

-- Open Lazygit in toggleterm or fallback
api.nvim_create_user_command("LazyGit", function()
  local ok, term = pcall(require, "toggleterm.terminal")
  if ok then
    if _G.toggle_lazygit then
      _G.toggle_lazygit()
    else
      local Terminal = term.Terminal or error("Toggleterm missing Terminal class")
      _G.toggle_lazygit =
        Terminal:new({ cmd = "lazygit", direction = "float", float_opts = { border = "rounded" } }).toggle
      _G.toggle_lazygit()
    end
  else
    vim.cmd("!lazygit")
  end
end, { desc = "Open Lazygit" })

-- Update plugins and Mason packages
api.nvim_create_user_command("UpdateAll", function()
  vim.cmd("Lazy update")
  if package.loaded["mason"] then
    vim.cmd("MasonUpdate")
  end
  vim.notify("Updated plugins and Mason packages", vim.log.levels.INFO)
end, { desc = "Update all plugins and Mason packages" })

-- Toggle transparency for gruvbox-material
api.nvim_create_user_command("ToggleTransparency", function()
  local flag = vim.g.gruvbox_material_transparent_background == 1 and 0 or 1
  vim.g.gruvbox_material_transparent_background = flag
  vim.notify(flag == 1 and "Transparency enabled" or "Transparency disabled", vim.log.levels.INFO)
  if vim.g.colors_name then
    vim.cmd("colorscheme " .. vim.g.colors_name)
  end
end, { desc = "Toggle background transparency" })

-- Toggle between gruvbox-material and tokyonight
api.nvim_create_user_command("ColorSchemeToggle", function()
  local current = vim.g.colors_name
  if current == "gruvbox-material" then
    vim.cmd("colorscheme tokyonight")
    vim.notify("Switched to TokyoNight theme", vim.log.levels.INFO)
  else
    vim.cmd("colorscheme gruvbox-material")
    vim.notify("Switched to Gruvbox Material theme", vim.log.levels.INFO)
  end
end, { desc = "Toggle between color schemes" })

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
