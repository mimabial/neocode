local M = {}

function M.setup()
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then
    vim.notify("Failed to load lazy.nvim. Check installation.", vim.log.levels.ERROR)
    return
  end

  lazy.setup({
    spec = {
      { import = "plugins.ai" },
      { import = "plugins.coding" },
      { import = "plugins.debug" },
      { import = "plugins.editor" },
      { import = "plugins.git" },
      { import = "plugins.lang" },
      { import = "plugins.lsp" },
      { import = "plugins.search" },
      { import = "plugins.themes" },
      { import = "plugins.ui" },
    },
    defaults = {
      lazy = true,
      version = false,
    },
    install = {
      colorscheme = { "kanagawa" },
      missing = true,
    },
    pkg = { enabled = false },
    checker = {
      enabled = true,
      notify = false,
      frequency = 3600,
    },
    change_detection = {
      enabled = true,
      notify = false,
    },
    ui = {
      border = "single",
      size = { width = 0.8, height = 0.8 },
      icons = require("lib.icons").lazy,
    },
    performance = {
      rtp = {
        disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
      },
      cache = { enabled = true },
      reset_packpath = true,
      reset_rtp = false,
    },
    debug = false,
  })

  vim.api.nvim_create_user_command("PluginSync", function()
    for name, _ in pairs(package.loaded) do
      if name:match("^plugins%.") then
        package.loaded[name] = nil
      end
    end
    vim.cmd("Lazy sync")
    vim.notify("Plugins synchronized", vim.log.levels.INFO)
  end, { desc = "Synchronize plugins and reload configurations" })
end

return M
