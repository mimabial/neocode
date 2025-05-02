-- lua/plugins/ai.lua
-- Integrated AI completion with Copilot and Codeium

return {
  -- GitHub Copilot integration
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    dependencies = {
      "zbirenbaum/copilot-cmp",
      "nvim-lua/plenary.nvim",
    },
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        yaml = true,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        ["."] = false,
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
      -- Register keymaps for toggling
      vim.keymap.set("n", "<leader>uc", function()
        local copilot_client = vim.lsp.get_clients({ name = "copilot" })[1]
        if copilot_client then
          copilot_client.stop()
          vim.notify("Copilot disabled", vim.log.levels.INFO)
        else
          require("copilot").setup(opts)
          vim.notify("Copilot enabled", vim.log.levels.INFO)
        end
      end, { desc = "Toggle Copilot" })
    end,
  },

  -- Copilot CMP integration
  {
    "zbirenbaum/copilot-cmp",
    dependencies = "copilot.lua",
    opts = {},
    config = function(_, opts)
      local copilot_cmp = require("copilot_cmp")
      copilot_cmp.setup(opts)

      -- Add custom formatting for better Copilot suggestions display
      if require("cmp.config").get().formatting then
        local format_kinds = require("cmp.config").get().formatting.format
        require("cmp.config").set({
          formatting = {
            format = function(entry, item)
              if format_kinds then
                format_kinds(entry, item)
              end

              -- Add symbol for Copilot
              if entry.source.name == "copilot" then
                item.kind = " Copilot"
                item.kind_hl_group = "CmpItemKindCopilot"
              end

              return item
            end,
          },
        })
      end
    end,
  },

  -- Codeium integration
  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    cmd = "Codeium",
    build = ":Codeium Auth",
    opts = {
      enable_chat = false,
      tools = {
        language_server = {
          enabled = true,
        },
      },
    },
    config = function(_, opts)
      require("codeium").setup(opts)

      -- Register toggle keybinding
      vim.keymap.set("n", "<leader>ui", function()
        if vim.g.codeium_enabled then
          vim.cmd("CodeiumDisable")
          vim.notify("Codeium disabled", vim.log.levels.INFO)
        else
          vim.cmd("CodeiumEnable")
          vim.notify("Codeium enabled", vim.log.levels.INFO)
        end
      end, { desc = "Toggle Codeium" })
    end,
  },
}
