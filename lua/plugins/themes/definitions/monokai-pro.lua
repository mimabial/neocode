local live = require("lib.live_theme")

return live.definition({
  plugin = "monokai-pro.nvim",
  variants = { "pro", "classic", "machine", "octagon", "ristretto", "spectrum" },
  default = "ristretto",
  background = "dark",
  apply = function(variant, opts)
    require("monokai-pro").setup({
      filter = variant,
      transparent_background = opts.transparency,
    })
    vim.cmd.colorscheme("monokai-pro")
  end,
})
