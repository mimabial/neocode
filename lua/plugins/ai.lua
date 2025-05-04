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
      -- Safely load copilot with error handling
      local ok, copilot = pcall(require, "copilot")
      if not ok then
        vim.notify("Failed to load Copilot: " .. tostring(copilot), vim.log.levels.WARN)
        return
      end

      -- Try to setup copilot with error handling
      local setup_ok, err = pcall(function()
        copilot.setup(opts)
      end)

      if not setup_ok then
        vim.notify("Copilot setup failed: " .. tostring(err), vim.log.levels.WARN)
      end

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

      -- Toggle keymap with fancy notification and status check
      vim.keymap.set("n", "<leader>uc", function()
        local status_ok, status = pcall(function()
          return require("copilot.client").is_started()
        end)

        if not status_ok then
          vim.notify("Could not check Copilot status", vim.log.levels.WARN)
          return
        end

        if status then
          -- Try to disable with error handling
          pcall(vim.api.nvim_command, "Copilot disable")
          vim.notify(" Copilot disabled", vim.log.levels.INFO, { title = "Copilot" })
        else
          -- Try to enable with error handling
          pcall(vim.api.nvim_command, "Copilot enable")
          vim.notify(" Copilot enabled", vim.log.levels.INFO, { title = "Copilot" })
        end
      end, { desc = "Toggle Copilot" })
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
      -- Safe loading
      local ok, copilot_cmp = pcall(require, "copilot_cmp")
      if not ok then
        vim.notify("Failed to load copilot-cmp", vim.log.levels.WARN)
        return
      end

      -- Setup with error handling
      local setup_ok, err = pcall(function()
        copilot_cmp.setup(opts)
      end)

      if not setup_ok then
        vim.notify("copilot-cmp setup failed: " .. tostring(err), vim.log.levels.WARN)
      end
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
      -- Safe loading
      local ok, codeium = pcall(require, "codeium")
      if not ok then
        vim.notify("Failed to load Codeium", vim.log.levels.WARN)
        return
      end

      -- Setup with error handling
      local setup_ok, err = pcall(function()
        codeium.setup({})
      end)

      if not setup_ok then
        vim.notify("Codeium setup failed: " .. tostring(err), vim.log.levels.WARN)
      end

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

      -- Toggle Codeium on/off with error handling
      vim.keymap.set("n", "<leader>ui", function()
        local toggle_ok = pcall(vim.api.nvim_command, "Codeium Toggle")
        if not toggle_ok then
          vim.notify("Failed to toggle Codeium", vim.log.levels.WARN)
        end
      end, { desc = "Toggle Codeium" })

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
      -- Safe loading
      local cmp_ok, cmp = pcall(require, "cmp")
      if not cmp_ok then
        vim.notify("Failed to load nvim-cmp", vim.log.levels.ERROR)
        return
      end

      local luasnip_ok, luasnip = pcall(require, "luasnip")
      if not luasnip_ok then
        vim.notify("Failed to load LuaSnip", vim.log.levels.WARN)
        -- Continue anyway, we'll handle the missing dependency
      end

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

      -- Build sources list dynamically and safely
      local sources = {
        { name = "copilot", group_index = 1, priority = 100 }, -- Highest priority
        { name = "codeium", group_index = 1, priority = 95 }, -- Fallback AI
        { name = "nvim_lsp", group_index = 1, priority = 90 }, -- LSP comes after AI
        { name = "luasnip", group_index = 1, priority = 80 },
        { name = "buffer", group_index = 2, priority = 70, keyword_length = 3 },
        { name = "path", group_index = 2, priority = 60 },
      }

      -- Check if sources exist before using them
      local final_sources = {}
      for _, source in ipairs(sources) do
        local available = true
        if source.name == "copilot" and not package.loaded["copilot_cmp"] then
          available = pcall(require, "copilot_cmp")
        elseif source.name == "codeium" and not package.loaded["codeium"] then
          available = pcall(require, "codeium")
        elseif source.name == "luasnip" and not luasnip_ok then
          available = false
        end

        if available then
          table.insert(final_sources, source)
        end
      end

      -- Special window with highlights for completion
      local winhl = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None"

      -- Configure with AI-friendly settings
      local config = {
        completion = {
          completeopt = "menu,menuone,noinsert",
          autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
        },
        snippet = {
          expand = function(args)
            if luasnip_ok then
              luasnip.lsp_expand(args.body)
            end
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
            elseif luasnip_ok and luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip_ok and luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources(final_sources),
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
              vim_item.menu = source_names[entry.source.name] or ("[" .. entry.source.name .. "]")
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
      }

      -- Setup with error handling
      local setup_ok, err = pcall(function()
        cmp.setup(config)
      end)

      if not setup_ok then
        vim.notify("nvim-cmp setup failed: " .. tostring(err), vim.log.levels.ERROR)
        return
      end

      -- Cmdline completions
      pcall(function()
        cmp.setup.cmdline(":", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
        })

        cmp.setup.cmdline("/", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = { { name = "buffer" } },
        })
      end)

      -- Ensure AI highlight groups are set
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644", bold = true })
          vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#09B6A2", bold = true })
        end,
      })

      -- Provide additional visual feedback with ghost text
      pcall(function()
        cmp.setup({
          experimental = { ghost_text = { hl_group = "Comment" } },
          view = { entries = { name = "custom", selection_order = "near_cursor" } },
        })
      end)
    end,
  },
}
