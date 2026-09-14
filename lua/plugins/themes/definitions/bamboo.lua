local live = require("lib.live_theme")

return live.definition({
  plugin = "bamboo.nvim",
  variants = { "vulgaris", "multiplex", "light" },
  default = "vulgaris",
  background = function(variant)
    return variant == "light" and "light" or "dark"
  end,
  apply = function(variant, opts)
    require("bamboo").setup({ style = variant, transparent = opts.transparency })
    require("bamboo").load()
  end,
})
