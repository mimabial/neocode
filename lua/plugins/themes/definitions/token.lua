local live = require("lib.live_theme")

return live.definition({
  plugin = "token",
  variants = { "ultra", "meridian", "classic", "flint", "temper" },
  default = "classic",
  background = function(_, opts)
    return opts.background
  end,
  apply = function(variant, opts)
    require("token").setup({
      transparent = opts.transparency,
      plugins = { all = true },
    })
    vim.cmd.colorscheme(variant == "classic" and "token" or "token-" .. variant)
  end,
})
