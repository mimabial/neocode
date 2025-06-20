-- Settings file path
local settings_file = vim.fn.stdpath("data") .. "/ai_provider_settings.json"

-- Load persistent settings
local function load_settings()
  local default_settings = { active_provider = "codeium" }

  if vim.fn.filereadable(settings_file) == 0 then
    return default_settings
  end

  local content = vim.fn.readfile(settings_file)
  if #content == 0 then
    return default_settings
  end

  local ok, parsed = pcall(vim.fn.json_decode, table.concat(content, ""))
  return ok and parsed or default_settings
end

-- Save settings
local function save_settings(settings)
  vim.fn.mkdir(vim.fn.fnamemodify(settings_file, ":h"), "p")
  local ok, json = pcall(vim.fn.json_encode, settings)
  if not ok then
    vim.notify("Failed to encode AI provider settings", vim.log.levels.ERROR)
    return false
  end
  local success = pcall(vim.fn.writefile, { json }, settings_file)
  return success
end

-- Get current settings
local current_settings = load_settings()

-- Update global variable for statusline and completion
local function update_globals()
  -- Set global variable
  vim.g.ai_provider_active = current_settings.active_provider

  -- Trigger refresh
  vim.api.nvim_exec_autocmds("User", { pattern = "AIProviderChanged" })

  -- Refresh statusline
  if package.loaded["lualine"] then
    require("lualine").refresh()
  end
end

local function disable_ai_providers()
  current_settings.active_provider = nil
  pcall(function()
    vim.cmd("Codeium Disable")
  end)
  pcall(function()
    local copilot = require("copilot.suggestion")
    if copilot.dismiss then
      copilot.dismiss()
    end
  end)
  vim.notify("AI assistance disabled", vim.log.levels.INFO, { title = "AI Provider" })
end

local function set_active_provider(provider)
  if provider == "none" then
    current_settings.active_provider = nil
  else
    current_settings.active_provider = provider
  end

  save_settings(current_settings)
  update_globals()

  -- Control plugin fonctionnality
  if provider == "copilot" then
    pcall(function()
      require("copilot").setup({
        suggestion = { auto_trigger = true },
        panel = { enabled = true },
      })
    end)
    pcall(function()
      vim.cmd("Codeium Disable")
    end)
  elseif provider == "codeium" then
    pcall(function()
      vim.cmd("Codeium Enable")
    end)
    pcall(function()
      local copilot = require("copilot.suggestion")
      if copilot.dismiss then
        copilot.dismiss()
      end
    end)
  else
    -- Disable both
    disable_ai_providers()
    return true
  end

  -- Notify user
  local icons = { codeium = "󰚩", copilot = "" }
  local message = icons[provider] .. " " .. provider .. " enabled"
  vim.notify(message, vim.log.levels.INFO, { title = "AI Provider" })
end

local function cycle_providers()
  local providers_tbl = { "copilot", "codeium" }
  local current = current_settings.active_provider or "none"
  local current_idx = vim.tbl_contains(providers_tbl, current) and vim.fn.index(providers_tbl, current) + 1 or 1
  local next_idx = (current_idx % #providers_tbl) + 1
  set_active_provider(providers_tbl[next_idx])
end

-- Create commands and keymaps
local function setup_commands()
  -- Individual toggle commands
  vim.api.nvim_create_user_command("AICopilot", function()
    local current = current_settings.active_provider
    set_active_provider(current == "copilot" and "none" or "copilot")
  end, { desc = "Toggle Copilot" })

  vim.api.nvim_create_user_command("AICodeium", function()
    local current = current_settings.active_provider
    set_active_provider(current == "codeium" and "none" or "codeium")
  end, { desc = "Toggle Codeium" })

  -- Cycle command
  vim.api.nvim_create_user_command("AICycle", cycle_providers, { desc = "Cycle AI providers" })

  -- Status command
  vim.api.nvim_create_user_command("AIStatus", function()
    local active = current_settings.active_provider
    if active then
      local provider = providers[active]
      vim.notify(provider.icon .. " Active: " .. provider.name, vim.log.levels.INFO, { title = "AI Provider" })
    else
      vim.notify("No AI provider active", vim.log.levels.INFO, { title = "AI Provider" })
    end
  end, { desc = "Show active AI provider" })

  vim.api.nvim_create_user_command("AIDisable", disable_ai_providers, { desc = "Disable all providers" })
end

-- Initialize globals on startup
update_globals()
setup_commands()

-- Export function for completion
_G.get_ai_active_provider = function()
  return current_settings.active_provider
end

return {
  -- GitHub Copilot - always loaded but conditionally active
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    dependencies = { "zbirenbaum/copilot-cmp" },
    opts = {
      suggestion = {
        enabled = false, -- Controlled via commands
        auto_trigger = false,
        debounce = 75,
        keymap = {
          accept = "<C-g>",
          accept_word = "<M-g>",
          accept_line = "<C-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-[>",
        },
      },
      panel = {
        enabled = false, -- Controlled via commands
        auto_refresh = true,
        layout = { position = "bottom", ratio = 0.4 },
      },
      filetypes = {
        ["*"] = true,
        TelescopePrompt = false,
        oil = false,
        help = false,
        gitcommit = false,
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)

      -- Enable if it's the active provider
      if current_settings.active_provider == "copilot" then
        vim.defer_fn(function()
          set_active_provider("copilot")
        end, 100)
      end
    end,
  },

  -- Copilot CMP integration
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua", "hrsh7th/nvim-cmp" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- Codeium - always loaded but conditionally active
  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",
    event = "InsertEnter",
    dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
    config = function()
      require("codeium").setup({
        enable_chat = true,
      })

      -- Enable if it's the active provider, otherwise disable
      if current_settings.active_provider == "codeium" then
        vim.defer_fn(function()
          set_active_provider("codeium")
        end, 100)
      else
        vim.defer_fn(function()
          vim.cmd("Codeium Disable")
        end, 100)
      end

      -- Keymaps for codeium when active
      local keymaps = {
        ["<C-g>"] = {
          function()
            return require("codeium").complete()
          end,
          "Accept suggestion",
        },
        ["<C-;>"] = {
          function()
            return require("codeium").cycle_completions(1)
          end,
          "Next completion",
        },
        ["<C-,>"] = {
          function()
            return require("codeium").cycle_completions(-1)
          end,
          "Prev completion",
        },
        ["<C-x>"] = {
          function()
            return require("codeium").clear()
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
