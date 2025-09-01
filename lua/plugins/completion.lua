return {
  -- Enhanced LSP symbols with distinctive icons
  {
    "onsails/lspkind.nvim",
    lazy = true,
    priority = 75,
    opts = function()
      local icons = {
        -- LSP kinds
        Text = "󰉿",
        Method = "󰆧",
        Function = "󰊕",
        Constructor = "󰆧",
        Field = "󰜢",
        Variable = "󰀫",
        Class = "󰠱",
        Interface = "󰕘",
        Module = "󰏗",
        Property = "󰜢",
        Unit = "󰑭",
        Value = "󰎠",
        Enum = "󰒻",
        Keyword = "󰌋",
        Snippet = "󰅪",
        Color = "󰏘",
        File = "󰈙",
        Reference = "󰈇",
        Folder = "󰉋",
        EnumMember = "󰒻",
        Constant = "󰏿",
        Struct = "󰙅",
        Event = "󰉁",
        Operator = "󰆕",
        TypeParameter = "󰅲",
        -- AI completion sources
        Copilot = "",
        Codeium = "󰚩",
      }

      return {
        preset = "codicons",
        mode = "symbol_text",
        symbol_map = icons,
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
      { "zbirenbaum/copilot-cmp",   optional = true },
      { "Exafunction/codeium.nvim", optional = true },
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
      local lspkind = require("lspkind")

      local function build_sources()
        local sources = {}

        local active_provider = _G.get_ai_active_provider()
        if active_provider then
          table.insert(sources, { name = active_provider, group_index = 0, priority = 100 })
        end

        vim.list_extend(sources, {
          { name = "nvim_lsp", group_index = 1, priority = 90 },
          { name = "luasnip",  group_index = 1, priority = 80 },
          { name = "nvim_lua", group_index = 1, priority = 70 },
          { name = "buffer",   group_index = 2, priority = 50, keyword_length = 3 },
          { name = "path",     group_index = 2, priority = 40 },
          { name = "emoji",    group_index = 3, priority = 30 },
        })

        return sources
      end

      -- Get UI config if available
      local ui_config = _G.get_ui_config and _G.get_ui_config() or {}

      -- Always use single border style
      local border = "single"

      local float_config = vim.tbl_deep_extend("force", {
        border = border,
        padding = { 0, 1 },
        max_width = 80,
        max_height = 20,
      }, ui_config.float or {})

      -- Force single border
      float_config.border = border

      -- Enhanced window styling with better borders and highlights
      local win_opts = {
        winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel",
        scrollbar = true,
        border = float_config.border,
        col_offset = 0,
        side_padding = float_config.padding and float_config.padding[1] or 1,
      }

      -- Configure with enhanced visual appearance
      local cmp_config = {
        enabled = function()
          -- Disable completion in Oil buffers
          local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })

          if filetype == "oil" then
            return false
          end

          -- Also disable for other file explorer/special buffers
          if buftype == "prompt" or filetype == "TelescopePrompt" then
            return false
          end

          return true
        end,
        completion = { completeopt = "menu,menuone,noinsert" },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(vim.tbl_extend("force", win_opts, {
            winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
          })),
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
          -- Jump to the next snippet placeholder
          ["<C-f>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          -- Jump to the previous snippet placeholder
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
        sources = cmp.config.sources(build_sources()),
        sorting = {
          priority_weight = 2,
          comparators = {
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
          -- Enhanced formatting with better visual distinction
          format = function(entry, vim_item)
            -- Get menu icons for different sources
            local menu_icons = {
              buffer = " Buffer",
              nvim_lsp = " LSP",
              luasnip = " Snippet",
              nvim_lua = " Lua",
              path = " Path",
              emoji = " Emoji",
              copilot = " Copilot",
              codeium = " Codeium",
            }

            -- Format using lspkind with improved styling
            local formatted_item = lspkind.cmp_format({
              mode = "symbol_text",
              maxwidth = 50,
              ellipsis_char = "...",
              menu = menu_icons,
              before = function(entry, vim_item)
                -- Add additional styling for AI sources
                if entry.source.name == "copilot" then
                  vim_item.kind = "Copilot"
                  vim_item.kind_hl_group = "CmpItemKindCopilot"
                elseif entry.source.name == "codeium" then
                  vim_item.kind = "Codeium"
                  vim_item.kind_hl_group = "CmpItemKindCodeium"
                end

                -- Set kind highlights based on source
                if entry.source.name == "nvim_lsp" then
                  vim_item.kind_hl_group = "CmpItemKind" .. vim_item.kind
                end

                return vim_item
              end,
            })(entry, vim_item)

            return formatted_item
          end,
        },
      }

      -- Initial setup
      cmp.setup(cmp_config)

      -- Reload cmp when AI provider changes
      vim.api.nvim_create_autocmd("User", {
        pattern = "AIProviderChanged",
        callback = function()
          -- Update sources in the stored config
          cmp_config.sources = cmp.config.sources(build_sources())
          -- Reconfigure cmp with updated sources
          cmp.setup(cmp_config)
        end,
      })

      -- Cmdline completions with enhanced styling
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
        formatting = {
          format = function(entry, vim_item)
            vim_item.kind = lspkind.symbolic(vim_item.kind, { mode = "symbol" })
            return vim_item
          end,
        },
        window = {
          completion = cmp.config.window.bordered(win_opts),
        },
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
        formatting = {
          format = function(entry, vim_item)
            vim_item.kind = lspkind.symbolic(vim_item.kind, { mode = "symbol" })
            return vim_item
          end,
        },
        window = {
          completion = cmp.config.window.bordered(win_opts),
        },
      })
    end,
  },
}
