return {
  "Exafunction/windsurf.nvim",
  cmd = "Codeium",
  event = "InsertEnter",
  dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
  config = function()
    require("codeium").setup({
      enable_chat = true,
      enable_cmp_source = false,
      virtual_text = {
        enabled = true,
        idle_delay = 100,
        accept_fallback = "<C-y>",
        filetypes = { TelescopePrompt = false, bigfile = false, oil = false },
        key_bindings = { accept = "<C-y>" },
      },
    })

    vim.keymap.set("n", "<leader>ac", "<cmd>Codeium Chat<cr>", { desc = "Codeium: Open Chat" })
  end,
}
