return {
  icon = "",
  variants = { "forest", "field" },
  setup = function(opts)
    local variant = opts.variant
      or ((opts.background or vim.o.background or "dark") == "light" and "field" or "forest")
    require("thorn").setup({
      theme = variant,
      transparent = opts.transparency,
    })
    vim.cmd("colorscheme thorn")
  end,
}
