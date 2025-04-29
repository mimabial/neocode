return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp", priority = 60 },
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = {
        {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        }
      },
      priority = 70, -- Higher priority to load before completion
    },
    "saadparwaiz1/cmp_luasnip",
    {
      "onsails/lspkind.nvim",
      priority = 75, -- Load before completion
    },
    -- Add these for more sources
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-emoji",
    {
      "zbirenbaum/copilot-cmp",
      dependencies = {
        {
          "zbirenbaum/copilot.lua",
          cmd = "Copilot",
          event = "InsertEnter",
          opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
            filetypes = {
              markdown = true,
              help = true,
            },
          },
        }
      },
      config = function()
        require("copilot_cmp").setup()
      end
    },
  },
  opts = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Utility functions
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    local kind_icons = {
      Text = "",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "󰇽",
      Variable = "󰂡",
      Class = "󰠱",
      Interface = "",
      Module = "",
      Property = "󰜢",
      Unit = "",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰏿",
      Struct = "",
      Event = "",
      Operator = "󰆕",
      TypeParameter = "󰅲",
      Copilot = "",
    }

    -- Add borders to documentation float window
    local winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None"

    return {
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered({
          winhighlight = winhighlight,
        }),
        documentation = cmp.config.window.bordered({
          winhighlight = winhighlight,
        }),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
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
      sources = cmp.config.sources({
        { name = "copilot",  group_index = 1, priority = 100 },
        { name = "nvim_lsp", group_index = 1, priority = 90 },
        { name = "luasnip",  group_index = 1, priority = 80 },
        { name = "nvim_lua", group_index = 1, priority = 70 },
        { name = "buffer",   group_index = 2, priority = 50, keyword_length = 3 },
        { name = "path",     group_index = 2, priority = 40 },
        { name = "emoji",    group_index = 3, priority = 30 },
      }),
      sorting = {
        priority_weight = 2,
        comparators = {
          -- Make copilot/nvim_lsp suggestions appear at the top
          function(entry1, entry2)
            local kind1 = entry1:get_kind()
            local kind2 = entry2:get_kind()
            
            local priority1 = 0
            local priority2 = 0
            
            if entry1.source.name == "copilot" then priority1 = 100
            elseif entry1.source.name == "nvim_lsp" then priority1 = 90
            end
            
            if entry2.source.name == "copilot" then priority2 = 100
            elseif entry2.source.name == "nvim_lsp" then priority2 = 90
            end
            
            if priority1 ~= priority2 then
              return priority1 > priority2
            end
          end,
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
        format = lspkind.cmp_format({
          mode = "symbol_text",
          maxwidth = 50,
          ellipsis_char = "...",
          symbol_map = kind_icons,
          menu = {
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            nvim_lua = "[Lua]",
            path = "[Path]",
            emoji = "[Emoji]",
            copilot = "[Copilot]",
          },
        }),
      },
      experimental = {
        ghost_text = {
          hl_group = "LspCodeLens",
        },
      },
    }
  end,
  config = function(_, opts)
    local cmp = require("cmp")
    cmp.setup(opts)

    -- Set up specific configs for different filetypes or cmdline
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })

    -- Set up search completion
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- Add GOTH-specific sources when in templ or go files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "go", "templ" },
      callback = function()
        -- Make sure we don't interfere with copilot
        local sources = {
          { name = "nvim_lsp", group_index = 1, priority = 90 },
          { name = "luasnip",  group_index = 1, priority = 80 },
          { name = "buffer",   group_index = 2, priority = 50 },
          { name = "path",     group_index = 2, priority = 40 },
        }

        -- Check if copilot is installed and enabled
        local has_copilot = package.loaded["copilot_cmp"] ~= nil
        if has_copilot then
          table.insert(sources, 1, { name = "copilot", group_index = 1, priority = 100 })
        end

        -- Apply the modified sources to only this buffer
        cmp.setup.buffer({ sources = sources })
      end
    })

    -- Add Next.js specific sources when in JS/TS files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      callback = function()
        local sources = {
          { name = "nvim_lsp", group_index = 1, priority = 90 },
          { name = "luasnip",  group_index = 1, priority = 80 },
          { name = "buffer",   group_index = 2, priority = 50 },
          { name = "path",     group_index = 2, priority = 40 },
        }

        -- Check if copilot is installed and enabled
        local has_copilot = package.loaded["copilot_cmp"] ~= nil
        if has_copilot then
          table.insert(sources, 1, { name = "copilot", group_index = 1, priority = 100 })
        end

        -- Apply the modified sources to only this buffer
        cmp.setup.buffer({ sources = sources })
      end
    })

    -- Load Copilot if available
    pcall(function()
      require("copilot_cmp").setup()
    end)
  end,
}
