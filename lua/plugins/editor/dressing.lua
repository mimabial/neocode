return {
  "stevearc/dressing.nvim",
  lazy = true,
  init = function()
    local lazy = require("lazy")
    vim.ui.select = function(...)
      lazy.load({ plugins = { "dressing.nvim" } })
      return require("dressing").select(...)
    end
    vim.ui.input = function(...)
      lazy.load({ plugins = { "dressing.nvim" } })
      return require("dressing").input(...)
    end
  end,
  opts = {
    input = {
      border = "single",
      title_pos = "center",
      mappings = {
        n = { ["<Esc>"] = "Close", ["<CR>"] = "Confirm" },
        i = {
          ["<C-c>"] = "Close",
          ["<CR>"] = "Confirm",
          ["<Up>"] = "HistoryPrev",
          ["<Down>"] = "HistoryNext",
        },
      },
    },
  },
}
