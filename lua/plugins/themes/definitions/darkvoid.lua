-- Darkvoid Theme Definition
return {
  icon = "",
  variants = { "glow" },
  setup = function(variant, transparency)
    require("darkvoid").setup({
      transparent = transparency,
      glow = (variant == "glow"),
      colors = {
        bg = "262626",
      },
      plugins = {
        gitsigns = true,
        nvim_cmp = true,
        treesitter = true,
        nvimtree = true,
        telescope = true,
        lualine = true,
        bufferline = true,
        oil = true,
        whichkey = true,
        nvim_notify = true,
      },
    })
    vim.cmd("colorscheme darkvoid")
  end,
}
