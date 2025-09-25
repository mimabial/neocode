return {
  {
    "onsails/lspkind.nvim",
    lazy = true,
    priority = 75,
    opts = {
      mode = "symbol_text",
      symbol_map = {
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
        Copilot = "",
        Codeium = "󰚩",
      },
    },
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
      { "zbirenbaum/copilot-cmp",   optional = true },
      { "Exafunction/codeium.nvim", optional = true },
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      local function build_sources()
        return {
          { name = "codeium",  group_index = 0, priority = 100 }, -- Windsurf Plugins
          { name = "nvim_lsp", group_index = 1, priority = 90 },
          { name = "luasnip",  group_index = 1, priority = 80 },
          { name = "nvim_lua", group_index = 1, priority = 70 },
          { name = "buffer",   group_index = 2, priority = 50, keyword_length = 3 },
          { name = "path",     group_index = 2, priority = 40 },
          { name = "emoji",    group_index = 3, priority = 30 },
        }
      end

      -- Get UI config if available
      local ui_config = _G.get_ui_config and _G.get_ui_config() or {}
      local float_config = ui_config.float

      local win_opts = {
        winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel",
        border = float_config.border,
      }

      local cmp_config = {
        enabled = function()
          local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
          return filetype ~= "oil" and buftype ~= "prompt" and filetype ~= "TelescopePrompt"
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
        formatting = {
          format = function(entry, vim_item)
            -- Get menu icons for different sources
            local menu_icons = {
              buffer = " Buffer",
              nvim_lsp = " LSP",
              luasnip = " Snippet",
              nvim_lua = " Lua",
              path = " Path",
              emoji = " Emoji",
              codeium = " Codeium",
            }

            -- Format using lspkind with improved styling
            local formatted_item = lspkind.cmp_format({
              mode = "symbol_text",
              maxwidth = 50,
              ellipsis_char = "...",
              menu = menu_icons,
              before = function(entry, vim_item)
                if entry.source.name == "codeium" then
                  vim_item.kind = "Codeium"
                  vim_item.kind_hl_group = "CmpItemKindCodeium"
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

      -- Cmdline completions
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
