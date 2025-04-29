return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp", priority = 60 },
    { "hrsh7th/cmp-buffer", priority = 40 },
    { "hrsh7th/cmp-path", priority = 40 },
    { "hrsh7th/cmp-cmdline", priority = 40 },
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
    { "saadparwaiz1/cmp_luasnip", priority = 50 },
    {
      "onsails/lspkind.nvim",
      priority = 75, -- Load before completion
    },
    -- Add these for more sources
    { "hrsh7th/cmp-nvim-lua", priority = 60 },
    { "hrsh7th/cmp-emoji", priority = 40 },
    -- Conditionally enable copilot-cmp if copilot is installed
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
      end,
      cond = function()
        return require("lazy.core.config").spec.plugins["copilot.lua"] ~= nil
      end,
      priority = 55,
    },
    -- Alternative: Codeium if Copilot is not available
    {
      "Exafunction/codeium.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      cond = function()
        return require("lazy.core.config").spec.plugins["copilot.lua"] == nil
      end,
      opts = {
        enable_chat = false,
      },
      priority = 55,
    },
  },
  opts = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Add custom snippets for GOTH stack and Next.js
    -- This will load any custom snippets in the LuaSnip directory
    require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

    -- Stack-specific snippets
    if vim.g.current_stack == "goth" then
      -- Load GOTH stack specific snippets (Go, Templ, HTMX)
      luasnip.add_snippets("templ", require("snippets.templ"))
      luasnip.add_snippets("go", require("snippets.go"))
    elseif vim.g.current_stack == "nextjs" then
      -- Load Next.js stack specific snippets
      luasnip.add_snippets("typescriptreact", require("snippets.nextjs"))
      luasnip.add_snippets("javascriptreact", require("snippets.nextjs"))
      luasnip.add_snippets("typescript", require("snippets.typescript"))
      luasnip.add_snippets("javascript", require("snippets.javascript"))
    end

    -- Utility functions
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    -- Icons for lspkind
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
      Codeium = "",
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
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
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
      sources = function()
        local sources = {
          { name = "nvim_lsp", group_index = 1, priority = 90 },
          { name = "luasnip",  group_index = 1, priority = 80 },
          { name = "nvim_lua", group_index = 1, priority = 70 },
          { name = "buffer",   group_index = 2, priority = 50, keyword_length = 3 },
          { name = "path",     group_index = 2, priority = 40 },
          { name = "emoji",    group_index = 3, priority = 30 },
        }
        
        -- Add copilot or codeium if available
        if package.loaded["copilot_cmp"] then
          table.insert(sources, 1, { name = "copilot", group_index = 1, priority = 100 })
        elseif package.loaded["codeium"] then
          table.insert(sources, 1, { name = "codeium", group_index = 1, priority = 100 })
        end
        
        return sources
      end,
      sorting = {
        priority_weight = 2,
        comparators = function()
          -- Default comparators
          local comparators = {
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
          
          -- Add AI suggestion priority if available
          if package.loaded["copilot_cmp"] or package.loaded["codeium"] then
            table.insert(comparators, 1, function(entry1, entry2)
              local kind1 = entry1:get_kind()
              local kind2 = entry2:get_kind()
              
              local priority1 = 0
              local priority2 = 0
              
              if entry1.source.name == "copilot" or entry1.source.name == "codeium" then
                priority1 = 100
              elseif entry1.source.name == "nvim_lsp" then
                priority1 = 90
              end
              
              if entry2.source.name == "copilot" or entry2.source.name == "codeium" then
                priority2 = 100
              elseif entry2.source.name == "nvim_lsp" then
                priority2 = 90
              end
              
              if priority1 ~= priority2 then
                return priority1 > priority2
              end
            end)
          end
          
          return comparators
        end,
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
            codeium = "[Codeium]",
          },
          before = function(entry, vim_item)
            -- Apply special highlighting for stack-specific items
            if vim.g.current_stack == "goth" then
              if entry.source.name == "nvim_lsp" then
                local client = vim.lsp.get_client_by_id(entry.source.source.client_id)
                if client and (client.name == "gopls" or client.name == "templ") then
                  vim_item.dup = 0 -- Higher priority for GOTH stack LSP items
                end
              end
            elseif vim.g.current_stack == "nextjs" then
              if entry.source.name == "nvim_lsp" then
                local client = vim.lsp.get_client_by_id(entry.source.source.client_id)
                if client and (client.name == "tsserver" or client.name == "typescript-tools") then
                  vim_item.dup = 0 -- Higher priority for Next.js stack LSP items
                end
              end
            end
            
            return vim_item
          end,
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
    local options = opts()
    
    -- Set up completion sources
    options.sources = options.sources()
    
    -- Set up sorting comparators
    options.sorting.comparators = options.sorting.comparators()
    
    -- Setup cmp
    cmp.setup(options)

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
        -- Deep copy the original sources to avoid modifying the global config
        local sources = vim.deepcopy(options.sources)
        
        -- Adjust priorities for GOTH stack
        for _, source in ipairs(sources) do
          if source.name == "nvim_lsp" then
            source.priority = source.priority + 5
          end
        end
        
        -- Apply the modified sources to only this buffer
        cmp.setup.buffer({ sources = sources })
      end
    })

    -- Add Next.js specific sources when in JS/TS files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      callback = function()
        -- Deep copy the original sources to avoid modifying the global config
        local sources = vim.deepcopy(options.sources)
        
        -- Adjust priorities for Next.js stack
        for _, source in ipairs(sources) do
          if source.name == "nvim_lsp" then
            source.priority = source.priority + 5
          end
        end
        
        -- Apply the modified sources to only this buffer
        cmp.setup.buffer({ sources = sources })
      end
    })

    -- Load Copilot if available
    pcall(function()
      require("copilot_cmp").setup()
    end)
    
    -- Load Codeium if available
    pcall(function()
      require("codeium").setup()
    end)
    
    -- Apply Gruvbox Material highlighting to completion items
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        -- Get colors from Gruvbox Material
        local colors = _G.get_gruvbox_colors and _G.get_gruvbox_colors() or {
          bg = "#282828",
          green = "#89b482",
          red = "#ea6962",
          blue = "#7daea3",
          yellow = "#d8a657",
          aqua = "#7daea3",
          purple = "#d3869b",
        }
        
        -- Set completion menu colors
        vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.green, bold = true })
        vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = colors.green, bold = true })
        vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.green })
        vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.green })
        vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = colors.blue })
        vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = colors.blue })
        vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = colors.purple })
        vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = colors.red })
        vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = colors.aqua })
        vim.api.nvim_set_hl(0, "CmpItemKindUnit", { fg = colors.yellow })
      end,
    })
  end,
}
