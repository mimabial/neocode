-- lua/plugins/ai.lua
-- Enhanced AI integration for GitHub Copilot and Codeium

return {
  -- GitHub Copilot integration
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    dependencies = {
      "zbirenbaum/copilot-cmp",
      "nvim-lua/plenary.nvim",
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
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          refresh = "gr",
          open = "<M-CR>",
        },
        layout = {
          position = "bottom",
          ratio = 0.4,
        },
      },
      filetypes = {
        -- Enable for all filetypes
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
        -- Stack-specific filetypes
        go = true,
        templ = true,
        typescript = true,
        javascript = true,
        typescriptreact = true,
        javascriptreact = true,
        html = true,
        css = true,
      },
      copilot_node_command = "node",
      server_opts_overrides = {},
      ft_disable = { "markdown", "text" },
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

      -- Toggle keymap with fancy notification
      vim.keymap.set("n", "<leader>uc", function()
        local status = require("copilot.client").is_started()
        if status then
          vim.cmd("Copilot disable")
          vim.notify(" Copilot disabled", vim.log.levels.INFO, { title = "Copilot" })
        else
          vim.cmd("Copilot enable")
          vim.notify(" Copilot enabled", vim.log.levels.INFO, { title = "Copilot" })
        end
      end, { desc = "Toggle Copilot" })

      -- Filetype-specific keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go", "templ", "typescript", "javascript", "typescriptreact", "javascriptreact" },
        callback = function(event)
          -- Local buffer keymap for revealing panel
          vim.keymap.set("i", "<C-A-p>", function()
            vim.cmd("Copilot panel")
          end, { buffer = event.buf, desc = "Copilot Panel" })
        end,
      })
    end,
  },

  -- Copilot CMP integration
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    event = "InsertEnter",
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
      event_type = "confirm_done",
    },
    config = function(_, opts)
      local copilot_cmp = require("copilot_cmp")
      copilot_cmp.setup(opts)

      -- Add custom formatting for better Copilot suggestions display
      if require("cmp.config").get().formatting then
        local format_kinds = require("cmp.config").get().formatting.format
        require("cmp.config").set({
          formatting = {
            format = function(entry, item)
              if format_kinds then
                format_kinds(entry, item)
              end

              -- Add symbol for Copilot
              if entry.source.name == "copilot" then
                item.kind = "Copilot"
                item.kind_hl_group = "CmpItemKindCopilot"
              end

              return item
            end,
          },
        })
      end
    end,
  },

  -- Codeium integration (as fallback if Copilot unavailable)
  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    cmd = "Codeium",
    event = "InsertEnter",
    build = ":Codeium Auth",
    enabled = function()
      -- Disable Codeium if Copilot is active
      return not require("lazy.core.config").plugins["copilot.lua"]._.loaded
    end,
    opts = {
      enable_chat = false,
      tools = {
        language_server = {
          enabled = true,
        },
        path_deny_list = { "oil://*" },
      },
      filetypes = {
        ["*"] = true,
        TelescopePrompt = false,
        ["neo-tree"] = false,
        lazy = false,
        ["neo-tree-popup"] = false,
        ["oil"] = false,
      },
    },
    config = function(_, opts)
      require("codeium").setup(opts)

      -- Highlight group for Codeium
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = "#928374", italic = true })
          vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#09B6A2", bold = true })
        end,
      })

      -- Register toggle keybinding
      vim.keymap.set("n", "<leader>ui", function()
        if vim.g.codeium_enabled then
          vim.cmd("CodeiumDisable")
          vim.notify("󰧑 Codeium disabled", vim.log.levels.INFO, { title = "Codeium" })
        else
          vim.cmd("CodeiumEnable")
          vim.notify("󰧑 Codeium enabled", vim.log.levels.INFO, { title = "Codeium" })
        end
      end, { desc = "Toggle Codeium" })

      -- Insert mode keymaps
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

  -- Enhanced completion integration for AI tools
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      -- Enhanced completion sources with AI prioritization
      local sources = opts.sources
        or {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }

      -- Add AI sources at the top if available
      if require("lazy.core.config").spec.plugins["copilot-cmp"] then
        table.insert(sources, 1, {
          name = "copilot",
          group_index = 1,
          priority = 100,
        })
      end

      if require("lazy.core.config").spec.plugins["codeium.nvim"] then
        table.insert(sources, 1, {
          name = "codeium",
          group_index = 1,
          priority = 90,
        })
      end

      -- Custom AI priority comparator
      local function ai_priority(entry1, entry2)
        local name1, name2 = entry1.source.name, entry2.source.name
        local p1 = name1 == "copilot" and 100 or (name1 == "codeium" and 90 or 0)
        local p2 = name2 == "copilot" and 100 or (name2 == "codeium" and 90 or 0)
        if p1 ~= p2 then
          return p1 > p2
        end
      end

      -- Add AI priority to comparators
      if opts.sorting and opts.sorting.comparators then
        table.insert(opts.sorting.comparators, 1, ai_priority)
      end

      -- Return enhanced options
      return vim.tbl_deep_extend("force", opts, {
        sources = sources,
        sorting = {
          priority_weight = 2,
          comparators = opts.sorting and opts.sorting.comparators or {
            ai_priority,
            require("cmp.config.compare").offset,
            require("cmp.config.compare").exact,
            require("cmp.config.compare").score,
            require("cmp.config.compare").recently_used,
            require("cmp.config.compare").locality,
            require("cmp.config.compare").kind,
            require("cmp.config.compare").sort_text,
            require("cmp.config.compare").length,
            require("cmp.config.compare").order,
          },
        },
      })
    end,
  },

  -- Custom key binding helper
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      defaults = {
        ["<leader>u"] = { name = "+UI/AI" },
        ["<leader>uc"] = { "Toggle Copilot" },
        ["<leader>ui"] = { "Toggle Codeium" },
      },
    },
  },
}
