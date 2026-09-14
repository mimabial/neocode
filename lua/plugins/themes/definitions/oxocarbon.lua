local live = require("lib.live_theme")

return live.definition({
  plugin = "oxocarbon.nvim",
  background = function(_, opts)
    return opts.background or vim.o.background
  end,
  apply = function(_, opts)
    vim.cmd.colorscheme("oxocarbon")
    if opts.transparency then
      for _, group in ipairs({ "Normal", "NormalFloat", "NormalNC" }) do
        vim.api.nvim_set_hl(0, group, { bg = "none" })
      end
    end
  end,
})
