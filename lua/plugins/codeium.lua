return {
  "Exafunction/codeium.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  event = "InsertEnter",
  cmd = "Codeium",
  build = ":Codeium Auth",
  opts = {
    -- No config needed for default behavior
  },
  config = function(_, opts)
    require("codeium").setup(opts)

    -- Add Codeium as a source to nvim-cmp
    local has_cmp, cmp = pcall(require, "cmp")
    if has_cmp then
      -- Get the current cmp config
      local cmp_config = cmp.get_config()
      -- Add codeium as a source
      table.insert(cmp_config.sources, {
        name = "codeium",
        group_index = 1,
        priority = 100,
      })
      -- Set up the modified config
      cmp.setup(cmp_config)
    end

    -- Set up keymaps for Codeium
    vim.keymap.set("i", "<C-g>", function()
      return vim.fn["codeium#Accept"]()
    end, { expr = true, silent = true })
    vim.keymap.set("i", "<C-;>", function()
      return vim.fn["codeium#CycleCompletions"](1)
    end, { expr = true, silent = true })
    vim.keymap.set("i", "<C-,>", function()
      return vim.fn["codeium#CycleCompletions"](-1)
    end, { expr = true, silent = true })
    vim.keymap.set("i", "<C-x>", function()
      return vim.fn["codeium#Clear"]()
    end, { expr = true, silent = true })

    -- Add commands to toggle Codeium
    vim.api.nvim_create_user_command("CodeiumToggle", function()
      if vim.g.codeium_enabled == true then
        vim.cmd("CodeiumDisable")
        vim.notify("Codeium disabled", vim.log.levels.INFO)
      else
        vim.cmd("CodeiumEnable")
        vim.notify("Codeium enabled", vim.log.levels.INFO)
      end
    end, { desc = "Toggle Codeium" })

    -- Disable Codeium in certain filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "TelescopePrompt", "neo-tree", "dashboard", "alpha", "lazy" },
      callback = function()
        vim.b.codeium_enabled = false
      end,
    })
  end,
}
