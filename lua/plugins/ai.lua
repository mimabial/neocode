-- AI Provider registry
local providers = {
  codeium = {
    name = "Codeium",
    icon = "󰚩",
    free = true,
    default = true,
  },
  copilot = {
    name = "GitHub Copilot",
    icon = "",
    free = true, -- has free tier
    default = false,
  },
}

-- Settings file path
local settings_file = vim.fn.stdpath("data") .. "/ai_provider_settings.json"

-- Load persistent settings
local function load_settings()
  local default_settings = {}
  for name, provider in pairs(providers) do
    default_settings[name] = provider.default or false
  end

  if vim.fn.filereadable(settings_file) == 0 then
    return default_settings
  end

  local content = vim.fn.readfile(settings_file)
  if #content == 0 then
    return default_settings
  end

  local ok, parsed = pcall(vim.fn.json_decode, table.concat(content, ""))
  if not ok or type(parsed) ~= "table" then
    return default_settings
  end

  -- Merge with defaults to handle new providers
  for name, _ in pairs(providers) do
    if parsed[name] == nil then
      parsed[name] = default_settings[name]
    end
  end

  return parsed
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

-- Get active provider
local function get_active_provider()
  for name, enabled in pairs(current_settings) do
    if enabled then
      return name
    end
  end
  return nil
end

-- Update global variables for statusline
local function update_globals()
  -- Set global variables that statusline checks
  vim.g.ai_provider_active = get_active_provider()
  vim.g.copilot_enabled = current_settings.copilot and 1 or 0
  vim.g.codeium_enabled = current_settings.codeium or false

  -- Trigger User event for statusline refresh
  vim.api.nvim_exec_autocmds("User", { pattern = "AIProviderChanged" })

  -- Refresh statusline if lualine is loaded
  if package.loaded["lualine"] then
    require("lualine").refresh()
  end
end

-- Set active provider (disable all others)
local function set_active_provider(provider_name)
  if not providers[provider_name] then
    vim.notify("Unknown AI provider: " .. provider_name, vim.log.levels.ERROR)
    return false
  end

  -- Disable all providers
  for name, _ in pairs(current_settings) do
    current_settings[name] = false
  end

  -- Enable the selected one
  current_settings[provider_name] = true

  -- Save settings
  save_settings(current_settings)

  -- Update globals and refresh statusline
  update_globals()

  -- Notify user
  local provider = providers[provider_name]
  vim.notify(provider.icon .. " " .. provider.name .. " enabled", vim.log.levels.INFO, { title = "AI Provider" })

  return true
end

-- Toggle specific provider
local function toggle_provider(provider_name)
  if not providers[provider_name] then
    vim.notify("Unknown AI provider: " .. provider_name, vim.log.levels.ERROR)
    return
  end

  local currently_active = get_active_provider()

  if currently_active == provider_name then
    -- Disable current provider
    current_settings[provider_name] = false
    save_settings(current_settings)
    update_globals()
    vim.notify("AI assistance disabled", vim.log.levels.INFO, { title = "AI Provider" })
  else
    -- Enable this provider (disables others)
    set_active_provider(provider_name)
  end
end

-- Cycle through providers
local function cycle_providers()
  local provider_names = vim.tbl_keys(providers)
  table.sort(provider_names) -- Consistent order

  local current = get_active_provider()
  local current_idx = 0

  -- Find current provider index
  for i, name in ipairs(provider_names) do
    if name == current then
      current_idx = i
      break
    end
  end

  -- Get next provider
  local next_idx = (current_idx % #provider_names) + 1
  local next_provider = provider_names[next_idx]

  set_active_provider(next_provider)
end

-- Create commands and keymaps
local function setup_commands()
  -- Individual toggle commands
  for name, provider in pairs(providers) do
    local cmd_name = "AI" .. provider.name:gsub("%s+", "")
    vim.api.nvim_create_user_command(cmd_name, function()
      toggle_provider(name)
    end, { desc = "Toggle " .. provider.name })
  end

  -- Cycle command
  vim.api.nvim_create_user_command("AICycle", cycle_providers, { desc = "Cycle AI providers" })

  -- Status command
  vim.api.nvim_create_user_command("AIStatus", function()
    local active = get_active_provider()
    if active then
      local provider = providers[active]
      vim.notify(provider.icon .. " Active: " .. provider.name, vim.log.levels.INFO, { title = "AI Provider" })
    else
      vim.notify("No AI provider active", vim.log.levels.INFO, { title = "AI Provider" })
    end
  end, { desc = "Show active AI provider" })

  -- Keymaps
  vim.keymap.set("n", "<leader>ua", cycle_providers, { desc = "Cycle AI providers" })
  vim.keymap.set("n", "<leader>uc", function()
    toggle_provider("copilot")
  end, { desc = "Toggle Copilot" })
  vim.keymap.set("n", "<leader>ui", function()
    toggle_provider("codeium")
  end, { desc = "Toggle Codeium" })
end

-- Initialize globals on startup
update_globals()
setup_commands()

-- Plugin configurations
return {
  -- GitHub Copilot
  {
    "zbirenbaum/copilot.lua",
    enabled = function()
      return current_settings.copilot
    end,
    cmd = "Copilot",
    event = "InsertEnter",
    dependencies = { "zbirenbaum/copilot-cmp" },
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
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
        enabled = true,
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

      -- Highlight setup
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          local colors = _G.get_ui_colors()
          vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = colors.gray, italic = true })
        end,
      })
    end,
  },

  -- Copilot CMP
  {
    "zbirenbaum/copilot-cmp",
    enabled = function()
      return current_settings.copilot
    end,
    dependencies = { "zbirenbaum/copilot.lua", "hrsh7th/nvim-cmp" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- Codeium
  {
    "Exafunction/codeium.nvim",
    enabled = function()
      return current_settings.codeium
    end,
    cmd = "Codeium",
    event = "InsertEnter",
    dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
    config = function()
      require("codeium").setup({
        enable_chat = true,
      })

      -- Keymaps
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

      -- Highlight setup
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          local colors = _G.get_ui_colors()
          vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = colors.gray, italic = true })
          vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#09B6A2" })
        end,
      })
    end,
  },
}
