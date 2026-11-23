return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    panel = { enabled = false },
    suggestion = {
      auto_trigger = true,
      debounce = 100,
    },
    filetypes = { ["*"] = true, TelescopePrompt = false, bigfile = false, oil = false },
  },
}
