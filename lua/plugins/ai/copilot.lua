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
  vim.g.ai_provider_active = current_settings.active_provider
  vim.api.nvim_exec_autocmds("User", { pattern = "AIProviderChanged" })
  if package.loaded["lualine"] then
    require("lualine").refresh()
  end
end

local function disable_ai_providers()
  current_settings.active_provider = nil
  pcall(function() vim.cmd("Codeium Disable") end)
  pcall(function()
    local copilot = require("copilot.suggestion")
    if copilot.dismiss then copilot.dismiss() end
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

  if provider == "copilot" then
    pcall(function()
      require("copilot").setup({
        suggestion = { auto_trigger = true },
        panel = { enabled = true },
      })
    end)
    pcall(function() vim.cmd("Codeium Disable") end)
  elseif provider == "codeium" then
    pcall(function() vim.cmd("Codeium Enable") end)
    pcall(function()
      local copilot = require("copilot.suggestion")
      if copilot.dismiss then copilot.dismiss() end
    end)
  else
    disable_ai_providers()
    return true
  end

  local icons = { codeium = "󰚩", copilot = "" }
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

-- Setup commands
local function setup_commands()
  vim.api.nvim_create_user_command("AICopilot", function()
    local current = current_settings.active_provider
    set_active_provider(current == "copilot" and "none" or "copilot")
  end, { desc = "Toggle Copilot" })

  vim.api.nvim_create_user_command("AICodeium", function()
    local current = current_settings.active_provider
    set_active_provider(current == "codeium" and "none" or "codeium")
  end, { desc = "Toggle Codeium" })

  vim.api.nvim_create_user_command("AICycle", cycle_providers, { desc = "Cycle AI providers" })

  vim.api.nvim_create_user_command("AIStatus", function()
    local active = current_settings.active_provider
    if active then
      local icons = { codeium = "󰚩", copilot = "" }
      vim.notify(icons[active] .. " Active: " .. active, vim.log.levels.INFO, { title = "AI Provider" })
    else
      vim.notify("No AI provider active", vim.log.levels.INFO, { title = "AI Provider" })
    end
  end, { desc = "Show active AI provider" })

  vim.api.nvim_create_user_command("AIDisable", disable_ai_providers, { desc = "Disable all providers" })
end

-- Initialize
update_globals()
setup_commands()

-- Export for completion
_G.get_ai_active_provider = function()
  return current_settings.active_provider
end

-- Export functions for codeium.lua to use
_G.ai_provider_settings = current_settings
_G.set_ai_provider = set_active_provider
_G.update_ai_globals = update_globals

return {
  -- Main Copilot plugin
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    dependencies = { "zbirenbaum/copilot-cmp" },
    opts = {
      suggestion = {
        enabled = false,
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
        enabled = false,
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

      -- Enable if active provider
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
}
