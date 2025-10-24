return {
  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local luasnip = require("luasnip")

      -- Configuration
      luasnip.config.setup({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        delete_check_events = "TextChanged",
        ext_opts = {
          [require("luasnip.util.types").choiceNode] = {
            active = {
              virt_text = { { "choiceNode", "Comment" } },
            },
          },
        },
        enable_autosnippets = true,
        store_selection_keys = "<Tab>",
      })

      -- Load snippet sources
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })

      -- Keymaps
      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        end
      end, { desc = "Expand or jump snippet" })

      vim.keymap.set({ "i", "s" }, "<C-h>", function()
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        end
      end, { desc = "Jump back in snippet" })

      vim.keymap.set("i", "<C-k>", function()
        if luasnip.choice_active() then
          luasnip.change_choice(1)
        end
      end, { desc = "Next choice in snippet" })

      vim.keymap.set("i", "<C-j>", function()
        if luasnip.choice_active() then
          luasnip.change_choice(-1)
        end
      end, { desc = "Previous choice in snippet" })
    end,
  },

  -- Community snippets
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
  },
}
