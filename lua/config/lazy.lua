local M = {}

function M.setup()
  local lazy = require("lazy") ---@type Lazy
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
      colorscheme = { "catppuccin-mocha" },
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
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazySync",
      once = true,
      callback = function()
        vim.notify("Plugins synchronized; restart Neovim to run updated plugin code", vim.log.levels.INFO)
      end,
    })
    lazy.sync()
  end, { desc = "Synchronize plugins" })
end

return M
