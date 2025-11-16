return {
  "ggandor/leap.nvim",
  event = "VeryLazy",
  dependencies = {
    "tpope/vim-repeat", -- Enables repeating leap operations with .
  },
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("leap").leap({ target_windows = { vim.fn.win_getid() } })
      end,
      desc = "Leap forward",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function()
        require("leap").leap({ backward = true, target_windows = { vim.fn.win_getid() } })
      end,
      desc = "Leap backward",
    },
    {
      "gs",
      mode = { "n", "x", "o" },
      function()
        require("leap").leap({
          target_windows = vim.tbl_filter(function(win)
            return vim.api.nvim_win_get_config(win).focusable
          end, vim.api.nvim_tabpage_list_wins(0)),
        })
      end,
      desc = "Leap from windows",
    },
  },
  config = function()
    local leap = require("leap")

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
