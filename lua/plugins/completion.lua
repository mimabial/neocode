-- lua/plugins/completion.lua
-- Enhanced completion menu with improved visual appearance

return {
  -- Enhanced LSP symbols with distinctive icons
  {
    "onsails/lspkind.nvim",
    lazy = true,
    priority = 75,
    opts = function()
      -- Get icons from UI config if available
      local ui_config = _G.get_ui_config and _G.get_ui_config() or {}
      local icons = ui_config.icons and ui_config.icons.kinds
        or {
          -- Default icons if UI config not available
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
          -- AI completion sources with distinctive icons
          Copilot = "",
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
      { "zbirenbaum/copilot-cmp", optional = true },
      { "Exafunction/codeium.nvim", optional = true },
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      -- Get theme colors from central UI config if available
      local colors
      if _G.get_ui_colors then
        colors = _G.get_ui_colors()
      else
        -- Fallback to standalone function
        local function get_hl_by_name(name)
          local hl = vim.api.nvim_get_hl(0, { name = name }) or {}
          return hl
        end

        -- Get theme colors or use fallbacks
        local normal = get_hl_by_name("Normal")
        local pmenu = get_hl_by_name("Pmenu")
        local pmenusel = get_hl_by_name("PmenuSel")
        local border = get_hl_by_name("FloatBorder")

        colors = {
          fg = normal.fg or 0xd4be98,
          bg = pmenu.bg or 0x32302f,
          select_bg = pmenusel.bg or 0x45403d,
          select_fg = pmenusel.fg or 0xd4be98,
          border = border.fg or 0x665c54,
          copilot = 0x6CC644,
          codeium = 0x09B6A2,
          blue = 0x7daea3,
          green = 0x89b482,
          orange = 0xe78a4e,
          yellow = 0xd8a657,
          purple = 0xd3869b,
          red = 0xea6962,
          gray = 0x928374,
        }

        -- Convert number colors to hex strings
        for k, v in pairs(colors) do
          if type(v) == "number" then
            colors[k] = string.format("#%06x", v)
          end
        end
      end

      -- AI suggestion priority comparator
      local function ai_priority(entry1, entry2)
        local name1 = entry1.source.name or ""
        local name2 = entry2.source.name or ""

        -- Priority ratings: copilot > codeium > lsp > others
        local p1 = name1 == "copilot" and 100 or (name1 == "codeium" and 95 or (name1 == "nvim_lsp" and 90 or 0))
        local p2 = name2 == "copilot" and 100 or (name2 == "codeium" and 95 or (name2 == "nvim_lsp" and 90 or 0))

        if p1 ~= p2 then
          return p1 > p2
        end
        -- If priorities are equal, fall through to other comparators
        return nil
      end

      -- Build sources list with improved organization
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

      -- Get UI config if available
      local ui_config = _G.get_ui_config and _G.get_ui_config() or {}
      local float_config = ui_config.float or {
        border = "single",
        padding = { 0, 1 },
      }

      -- Enhanced window styling with better borders and highlights
      local win_opts = {
        winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel",
        scrollbar = true,
        border = float_config.border,
        col_offset = 0,
        side_padding = float_config.padding and float_config.padding[1] or 1,
      }

      -- Configure with enhanced visual appearance
      cmp.setup({
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
            vim_item = lspkind.cmp_format({
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

            return vim_item
          end,
        },
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

      -- Enhanced highlight groups for completion menu that adapt to theme
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- Update colors
          if _G.get_ui_colors then
            colors = _G.get_ui_colors()
          end

          -- Create better highlighting
          -- Basic UI elements
          vim.api.nvim_set_hl(0, "CmpNormal", { bg = colors.bg })
          vim.api.nvim_set_hl(0, "CmpBorder", { fg = colors.border })
          vim.api.nvim_set_hl(0, "CmpSel", { bg = colors.select_bg, fg = colors.select_fg, bold = true })
          vim.api.nvim_set_hl(0, "CmpGhostText", { fg = colors.gray, italic = true })

          -- AI source highlighting
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.copilot, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.codeium, bold = true })

          -- LSP kinds with subtle color variations
          vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = colors.blue, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = colors.blue })
          vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = colors.orange })
          vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = colors.green })
          vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = colors.yellow, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = colors.purple })
          vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = colors.orange, bold = true })

          -- Other sources with distinctive colors
          vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = colors.green, italic = true })
          vim.api.nvim_set_hl(0, "CmpItemKindBuffer", { fg = colors.gray })
          vim.api.nvim_set_hl(0, "CmpItemKindPath", { fg = colors.orange })

          -- Enhanced highlight groups for selected items
          vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.green, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = colors.green, bold = true })

          -- Create distinct highlighting for selected items
          vim.api.nvim_set_hl(0, "CmpSel", { bg = colors.select_bg, fg = colors.select_fg, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = colors.gray, strikethrough = true })

          -- Create special highlights for selected items
          vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = colors.green, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = colors.green, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemAbbrMatchSelected", { fg = colors.yellow, bg = colors.select_bg, bold = true })
          vim.api.nvim_set_hl(
            0,
            "CmpItemAbbrMatchFuzzySelected",
            { fg = colors.yellow, bg = colors.select_bg, bold = true }
          )

          -- Menu appearance for selected vs non-selected items
          vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = colors.gray, italic = true })
          vim.api.nvim_set_hl(
            0,
            "CmpItemMenuSelected",
            { fg = colors.fg, bg = colors.select_bg, italic = true, bold = true }
          )
        end,
      })
    end,
  },
}
