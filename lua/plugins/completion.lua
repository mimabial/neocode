-- lua/plugins/completion.lua

return {
  -- Enhanced LSP symbols
  {
    "onsails/lspkind.nvim",
    lazy = true,
    priority = 75,
    opts = function()
      return {
        preset = "codicons",
        mode = "symbol_text",
        symbol_map = {
          Text = "󰉿",
          Method = "󰆧",
          Function = "󰊕",
          Field = "󰜢",
          Variable = "󰀫",
          Class = "󰠱",
          Property = "󰜢",
          Unit = "󰑭",
          Value = "󰎠",
          Keyword = "󰌋",
          Color = "󰏘",
          File = "󰈙",
          Reference = "󰈇",
          Folder = "󰉋",
          Constant = "󰏿",
          Struct = "󰙅",
          Operator = "󰆕",
          TypeParameter = "󰅲",
          Copilot = "",
          Codeium = "",
        },
      }
    end,
  },

  -- Core completion engine
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
      { "zbirenbaum/copilot-cmp" },
      { "Exafunction/codeium.nvim" },
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- -- Check for non-space before cursor
      -- local function has_words_before()
      --   local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      --   return col ~= 0 and vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]:sub(col, col):match("%s") == nil
      -- end

      -- AI suggestion priority comparator
      local function ai_priority(entry1, entry2)
        local name1, name2 = entry1.source.name, entry2.source.name

        -- Priority ratings: copilot > codeium > lsp > others
        local p1 = name1 == "copilot" and 100 or (name1 == "codeium" and 95 or (name1 == "nvim_lsp" and 90 or 0))

        local p2 = name2 == "copilot" and 100 or (name2 == "codeium" and 95 or (name2 == "nvim_lsp" and 90 or 0))

        if p1 ~= p2 then
          return p1 > p2
        end
      end

      -- Build sources list dynamically
      local sources = {
        { name = "copilot", group_index = 1, priority = 100 },
        { name = "codeium", group_index = 1, priority = 95 },
        { name = "nvim_lsp", group_index = 1, priority = 90 },
        { name = "luasnip", group_index = 1, priority = 80 },
        { name = "nvim_lua", group_index = 1, priority = 70 },
        { name = "buffer", group_index = 2, priority = 50, keyword_length = 3 },
        { name = "path", group_index = 2, priority = 40 },
        { name = "emoji", group_index = 3, priority = 30 },
      }

      -- Special window with highlights for completion
      local winhl = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None"

      -- Default comparators + AI priority
      local function get_comparators()
        local comps = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        }
        if package.loaded["copilot_cmp"] or package.loaded["codeium"] then
          table.insert(comps, 1, ai_priority)
        end
        return comps
      end

      -- Floating window highlights
      local winhl = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None"

      -- Configure with AI-friendly settings
      cmp.setup({
        completion = { completeopt = "menu,menuone,noinsert" },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered({ winhighlight = winhl }),
          documentation = cmp.config.window.bordered({ winhighlight = winhl }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
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
        sources = cmp.config.sources(sources),
        sorting = {
          priority_weight = 2,
          comparators = {
            ai_priority, -- Our custom AI comparator first
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        formatting = {
          format = function(entry, vim_item)
            if require("lspkind") then
              vim_item = require("lspkind").cmp_format({
                mode = "symbol_text",
                maxwidth = 50,
                ellipsis_char = "...",
                menu = {
                  buffer = "[Buf]",
                  nvim_lsp = "[LSP]",
                  luasnip = "[Snip]",
                  nvim_lua = "[Lua]",
                  path = "[Path]",
                  emoji = "[Emoji]",
                  copilot = "[CP]",
                  codeium = "[CI]",
                },
              })(entry, vim_item)
            end
            return vim_item
          end,
        },
        experimental = { ghost_text = { hl_group = "LspCodeLens" } },
      })

      -- Cmdline completions
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- Gruvbox Material highlights for completion menu
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644", bold = true })
          vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#09B6A2", bold = true })
        end,
      })

      -- Special handling for AI provider-specific keys
      vim.keymap.set("i", "<C-]>", function()
        local copilot_keys = vim.fn["copilot#Accept"]()
        if copilot_keys ~= "" then
          vim.api.nvim_feedkeys(copilot_keys, "i", true)
        end
      end, { desc = "Copilot Accept", silent = true, expr = true })
    end,
  },
}
