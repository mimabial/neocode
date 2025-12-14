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

    -- Setup which-key
    which_key.setup({
      win = {
        title = false,
      },
      -- show mappings with a description or group label
      filter = function(mapping)
        return (mapping.desc and mapping.desc ~= "") or (mapping.group and mapping.group ~= "")
      end,
      show_help = false,
      show_keys = false,
      disable = {
        bt = {}, -- options: terminal, nofile,...
        ft = { "TelescopePrompt", "TelescopeResults", "neo-tree", "lazy" },
      },
    })

    -- Group definitions using v3 API
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
      { "<leader>n", group = "Notifications" },
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

    -- Avante
    which_key.add({
      { "<leader>aa", desc = "Ask Avante" },
      { "<leader>ae", desc = "Edit with Avante" },
      { "<leader>ar", desc = "Refresh Avante" },
    })

    -- Buffer number mappings (1-9, defined in tabline.lua)
    for i = 1, 9 do
      which_key.add({
        { "<leader>b" .. i, desc = "Go to buffer " .. i },
      })
    end

    -- Note: Actual git keybindings are defined in their respective plugin files:
    -- <leader>gg  → plugins/ui/terminal.lua (LazyGit)
    -- <leader>go* → plugins/git/octo.lua (Octo commands)
    -- <leader>gh* → plugins/git/gitsigns.lua (hunk operations)
    -- <leader>fg* → plugins/search/telescope.lua (git searches)

    -- Terminal
    which_key.add({
      { "<leader>tf", desc = "Terminal (float)" },
      { "<leader>th", desc = "Terminal (horizontal)" },
      { "<leader>tv", desc = "Terminal (vertical)" },
      { "<leader>tt", desc = "Toggle Terminal" },
    })

    -- UI/Settings
    which_key.add({
      { "<leader>us", desc = "Cycle color scheme" },
      { "<leader>uS", desc = "Select color scheme" },
      { "<leader>uv", desc = "Cycle color variant" },
      { "<leader>uV", desc = "Select color variant" },
      { "<leader>ub", desc = "Toggle transparency" },
      { "<leader>uy", desc = "Sync with system theme" },
      { "<leader>uY", desc = "Detect system theme" },
      { "<leader>uz", desc = "Set system NVIM_SCHEME" },
      { "<leader>uL", desc = "List available system themes" },
    })

    -- Navic & Outline
    which_key.add({
      { "<leader>nb", desc = "Toggle dropbar" },
      { "<leader>o", desc = "Toggle outline" },
      { "]]", desc = "Next reference" },
      { "[[", desc = "Prev reference" },
    })

    -- Layouts
    which_key.add({
      { "<leader>L1", desc = "Coding Layout" },
      { "<leader>L2", desc = "Terminal Layout" },
      { "<leader>L3", desc = "Writing Layout" },
      { "<leader>L4", desc = "Debug Layout" },
    })

    -- LSP mappings
    which_key.add({
      { "<leader>ca", desc = "Code Action" },
      { "<leader>cd", desc = "Show Diagnostics" },
      { "<leader>cf", desc = "Format" },
      { "<leader>cr", desc = "Rename Symbol" },
      { "<leader>cs", desc = "Symbols (Trouble)" },
    })

    -- Trouble/Diagnostics
    which_key.add({
      { "<leader>xx", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xQ", desc = "Quickfix List (Trouble)" },
      { "<leader>xL", desc = "Location List (Trouble)" },
    })

    -- Note: Fold commands (z*) are built-in Vim commands, not custom keybindings
    -- zR = open all folds, zM = close all folds, za = toggle fold, etc.

    -- Register LSP-specific keymaps when LSP attaches
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
