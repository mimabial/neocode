return {
  {
    "onsails/lspkind.nvim",
    lazy = true,
    priority = 75,
    opts = function()
      return { mode = "symbol_text", symbol_map = require("lib.icons").kinds }
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    priority = 1000,
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-nvim-lua" },
      { "hrsh7th/cmp-emoji" },
      { "saadparwaiz1/cmp_luasnip" },
      { "onsails/lspkind.nvim" },
      { "L3MON4D3/LuaSnip" },
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      local disabled_filetypes = { bigfile = true, oil = true, TelescopePrompt = true }

      local ui_config = require("config.ui").get_config() or {}
      local float_config = ui_config.float

      local win_opts = {
        winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel",
        border = float_config.border,
      }

      local cmp_config = {
        enabled = function()
          local buftype = vim.bo[0].buftype
          local filetype = vim.bo[0].filetype
          return not disabled_filetypes[filetype] and buftype ~= "prompt"
        end,
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(win_opts),
          documentation = cmp.config.window.bordered(vim.tbl_extend("force", win_opts, {
            max_height = float_config.max_height or 15,
            max_width = float_config.max_width or 60,
          })),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-f>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-b>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        performance = { max_view_entries = 50 },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "nvim_lua" },
        }, {
          { name = "path" },
          { name = "buffer", keyword_length = 3 },
        }, {
          { name = "emoji" },
        }),
        formatting = {
          format = function(entry, vim_item)
            local menu_icons = {
              buffer = " Buffer",
              nvim_lsp = " LSP",
              luasnip = " Snippet",
              nvim_lua = " Lua",
              path = " Path",
              emoji = " Emoji",
            }

            return lspkind.cmp_format({
              mode = "symbol_text",
              maxwidth = 50,
              ellipsis_char = "...",
              menu = menu_icons,
            })(entry, vim_item)
          end,
        },
      }

      cmp.setup(cmp_config)

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
        window = {
          completion = cmp.config.window.bordered(win_opts),
        },
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
        window = {
          completion = cmp.config.window.bordered(win_opts),
        },
      })
    end,
  },
}
