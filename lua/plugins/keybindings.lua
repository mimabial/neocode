-- lua/plugins/which-key.lua
---@diagnostic disable: missing-fields

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  priority = 820,
  config = function()
    local ok, wk = pcall(require, "which-key")
    if not ok then
      vim.notify("[whichkey] which-key.nvim not found", vim.log.levels.WARN)
      return
    end

    -- Setup
    wk.setup({
      plugins = {
        marks = true, -- shows a list of your marks on ‘ and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = { enabled = false, suggestions = 20 },
        presets = {
          operators = false, -- adds help for operators like d, y, ...
          motions = false, -- adds help for motions
          text_objects = false, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling, etc.
          g = true, -- bindings for prefixed with g
        },
      },
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and its label
        group = "+", -- symbol prepended to a group
      },
      popup_mappings = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>", -- binding to scroll up inside the popup
      },
      window = {
        border = "single", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      },
    })

    -- Keybindings
    wk.register({
      ["<leader>"] = { name = "Leader" },
      f = {
        name = "Find/Search",
        f = { "<cmd>SnacksFiles<cr>", "Find Files" },
        g = { "<cmd>SnacksGrep<cr>", "Grep" },
        b = { "<cmd>SnacksBuffers<cr>", "Buffers" },
        h = { "<cmd>SnacksHelp<cr>", "Help" },
        r = { "<cmd>SnacksRecent<cr>", "Recent" },
        R = { "<cmd>SnacksSmart<cr>", "Frecent" },
        p = { "<cmd>SnacksProjects<cr>", "Projects" },
      },
      b = {
        name = "Buffers",
        b = { "<cmd>e #<cr>", "Other Buffer" },
        d = { "<cmd>bdelete<cr>", "Delete Buffer" },
        n = { "<cmd>bnext<cr>", "Next Buffer" },
        p = { "<cmd>bprevious<cr>", "Prev Buffer" },
      },
      e = {
        name = "Explorer",
        o = { "<cmd>ExplorerToggle oil<cr>", "Open Oil" },
        s = { "<cmd>ExplorerToggle snacks<cr>", "Open Snacks" },
      },
      u = {
        name = "Utilities",
        sg = { "<cmd>StackFocus goth<cr>", "Focus GOTH" },
        sn = { "<cmd>StackFocus nextjs<cr>", "Focus Next.js" },
        td = { "<cmd>ToggleTransparency<cr>", "Toggle Transparency" },
        cs = { "<cmd>ColorSchemeToggle<cr>", "Toggle Colorscheme" },
        lg = { "<cmd>LazyGit<cr>", "LazyGit" },
        ua = { "<cmd>UpdateAll<cr>", "Update All" },
      },
    }, { mode = "n", prefix = "", silent = true, noremap = true })
  end,
}
