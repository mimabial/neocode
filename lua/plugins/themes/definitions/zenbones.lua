-- Zenbones Theme Definition
return {
  icon = "",
  variants = { "default", "stark", "warm", "bright", "dim" },
  setup = function(opts)
    local bg = opts.background == "light" and "light" or "dark"
    local variant = opts.variant

    vim.o.background = bg
    vim.g.zenbones_darkness = nil
    vim.g.zenbones_lightness = nil

    if variant == "default" or variant == "" then
      variant = nil
    end

    if bg == "dark" and (variant == "stark" or variant == "warm") then
      vim.g.zenbones_darkness = variant
    elseif bg == "light" and (variant == "bright" or variant == "dim") then
      vim.g.zenbones_lightness = variant
    end

    vim.g.zenbones_transparent_background = opts.transparency == true
    vim.cmd("colorscheme zenbones")
  end,
}
