-- Kanagawa Theme Definition
return {
  icon = "",
  variants = { "wave", "dragon", "lotus" },
  setup = function(variant, transparency)
    require("kanagawa").setup({
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = transparency,
      dimInactive = false,
      terminalColors = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
      theme = variant or "wave",
      background = {
        dark = "wave",
        light = "lotus",
      },
    })
    vim.cmd("colorscheme kanagawa" .. (variant and ("-" .. variant) or ""))
  end,
}
