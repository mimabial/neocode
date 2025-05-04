-- lua/plugins/completion.lua
-- Enhanced completion menu with improved visual appearance

return {
  -- Enhanced LSP symbols with distinctive icons
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
      local lspkind = require("lspkind")

      -- Function to get theme-aware colors
      local function get_colors()
        -- Try to get colors from the current colorscheme
        local function get_hl_by_name(name)
          local hl = vim.api.nvim_get_hl(0, { name = name })
          return hl
        end

        -- Try to get gruvbox colors, falling back to defaults
        local function get_gruvbox_colors()
          if _G.get_gruvbox_colors then
            return _G.get_gruvbox_colors()
          end
          return {
            bg = "#282828",
            bg1 = "#32302f",
            bg2 = "#32302f",
            bg3 = "#45403d",
            bg4 = "#45403d",
            fg = "#d4be98",
            red = "#ea6962",
            orange = "#e78a4e",
            yellow = "#d8a657",
            green = "#89b482",
            aqua = "#7daea3",
            blue = "#7daea3",
            purple = "#d3869b",
            grey = "#928374",
          }
        end

        local colors = get_gruvbox_colors()

        -- Get panel colors - adaptive to current theme
        local normal = get_hl_by_name("Normal")
        local pmenu = get_hl_by_name("Pmenu")
        local pmenusel = get_hl_by_name("PmenuSel")
        local border = get_hl_by_name("FloatBorder")

        return {
          fg = normal.fg or colors.fg,
          bg = pmenu.bg or colors.bg1,
          select_bg = pmenusel.bg or colors.blue,
          select_fg = pmenusel.fg or colors.bg,
          border = border.fg or colors.bg3,
          copilot = "#6CC644",
          codeium = "#09B6A2",
          lsp = colors.blue,
          snippet = colors.green,
          buffer = colors.grey,
          path = colors.orange,
          emoji = colors.yellow,
        }
      end

      -- Get colors for current theme
      local colors = get_colors()

      -- AI suggestion priority comparator (fail-safe implementation)
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

      -- Enhanced window styling with better borders and highlights
      local win_opts = {
        winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
        scrollbar = true,
        border = "rounded",
        col_offset = 0,
        side_padding = 1,
      }

      -- Configure with enhanced visual appearance
      cmp.setup({
        completion = { completeopt = "menu,menuone,noinsert" },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(win_opts),
          documentation = cmp.config.window.bordered(vim.tbl_extend("force", win_opts, {
            max_height = 15,
            max_width = 60,
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
            -- Format using lspkind with improved styling
            vim_item = lspkind.cmp_format({
              mode = "symbol_text",
              maxwidth = 50,
              ellipsis_char = "...",
              menu = {
                buffer = " Buffer",
                nvim_lsp = " LSP",
                luasnip = " Snippet",
                nvim_lua = " Lua",
                path = " Path",
                emoji = " Emoji",
                copilot = " Copilot",
                codeium = " Codeium",
              },
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
                  vim_item.kind_hl_group = "CmpItemKindLSP" .. vim_item.kind
                end

                -- Add highlighting to the item abbr
                if entry.completion_item.data and entry.completion_item.data.detail then
                  vim_item.abbr = string.format("%s  %s", vim_item.abbr, entry.completion_item.data.detail)
                end

                return vim_item
              end,
            })(entry, vim_item)

            return vim_item
          end,
        },
        experimental = { ghost_text = { hl_group = "CmpGhostText" } },
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
      })

      -- Enhanced highlight groups for completion menu that adapt to theme
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local colors = get_colors()

          -- Create better highlighting
          -- Basic UI elements
          vim.api.nvim_set_hl(0, "CmpNormal", { bg = colors.bg })
          vim.api.nvim_set_hl(0, "CmpBorder", { fg = colors.border })
          vim.api.nvim_set_hl(0, "CmpSel", { bg = colors.select_bg, fg = colors.select_fg, bold = true })
          vim.api.nvim_set_hl(0, "CmpGhostText", { fg = colors.grey, italic = true })

          -- AI source highlighting
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = colors.copilot, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = colors.codeium, bold = true })

          -- LSP kinds with subtle color variations
          vim.api.nvim_set_hl(0, "CmpItemKindLSPFunction", { fg = colors.blue, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemKindLSPMethod", { fg = colors.blue })
          vim.api.nvim_set_hl(0, "CmpItemKindLSPVariable", { fg = colors.orange })
          vim.api.nvim_set_hl(0, "CmpItemKindLSPField", { fg = colors.green })
          vim.api.nvim_set_hl(0, "CmpItemKindLSPClass", { fg = colors.yellow, bold = true })
          vim.api.nvim_set_hl(0, "CmpItemKindLSPInterface", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "CmpItemKindLSPStruct", { fg = colors.purple })
          vim.api.nvim_set_hl(0, "CmpItemKindLSPConstant", { fg = colors.orange, bold = true })

          -- Other sources with distinctive colors
          vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = colors.snippet, italic = true })
          vim.api.nvim_set_hl(0, "CmpItemKindBuffer", { fg = colors.buffer })
          vim.api.nvim_set_hl(0, "CmpItemKindPath", { fg = colors.path })
        end,
      })

      -- Trigger the colorscheme autocmd to apply highlights
      vim.cmd("doautocmd ColorScheme")
    end,
  },
}
