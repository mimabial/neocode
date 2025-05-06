-- lua/plugins/ai.lua
-- Enhanced AI integration with consistent UI styling for both Copilot and Codeium

return {
  -- GitHub Copilot integration
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    dependencies = {
      "zbirenbaum/copilot-cmp", -- For completion menu integration
    },
    opts = function()
      -- Get UI config if available
      local ui_config = _G.get_ui_config and _G.get_ui_config() or {}

      return {
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
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4,
          },
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
      }
    end,
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

      -- Get colors from central UI config if available
      local get_colors = _G.get_ui_colors
        or function()
          -- Default gruvbox-compatible colors
          return {
            bg = "#282828",
            bg1 = "#32302f",
            gray = "#928374",
            selection_bg = "#45403d",
          }
        end

      -- Highlight groups for copilot
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local colors = get_colors()

          -- Set highlight groups compatible with the current theme
          vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = colors.gray, italic = true })
          vim.api.nvim_set_hl(0, "CopilotAnnotation", { fg = colors.gray, italic = true })
          vim.api.nvim_set_hl(
            0,
            "CopilotSuggestionActive",
            { bg = colors.bg1, fg = colors.gray, italic = true, bold = true }
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

      -- Get UI config if available
      local ui_config = _G.get_ui_config and _G.get_ui_config() or {}
      local float_config = ui_config.float or { border = "single" }

      -- Setup with error handling and UI enhancements
      local setup_ok, err = pcall(function()
        codeium.setup({
          config = {
            enable_chat = true,
            tools = {
              -- Apply UI styling from central config
              language_server = {
                enabled = true,
              },
              selector = {
                enabled = true,
                border = float_config.border,
                max_width = ui_config.float and ui_config.float.max_width or 80,
              },
            },
          },
        })
      end)

      if not setup_ok then
        vim.notify("Codeium setup failed: " .. tostring(err), vim.log.levels.WARN)
      end

      -- Ensure Codeium is enabled by default
      if vim.g.codeium_enabled == nil then
        vim.g.codeium_enabled = true
      end

      -- Get colors function from UI module or fallback
      local get_colors = _G.get_ui_colors or function()
        return {
          gray = "#928374",
        }
      end

      -- Highlight groups for suggestions
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local colors = get_colors()
          vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = colors.gray, italic = true })
          vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#09B6A2" })
        end,
      })

      -- Toggle Codeium on/off with error handling
      vim.keymap.set("n", "<leader>ui", function()
        local toggle_ok = pcall(vim.api.nvim_command, "CodeiumToggle")
        if not toggle_ok then
          vim.notify("Failed to toggle Codeium", vim.log.levels.WARN)
        end
      end, { desc = "Toggle Codeium" })

      -- Insert-mode keymaps
      local keymaps = {
        ["<C-g>"] = {
          function()
            -- Updated to use the correct API function with additional safety checks
            local codeium = require("codeium")
            if codeium and codeium.complete then
              return codeium.complete()
            end
            return ""
          end,
          "Accept suggestion",
        },
        ["<C-;>"] = {
          function()
            local codeium = require("codeium")
            if codeium and codeium.cycle_completions then
              return codeium.cycle_completions(1)
            end
            return ""
          end,
          "Next completion",
        },
        ["<C-,>"] = {
          function()
            local codeium = require("codeium")
            if codeium and codeium.cycle_completions then
              return codeium.cycle_completions(-1)
            end
            return ""
          end,
          "Prev completion",
        },
        ["<C-x>"] = {
          function()
            local codeium = require("codeium")
            if codeium and codeium.clear then
              return codeium.clear()
            end
            return ""
          end,
          "Clear suggestions",
        },
      }

      for key, mapping in pairs(keymaps) do
        vim.keymap.set("i", key, mapping[1], { expr = true, desc = "Codeium: " .. mapping[2] })
      end
    end,
  },
}
