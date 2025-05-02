-- lua/plugins/codeium.lua

return {
  "Exafunction/codeium.nvim",
  lazy = true,
  event = { "BufReadPost", "BufNewFile" },
  enabled = function()
    -- Disable Codeium if Copilot is present
    return not require("lazy.core.config").spec.plugins["copilot.lua"]
  end,
  dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
  build = ":Codeium Auth",
  opts = function()
    return {
      filetypes = {
        ["neo-tree"] = false,
        TelescopePrompt = false,
        dashboard = false,
        alpha = false,
        lazy = false,
        oil = false,
      },
      tools = {
        path_deny_list = { "oil://*" },
      },
    }
  end,
  config = function(_, opts)
    -- Setup Codeium
    local codeium = require("codeium")
    codeium.setup(opts)

    -- Integrate with nvim-cmp
    local has_cmp, cmp = pcall(require, "cmp")
    if has_cmp then
      local sources = cmp.get_config().sources or {}
      table.insert(sources, 1, { name = "codeium", group_index = 1, priority = 100 })
      cmp.setup({ sources = sources })
    end

    -- Helper for Codeium mappings
    local function map(lhs, fn)
      vim.keymap.set("i", lhs, fn, { expr = true, silent = true })
    end

    map("<C-g>", function()
      return vim.fn["codeium#Accept"]()
    end)
    map("<C-;>", function()
      return vim.fn["codeium#CycleCompletions"](1)
    end)
    map("<C-,>", function()
      return vim.fn["codeium#CycleCompletions"](-1)
    end)
    map("<C-x>", function()
      return vim.fn["codeium#Clear"]()
    end)

    -- Toggle command
    vim.api.nvim_create_user_command("CodeiumToggle", function()
      if vim.g.codeium_enabled then
        vim.cmd("CodeiumDisable")
        vim.notify("Codeium disabled", vim.log.levels.INFO)
      else
        vim.cmd("CodeiumEnable")
        vim.notify("Codeium enabled", vim.log.levels.INFO)
      end
    end, { desc = "Toggle Codeium engine" })

    -- Disable Codeium in UI filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "TelescopePrompt", "neo-tree", "dashboard", "alpha", "lazy", "oil" },
      callback = function()
        vim.b.codeium_disable = true
      end,
    })
  end,
}
