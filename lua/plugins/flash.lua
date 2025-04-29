return {
  "folke/flash.nvim",
  event = "VeryLazy",
  priority = 70,
  opts = {
    labels = "asdfghjklqwertyuiopzxcvbnm",
    search = {
      mode = "fuzzy",
      exclude = {
        function(win)
          -- Exclude certain filetypes
          local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
          return ft == "neo-tree" or ft == "oil"
        end,
        function(win)
          -- Exclude floating windows
          return vim.api.nvim_win_get_config(win).relative ~= ""
        end,
      },
    },
    jump = {
      inclusive = true,
      autojump = true,
    },
    modes = {
      char = {
        enabled = true,
        search = { mode = "fuzzy" },
      },
      search = {
        enabled = true,
        highlight = { backdrop = true },
      },
      treesitter = {
        labels = "abcdefghijklmnopqrstuvwxyz",
        jump = { pos = "range" },
      },
    },
  },
  -- Define keys directly with vim.keymap.set
  config = function(_, opts)
    require("flash").setup(opts)
    
    -- Set keymaps with vim.keymap.set instead of in the keys table
    vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })
    vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash treesitter" })
    vim.keymap.set("o", "r", function() require("flash").remote() end, { desc = "Flash remote" })
    vim.keymap.set({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Flash treesitter search" })
    vim.keymap.set("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle flash search" })
    
    -- Register descriptions with which-key
    local wk_ok, wk = pcall(require, "which-key")
    if wk_ok then
      wk.register({
        s = "Flash jump",
        S = "Flash treesitter",
        r = "Flash remote",
        R = "Flash treesitter search",
      })
    end
  end,
}
