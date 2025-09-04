return {
  "Exafunction/codeium.nvim",
  cmd = "Codeium",
  event = "InsertEnter",
  dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
  config = function()
    require("codeium").setup({
      enable_chat = true,
    })

    -- Get current settings from shared system
    local current_settings = _G.ai_provider_settings or {}

    -- Enable if active provider, otherwise disable
    if current_settings.active_provider == "codeium" then
      vim.defer_fn(function()
        if _G.set_ai_provider then
          _G.set_ai_provider("codeium")
        end
      end, 100)
    else
      vim.defer_fn(function()
        vim.cmd("Codeium Disable")
      end, 100)
    end

    -- Codeium keymaps
    local keymaps = {
      ["<C-g>"] = {
        function() return require("codeium").complete() end,
        "Accept suggestion",
      },
      ["<C-;>"] = {
        function() return require("codeium").cycle_completions(1) end,
        "Next completion",
      },
      ["<C-,>"] = {
        function() return require("codeium").cycle_completions(-1) end,
        "Prev completion",
      },
      ["<C-x>"] = {
        function() return require("codeium").clear() end,
        "Clear suggestions",
      },
    }

    for key, mapping in pairs(keymaps) do
      vim.keymap.set("i", key, mapping[1], { expr = true, desc = "Codeium: " .. mapping[2] })
    end
  end,
}
