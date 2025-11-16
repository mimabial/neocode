return {
  "ggandor/leap.nvim",
  event = "VeryLazy",
  dependencies = {
    "tpope/vim-repeat", -- Enables repeating leap operations with .
  },
  keys = {
    { "s", mode = { "n", "x", "o" }, desc = "Leap forward" },
    { "S", mode = { "n", "x", "o" }, desc = "Leap backward" },
    { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
  },
  config = function()
    local leap = require("leap")

    -- Use default mappings
    leap.add_default_mappings()

    -- Enhanced highlighting
    vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
    vim.api.nvim_set_hl(0, "LeapMatch", {
      fg = "white",
      bold = true,
      nocombine = true,
    })

    -- Customize leap settings
    leap.opts.case_sensitive = false
    leap.opts.equivalence_classes = { " \t\r\n" }

    -- Repeat leap operations with . (via vim-repeat)
    vim.api.nvim_create_autocmd("User", {
      pattern = "LeapEnter",
      callback = function()
        vim.cmd("silent! call repeat#set(\"\\<Plug>(leap-forward)\", -1)")
      end,
    })
  end,
}
