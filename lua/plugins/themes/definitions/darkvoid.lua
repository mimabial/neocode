-- Darkvoid Theme Definition
return {
  icon = "",
  variants = { "default", "glow" },
  setup = function(opts)
    require("darkvoid").setup({
      transparent = opts.transparency,
      glow = opts.variant == "glow",
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
