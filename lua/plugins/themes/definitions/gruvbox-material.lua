local live = require("lib.live_theme")

return live.definition({
  plugin = "gruvbox-material",
  variants = { "hard", "medium", "soft" },
  default = "medium",
  background = function(_, opts)
    return opts.background or vim.o.background
  end,
  apply = function(variant, opts)
    vim.g.gruvbox_material_background = variant
    vim.g.gruvbox_material_transparent_background = opts.transparency and 2 or 0
    vim.cmd.colorscheme("gruvbox-material")
  end,
})
