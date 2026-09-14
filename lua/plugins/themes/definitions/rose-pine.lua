local live = require("lib.live_theme")

return live.definition({
  plugin = "rose-pine",
  variants = { "main", "moon", "dawn" },
  default = "main",
  background = function(variant)
    return variant == "dawn" and "light" or "dark"
  end,
  apply = function(variant, opts)
    require("rose-pine").setup({
      variant = variant,
      disable_background = opts.transparency,
    })
    vim.cmd.colorscheme("rose-pine")
  end,
})
