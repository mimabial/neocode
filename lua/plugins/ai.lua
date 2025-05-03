-- lua/plugins/ai.lua
-- Enhanced AI integration with both Copilot and Codeium working together

return {
  -- GitHub Copilot integration
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    dependencies = {
      "zbirenbaum/copilot-cmp", -- For completion menu integration
    },
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<C-]>",
          accept_word = "<M-]>",
          accept_line = "<C-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-[>",
        },
      },
      panel = {
        enabled = true,
        auto_refresh = true,
      },
      filetypes = {
        -- Enable for all filetypes including templ
        ["*"] = true,
        -- Except these
        TelescopePrompt = false,
        DressingInput = false,
        ["neo-tree-popup"] = false,
        ["oil"] = false,
        help = false,
        git = false,
        gitcommit = false,
        gitrebase = false,
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)

      -- Highlight groups for copilot
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- Set highlight groups compatible with gruvbox-material
          vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#928374", italic = true })
          vim.api.nvim_set_hl(0, "CopilotAnnotation", { fg = "#928374", italic = true })
          vim.api.nvim_set_hl(
            0,
            "CopilotSuggestionActive",
            { bg = "#32302f", fg = "#a89984", italic = true, bold = true }
          )
        end,
      })

      -- -- Toggle keymap with fancy notification
      -- vim.keymap.set("n", "<leader>uc", function()
      --   local status = require("copilot.client").is_started()
      --   if status then
      --     vim.cmd("Copilot disable")
      --     vim.notify(" Copilot disabled", vim.log.levels.INFO, { title = "Copilot" })
      --   else
      --     vim.cmd("Copilot enable")
      --     vim.notify(" Copilot enabled", vim.log.levels.INFO, { title = "Copilot" })
      --   end
      -- end, { desc = "Toggle Copilot" })
    end,
  },

  -- Copilot CMP integration
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua", "hrsh7th/nvim-cmp" },
    opts = {
      method = "getCompletionsCycling",
      formatters = {
        label = function(suggestion)
          local label = suggestion.displayText or ""
          if vim.startswith(label, "copilot:") then
            label = label:sub(9)
          end
          return " " .. label
        end,
        insert_text = function(suggestion)
          return suggestion.insertText
        end,
        preview = function(suggestion)
          return suggestion.displayText
        end,
      },
    },
    config = function(_, opts)
      require("copilot_cmp").setup(opts)
    end,
  },

  -- Codeium integration
  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",
    event = "InsertEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    enabled = true, -- Always enable so it can act as a fallback
    config = function()
      -- Use all of the built-in defaults
      require("codeium").setup()

      -- Ensure Codeium is enabled by default
      if vim.g.codeium_enabled == nil then
        vim.g.codeium_enabled = true
      end

      -- Highlight groups for suggestions
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = "#928374", italic = true })
          vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#09B6A2", bold = true })
        end,
      })
      -- -- Toggle Codeium on/off
      -- vim.keymap.set("n", "<leader>ui", function()
      --   vim.cmd("Codeium Toggle")
      -- end, { desc = "Toggle Codeium" })

      -- Insert-mode keymaps
      local keymaps = {
        ["<C-g>"] = { vim.fn["codeium#Accept"], "Accept" },
        ["<C-;>"] = {
          function()
            return vim.fn["codeium#CycleCompletions"](1)
          end,
          "Next completion",
        },
        ["<C-,>"] = {
          function()
            return vim.fn["codeium#CycleCompletions"](-1)
          end,
          "Prev completion",
        },
        ["<C-x>"] = { vim.fn["codeium#Clear"], "Clear suggestions" },
      }

      for key, mapping in pairs(keymaps) do
        vim.keymap.set("i", key, mapping[1], { expr = true, desc = "Codeium: " .. mapping[2] })
      end
    end,
  },

  -- Enhanced completion integration for both AI tools
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "saadparwaiz1/cmp_luasnip" },
      { "L3MON4D3/LuaSnip" },
      { "zbirenbaum/copilot-cmp", optional = true },
      { "Exafunction/codeium.nvim", optional = true },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Ensure AI completion sources have proper priorities
      local sources = {
        { name = "copilot", group_index = 1, priority = 100 }, -- Highest priority
        { name = "codeium", group_index = 1, priority = 95 }, -- Fallback AI
        { name = "nvim_lsp", group_index = 1, priority = 90 }, -- LSP comes after AI
        { name = "luasnip", group_index = 1, priority = 80 },
        { name = "buffer", group_index = 2, priority = 70, keyword_length = 3 },
        { name = "path", group_index = 2, priority = 60 },
      }

      -- AI suggestion priority comparator
      local function ai_priority(entry1, entry2)
        local name1, name2 = entry1.source.name, entry2.source.name

        -- Set explicit priorities for AI sources vs others
        local p1 = name1 == "copilot" and 100 or (name1 == "codeium" and 95 or (name1 == "nvim_lsp" and 90 or 0))
        local p2 = name2 == "copilot" and 100 or (name2 == "codeium" and 95 or (name2 == "nvim_lsp" and 90 or 0))

        if p1 ~= p2 then
          return p1 > p2
        end
      end

      -- Special window with highlights for completion
      local winhl = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None"

      -- Configure with AI-friendly settings
      cmp.setup({
        completion = {
          completeopt = "menu,menuone,noinsert",
          autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
        },
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
            -- Try to use lspkind if available
            local has_lspkind, lspkind = pcall(require, "lspkind")
            if has_lspkind then
              vim_item = lspkind.cmp_format({
                mode = "symbol_text",
                maxwidth = 50,
                ellipsis_char = "...",
                menu = {
                  buffer = "[Buf]",
                  nvim_lsp = "[LSP]",
                  luasnip = "[Snip]",
                  nvim_lua = "[Lua]",
                  path = "[Path]",
                  copilot = "[CP]",
                  codeium = "[CI]",
                },
              })(entry, vim_item)
            else
              -- Basic formatting without lspkind
              local source_names = {
                copilot = "[CP]",
                codeium = "[CI]",
                nvim_lsp = "[LSP]",
                luasnip = "[Snip]",
                buffer = "[Buf]",
                path = "[Path]",
              }
              vim_item.menu = source_names[entry.source.name] or "[" .. entry.source.name .. "]"
            end

            -- Special handling for AI sources
            if entry.source.name == "copilot" then
              vim_item.kind = "Copilot"
              vim_item.kind_hl_group = "CmpItemKindCopilot"
            elseif entry.source.name == "codeium" then
              vim_item.kind = "Codeium"
              vim_item.kind_hl_group = "CmpItemKindCodeium"
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

      -- Ensure AI highlight groups are set
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644", bold = true })
          vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#09B6A2", bold = true })
        end,
      })

      -- Provide additional visual feedback with ghost text
      cmp.setup({
        experimental = { ghost_text = { hl_group = "Comment" } },
        view = { entries = { name = "custom", selection_order = "near_cursor" } },
      })
    end,
  },
}
