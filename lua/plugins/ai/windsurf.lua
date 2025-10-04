return {
  "Exafunction/windsurf.nvim",
  cmd = "Codeium",
  event = "InsertEnter",
  dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
  config = function()
    require("codeium").setup({
      enable_chat = true,
    })

    -- Disable Codeium in special buffers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "spectre_panel", "TelescopePrompt", "oil" },
      callback = function()
        vim.b.codeium_enabled = false
      end,
    })

    vim.keymap.set("i", "<C-g>", function()
      return require("codeium").complete()
    end, { expr = true, desc = "Windsurf: Accept suggestion" })

    vim.keymap.set("i", "<C-;>", function()
      return require("codeium").cycle_completions(1)
    end, { expr = true, desc = "Windsurf: Next completion" })

    vim.keymap.set("i", "<C-,>", function()
      return require("codeium").cycle_completions(-1)
    end, { expr = true, desc = "Windsurf: Previous completion" })

    vim.keymap.set("i", "<C-x>", function()
      return require("codeium").clear()
    end, { expr = true, desc = "Windsurf: Clear suggestions" })
  end,
}
