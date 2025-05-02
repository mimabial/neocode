-- lua/config/whichkey.lua
-- Centralized which-key configuration and key grouping
---@diagnostic disable: missing-fields
local M = {}

function M.setup()
  local ok, which_key = pcall(require, "which-key")
  if not ok then
    vim.notify("which-key.nvim not installed", vim.log.levels.WARN)
    return
  end

  -- Basic setup (you can adjust as needed)
  which_key.setup({
    plugins = {
      spelling = { enabled = true, suggestions = 20 },
    },
    icons = { breadcrumb = "»", separator = "➜", group = "+" },
    window = { border = "rounded", position = "bottom" },
  })

  -- Register key mappings with names for better grouping
  which_key.add({
    ["<leader>"] = {
      f = {
        name = "Find/Search", -- Snacks & Telescope
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
    },
  }, { mode = "n", prefix = "", silent = true, noremap = true })
end

return M
