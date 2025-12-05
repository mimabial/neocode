-- Oxocarbon Theme Definition
return {
  icon = "",
  variants = { "dark", "light" },
  setup = function(variant, transparency)
    vim.opt.background = variant
    if transparency then
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    else
      vim.api.nvim_set_hl(0, "Normal", {})
      vim.api.nvim_set_hl(0, "NormalFloat", {})
      vim.api.nvim_set_hl(0, "NormalNC", {})
    end
    vim.cmd("colorscheme oxocarbon")
  end,
}
