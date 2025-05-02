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
    config = function(_, opts)
      local lspkind = require("lspkind")
      lspkind.init(opts)
      _G.lspkind_symbol_map = lspkind.symbol_map
    end,
  },

  -- Core completion engine
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    priority = 1000,
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp", priority = 60 },
      { "hrsh7th/cmp-buffer", priority = 40 },
      { "hrsh7th/cmp-path", priority = 40 },
      { "hrsh7th/cmp-cmdline", priority = 40 },
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        priority = 70,
        dependencies = { "rafamadriz/friendly-snippets" },
      },
      { "saadparwaiz1/cmp_luasnip", priority = 50 },
      { "hrsh7th/cmp-nvim-lua", priority = 60 },
      { "hrsh7th/cmp-emoji", priority = 40 },
      {
        "zbirenbaum/copilot-cmp",
        dependencies = { "zbirenbaum/copilot.lua" },
        cond = function()
          return require("lazy.core.config").spec.plugins["copilot.lua"] ~= nil
        end,
        config = function()
          require("copilot_cmp").setup()
        end,
        priority = 55,
      },
      {
        "Exafunction/codeium.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cond = function()
          return require("lazy.core.config").spec.plugins["copilot.lua"] == nil
        end,
        opts = { enable_chat = false },
        config = function(_, opts)
          require("codeium").setup(opts)
        end,
        priority = 55,
      },
    },

    opts = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Check for non-space before cursor
      local function has_words_before()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]:sub(col, col):match("%s") == nil
      end

      -- AI suggestion priority comparator
      local function ai_priority(entry1, entry2)
        local name1, name2 = entry1.source.name, entry2.source.name
        local p1 = (name1 == "copilot" or name1 == "codeium") and 100 or (name1 == "nvim_lsp" and 90 or 0)
        local p2 = (name2 == "copilot" or name2 == "codeium") and 100 or (name2 == "nvim_lsp" and 90 or 0)
        if p1 ~= p2 then
          return p1 > p2
        end
      end

      -- Build sources list dynamically
      local function get_sources()
        local src = {
          { name = "nvim_lsp", group_index = 1, priority = 90 },
          { name = "luasnip", group_index = 1, priority = 80 },
          { name = "nvim_lua", group_index = 1, priority = 70 },
          { name = "buffer", group_index = 2, priority = 50, keyword_length = 3 },
          { name = "path", group_index = 2, priority = 40 },
          { name = "emoji", group_index = 3, priority = 30 },
        }
        if package.loaded["copilot_cmp"] then
          table.insert(src, 1, { name = "copilot", group_index = 1, priority = 100 })
        elseif package.loaded["codeium"] then
          table.insert(src, 1, { name = "codeium", group_index = 1, priority = 100 })
        end
        return src
      end

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

      return {
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
            elseif has_words_before() then
              cmp.complete()
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
        sources = get_sources(),
        sorting = { priority_weight = 2, comparators = get_comparators() },
        formatting = {
          format = function(entry, vim_item)
            if package.loaded["lspkind"] then
              vim_item = require("lspkind").cmp_format({
                mode = "symbol_text",
                maxwidth = 50,
                ellipsis_char = "...",
                symbol_map = _G.lspkind_symbol_map or {},
                menu = {
                  buffer = "[Buf]",
                  nvim_lsp = "[LSP]",
                  luasnip = "[Snip]",
                  nvim_lua = "[Lua]",
                  path = "[Path]",
                  emoji = "[Emoji]",
                  copilot = "[Cop]",
                  codeium = "[CI]",
                },
              })(entry, vim_item)
            end
            return vim_item
          end,
        },
        experimental = { ghost_text = { hl_group = "LspCodeLens" } },
      }
    end,

    config = function(_, opts)
      local cmp_ok, cmp = pcall(require, "cmp")
      if not cmp_ok then
        vim.notify("nvim-cmp could not be loaded", vim.log.levels.ERROR)
        return
      end
      
      -- Apply base setup
      cmp.setup(opts)

      -- Cmdline ":"
      cmp.setup.cmdline(" :", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
      -- Search "/"
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- Stack-specific priority adjustments
      local function adjust_priority(patterns)
        vim.api.nvim_create_autocmd("FileType", {
          pattern = patterns,
          callback = function()
            local buf_src = vim.deepcopy(opts.sources)
            for _, s in ipairs(buf_src) do
              if s.name == "nvim_lsp" then
                s.priority = s.priority + 5
              end
            end
            cmp.setup.buffer({ sources = buf_src })
          end,
        })
      end
      adjust_priority({ "go", "templ" })
      adjust_priority({ "javascript", "typescript", "javascriptreact", "typescriptreact" })

      -- Optional AI integrations
      pcall(require("copilot_cmp").setup)
      pcall(require("codeium").setup)

      -- Gruvbox Material highlights
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local c = _G.get_gruvbox_colors and _G.get_gruvbox_colors() or {}
          local hl = vim.api.nvim_set_hl
          hl(0, "CmpItemAbbrMatch", { fg = c.green, bold = true })
          hl(0, "CmpItemAbbrMatchFuzzy", { fg = c.green, bold = true })
          hl(0, "CmpItemKindFunction", { fg = c.blue })
          hl(0, "CmpItemKindMethod", { fg = c.blue })
          hl(0, "CmpItemKindVariable", { fg = c.purple })
          hl(0, "CmpItemKindKeyword", { fg = c.red })
          hl(0, "CmpItemKindProperty", { fg = c.aqua })
          hl(0, "CmpItemKindUnit", { fg = c.yellow })
        end,
      })
    end,
  },
}
