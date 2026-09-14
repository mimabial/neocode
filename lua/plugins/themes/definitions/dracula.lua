local live = require("lib.live_theme")

return live.definition({
  plugin = "dracula.nvim",
  variants = { "default", "soft" },
  default = "default",
  background = "dark",
  apply = function(variant, opts)
    require("dracula").setup({ transparent_bg = opts.transparency })
    vim.cmd.colorscheme(variant == "soft" and "dracula-soft" or "dracula")
  end,
})
