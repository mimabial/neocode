return {
  "folke/which-key.nvim",
  event = "UIEnter",
  priority = 820,
  config = function()
    local ok, which_key = pcall(require, "which-key")
    if not ok then
      vim.notify("[Error] which-key.nvim not found", vim.log.levels.WARN)
      return
    end

    which_key.setup({
      win = { title = false },
      filter = function(mapping)
        return (mapping.desc and mapping.desc ~= "") or (mapping.group and mapping.group ~= "")
      end,
      show_help = false,
      show_keys = false,
      disable = {
        bt = {},
        ft = { "TelescopePrompt", "TelescopeResults", "neo-tree", "lazy" },
      },
    })

    which_key.add({
      { "<leader>a", group = "Avante" },
      { "<leader>ai", group = "AI (NeoCodeium)" },
      { "<leader>b", group = "Buffers" },
      { "<leader>c", group = "Code/LSP" },
      { "<leader>d", group = "Debug" },
      { "<leader>f", group = "Find/Telescope" },
      { "<leader>fg", group = "Find Git" },
      { "<leader>g", group = "Git" },
      { "<leader>go", group = "Git Operations (Octo)" },
      { "<leader>L", group = "Layouts" },
      { "<leader>n", group = "Notifications/Navic" },
      { "<leader>q", group = "Quit" },
      { "<leader>r", group = "Refactoring" },
      { "<leader>s", group = "Search/Replace" },
      { "<leader>sc", group = "Search CWD" },
      { "<leader>sg", group = "Search Git" },
      { "<leader>sh", group = "Search Home" },
      { "<leader>t", group = "Terminal/Toggle" },
      { "<leader>u", group = "UI/Settings" },
      { "<leader>w", group = "Windows" },
      { "<leader>x", group = "Diagnostics/Trouble" },
    })

    which_key.add({
      { "<leader>aa", desc = "Ask Avante" },
      { "<leader>ae", desc = "Edit with Avante" },
      { "<leader>ar", desc = "Refresh Avante" },
    })

    for i = 1, 9 do
      which_key.add({
        { "<leader>b" .. i, desc = "Go to buffer " .. i },
      })
    end

    which_key.add({
      { "<leader>tf", desc = "Terminal (float)" },
      { "<leader>th", desc = "Terminal (horizontal)" },
      { "<leader>tv", desc = "Terminal (vertical)" },
      { "<leader>tt", desc = "Toggle Terminal" },
    })

    which_key.add({
      { "<leader>us", desc = "Cycle color scheme" },
      { "<leader>uS", desc = "Select color scheme" },
      { "<leader>uv", desc = "Cycle color variant" },
      { "<leader>uV", desc = "Select color variant" },
      { "<leader>ud", desc = "Toggle dark/light mode" },
      { "<leader>uy", desc = "Sync with system theme" },
      { "<leader>uY", desc = "Color mode status" },
      { "<leader>uz", desc = "Set system NVIM_SCHEME" },
      { "<leader>uL", desc = "List available system themes" },
    })

    which_key.add({
      { "<leader>nb", desc = "Toggle breadcrumbs" },
    })

    which_key.add({
      { "<leader>L1", desc = "Coding Layout" },
      { "<leader>L2", desc = "Terminal Layout" },
      { "<leader>L3", desc = "Writing Layout" },
      { "<leader>L4", desc = "Debug Layout" },
    })

    which_key.add({
      { "<leader>ca", desc = "Code Action" },
      { "<leader>cd", desc = "Show Diagnostics" },
      { "<leader>cf", desc = "Format" },
      { "<leader>cr", desc = "Rename Symbol" },
      { "<leader>cs", desc = "Symbols (Trouble)" },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        which_key.add({
          { "gd", desc = "Go to Definition", buffer = args.buf },
          { "gD", desc = "Go to Declaration", buffer = args.buf },
          { "gi", desc = "Go to Implementation", buffer = args.buf },
          { "gr", desc = "Find References", buffer = args.buf },
          { "K", desc = "Hover Documentation", buffer = args.buf },
          { "<C-k>", desc = "Signature Help", buffer = args.buf },
          { "[d", desc = "Previous Diagnostic", buffer = args.buf },
          { "]d", desc = "Next Diagnostic", buffer = args.buf },
        })
      end,
    })
  end,
}
