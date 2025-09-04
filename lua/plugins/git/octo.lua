return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  keys = {
    { "<leader>go",  "<cmd>Octo<cr>",            desc = "Octo" },
    { "<leader>gpr", "<cmd>Octo pr list<cr>",    desc = "PR List" },
    { "<leader>gi",  "<cmd>Octo issue list<cr>", desc = "Issue List" },
  },
  config = function()
    require("octo").setup()
  end,
}
