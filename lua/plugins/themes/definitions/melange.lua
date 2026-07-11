-- Melange Theme Definition
-- Variants are backgrounds: melange picks dark/light via vim.o.background.
return {
  icon = "",
  variants = { "dark", "light" },
  setup = function(opts)
    local bg = opts.background or opts.variant
    if bg ~= "dark" and bg ~= "light" then
      bg = "dark"
    end
    vim.o.background = bg
    vim.cmd("colorscheme melange")
  end,
}
