-- lua/plugins/copilot.lua

-- GitHub Copilot integration
return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  lazy = true,
  opts = function()
    return {
      panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
          jump_next = "<Tab>",
          jump_prev = "<S-Tab>",
          accept = "<CR>",
          refresh = "gr",
          open = "<leader>cp",
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<C-]>",
          next = "<C-.>",
          prev = "<C-,>",
          dismiss = "<C-[>",
        },
      },
      filetypes = {
        yaml = true,
        xml = true,
        markdown = true,
        sh = true,
        zsh = true,
        fish = true,
        help = false,
      },
      copilot_node_command = "node", -- Node.js command path
      server_opts_overrides = {},
    }
  end,
  config = function(_, opts)
    require("copilot").setup(opts)
    -- Optional: integrate with completion plugin
    vim.keymap.set("i", "<C-Space>", function()
      require("copilot.suggestion").toggle_auto_trigger()
    end, { desc = "Toggle Copilot Auto Trigger" })
  end,
}
