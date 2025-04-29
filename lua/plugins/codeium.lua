return {
  "Exafunction/codeium.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  event = { "BufReadPost", "BufNewFile" },
  cmd = "Codeium",
  build = ":Codeium Auth",
  opts = {
    filetypes = {
      ["neo-tree"] = false,
      TelescopePrompt = false,
      dashboard = false,
      alpha = false,
      lazy = false,
      oil = false,
    },
    tools = {
      path_deny_list = {
        "oil://*",
      },
    },
  },
  config = function(_, opts)
    require("codeium").setup(opts)

    local has_cmp, cmp = pcall(require, "cmp")
    if has_cmp then
      local cmp_config = cmp.get_config()
      table.insert(cmp_config.sources, {
        name = "codeium",
        group_index = 1,
        priority = 100,
      })
      cmp.setup(cmp_config)
    end

    vim.keymap.set("i", "<C-g>", function()
      return vim.fn["codeium#Accept"]()
    end, { expr = true, silent = true })

    vim.keymap.set("i", "<C-;>", function()
      return vim.fn 
    end, { expr = true, silent = true })

    vim.keymap.set("i", "<C-,>", function()
      return vim.fn["codeium#CycleCompletions"](-1)
    end, { expr = true, silent = true })

    vim.keymap.set("i", "<C-x>", function()
      return vim.fn["codeium#Clear"]()
    end, { expr = true, silent = true })

    vim.api.nvim_create_user_command("CodeiumToggle", function()
      if vim.g.codeium_enabled then
        vim.cmd("CodeiumDisable")
        vim.notify("Codeium disabled", vim.log.levels.INFO)
      else
        vim.cmd("CodeiumEnable")
        vim.notify("Codeium enabled", vim.log.levels.INFO)
      end
    end, { desc = "Toggle Codeium" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "TelescopePrompt", "neo-tree", "dashboard", "alpha", "lazy", "oil" },
      callback = function()
        vim.b.codeium_disable = true
      end,
    })
  end,
}

