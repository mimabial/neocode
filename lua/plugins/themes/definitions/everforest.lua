local live = require("lib.live_theme")

return live.definition({
  plugin = "everforest",
  variants = { "hard", "medium", "soft" },
  default = "hard",
  background = function(_, opts)
    return opts.background or vim.o.background
  end,
  apply = function(variant, opts)
    vim.g.everforest_background = variant
    vim.g.everforest_transparent_background = opts.transparency and 2 or 0
    vim.cmd.colorscheme("everforest")
  end,
})
