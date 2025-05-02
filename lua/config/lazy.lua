-- lua/config/lazy.lua – Lazy.nvim configuration and custom commands

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

-- 4) Global flags
vim.g.use_snacks_ui = true

-- 5) Plugin specification
lazy.setup({
  spec = {
    { import = "plugins" },
    { "sainnhe/gruvbox-material", lazy = false, priority = 1000 },
    { "nvim-tree/nvim-web-devicons", lazy = false, priority = 950 },
    { "rcarriga/nvim-notify", lazy = false, priority = 940 },
    { "stevearc/oil.nvim", lazy = false, priority = 850 },
    { "folke/which-key.nvim", event = "VeryLazy", priority = 820 },
    { "folke/snacks.nvim", event = "VeryLazy", priority = 800 },
    { import = "plugins.goth", cond = function()
        return vim.g.current_stack ~= "nextjs"
      end },
    { import = "plugins.nextjs", cond = function()
        return vim.g.current_stack ~= "goth"
      end },
  },
  defaults = { lazy = true, version = false },
  install = { colorscheme = { "gruvbox-material", "tokyonight" }, missing = true },
  ui = { border = "rounded", size = { width = 0.8, height = 0.8 }, icons = {
    loaded = "●",
    not_loaded = "○",
    lazy = "󰒲 "
  } },
  checker = { enabled = true, notify = false, frequency = 3600 },
  change_detection = { enabled = true, notify = false },
  performance = {
    rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
    cache = { enabled = true },
    reset_packpath = true,
    reset_rtp = false,
  },
})

-- 6) Custom user commands
local api = vim.api

-- Lazygit toggle
api.nvim_create_user_command("LazyGit", function()
  local ok, term = pcall(require, "toggleterm.terminal")
  if ok then
    if _G.toggle_lazygit then
      _G.toggle_lazygit()
    else
      local Terminal = term.Terminal or error("Toggleterm missing Terminal class")
      _G.toggle_lazygit = Terminal:new({ cmd = "lazygit", direction = "float", float_opts = { border = "rounded" } }).toggle
      _G.toggle_lazygit()
    end
  else
    vim.cmd("!lazygit")
  end
end, { desc = "Open Lazygit" })

-- Update all plugins and Mason packages
api.nvim_create_user_command("UpdateAll", function()
  vim.cmd("Lazy update")
  if package.loaded["mason"] then
    vim.cmd("MasonUpdate")
  end
  vim.notify("Updated plugins and Mason packages", vim.log.levels.INFO)
end, { desc = "Update all plugins and Mason packages" })

-- Toggle background transparency
api.nvim_create_user_command("ToggleTransparency", function()
  local flag = vim.g.gruvbox_material_transparent_background == 1 and 0 or 1
  vim.g.gruvbox_material_transparent_background = flag
  vim.notify(flag == 1 and "Transparency enabled" or "Transparency disabled", vim.log.levels.INFO)
  if vim.g.colors_name then
    vim.cmd("colorscheme " .. vim.g.colors_name)
  end
end, { desc = "Toggle background transparency" })

-- Color scheme toggle
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

-- Stack switching command
api.nvim_create_user_command("StackFocus", function(opts)
  require("config.stack").configure_stack(opts.args)
end, {
  nargs = "?",
  desc = "Focus on a specific tech stack",
  complete = function()
    return { "goth", "nextjs" }
  end,
})
