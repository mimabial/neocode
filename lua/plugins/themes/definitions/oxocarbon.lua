local live = require("lib.live_theme")

return live.definition({
  plugin = "oxocarbon.nvim",
  background = function(_, opts)
    return opts.background or vim.o.background
  end,
  apply = function(_, opts)
    vim.cmd.colorscheme("oxocarbon")
    if opts.transparency then
      local float = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
      float.bg = nil
      vim.api.nvim_set_hl(0, "NormalFloat", float)
    end
  end,
})
