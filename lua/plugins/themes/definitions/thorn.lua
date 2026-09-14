local live = require("lib.live_theme")

return live.definition({
  plugin = "thorn.nvim",
  variants = { "forest", "field" },
  default = "forest",
  background = function(variant)
    return variant == "field" and "light" or "dark"
  end,
  apply = function(variant, opts)
    require("thorn").setup({ theme = variant, transparent = opts.transparency })
    vim.cmd.colorscheme("thorn")
  end,
})
