local live = require("lib.live_theme")

return live.definition({
  plugin = "decay.nvim",
  variants = { "default", "dark", "decayce" },
  default = "default",
  background = function(_, opts)
    return opts.background or "dark"
  end,
  apply = function(variant, opts)
    require("decay").setup({ style = variant, transparent = opts.transparency })
    local colorscheme = variant == "decayce" and "decayce" or ("decay-" .. variant)
    vim.cmd.colorscheme(colorscheme)
    vim.g.colors_name = colorscheme
  end,
})
