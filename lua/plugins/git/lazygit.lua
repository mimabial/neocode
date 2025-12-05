-- Git Namespace Owner
-- This file coordinates the <leader>g* namespace for git operations
--
-- Keybinding organization:
--   <leader>gg  → LazyGit (defined here)
--   <leader>go* → Octo (GitHub operations - see plugins/git/octo.lua)
--   <leader>gh* → Gitsigns (hunk operations - see plugins/git/gitsigns.lua)
--   <leader>h*  → Gitsigns (hunk operations - see plugins/git/gitsigns.lua)
--   <leader>fg* → Telescope git searches (see plugins/search/telescope.lua)
--   ]c / [c     → Next/Previous hunk (see plugins/git/gitsigns.lua)

return {
  "kdheepak/lazygit.nvim",
  cmd = "LazyGit",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
  },
}
