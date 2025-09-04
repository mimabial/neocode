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
      enabled = true,
      default_prompt = "Input:",
      prompt_align = "left",
      insert_only = true,
      start_in_insert = true,
      border = "rounded",
      relative = "cursor",
      prefer_width = 40,
      width = nil,
      max_width = { 140, 0.9 },
      min_width = { 20, 0.2 },
      win_options = { winblend = 0, wrap = false },
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
