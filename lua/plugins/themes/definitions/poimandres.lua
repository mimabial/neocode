local live = require("lib.live_theme")

return live.definition({
  plugin = "poimandres.nvim",
  background = "dark",
  apply = function(_, opts)
    require("poimandres").setup({
      disable_background = opts.transparency,
      disable_float_background = opts.transparency,
    })
    vim.cmd.colorscheme("poimandres")
  end,
})
