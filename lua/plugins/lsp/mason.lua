return {
  "williamboman/mason.nvim",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  build = ":MasonUpdate",
  opts = function()
    return { ui = { border = "single", icons = require("lib.icons").mason } }
  end,
}
