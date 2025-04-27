return {
  "Exafunction/codeium.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  event = "InsertEnter",
  cmd = { "Codeium", "CodeiumAuth", "CodeiumEnable", "CodeiumDisable" },
  keys = {
    -- Keys are now managed in the which-key.lua file for better organization
  },
  config = function()
    require("codeium").setup({
      tools = {
        language_server = {
          -- Customize LSP settings if needed
          -- hover_context_enabled = true,
        },
      },
      bin_path = vim.fn.stdpath("data") .. "/codeium", -- Path for the binary
    })

    -- Add Codeium source to nvim-cmp
    local has_cmp, cmp = pcall(require, "cmp")
    if has_cmp then
      -- Get the current config
      local config = cmp.get_config()
      table.insert(config.sources, { name = "codeium", priority = 1000 }) -- High priority
      cmp.setup(config)
    end

    -- Set up autocommands for better Codeium integration
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "TelescopePrompt", "neo-tree", "dashboard", "alpha", "lazy" },
      callback = function()
        -- Disable Codeium in these filetypes
        vim.b.codeium_enabled = false
      end,
    })
  end,
}
