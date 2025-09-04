-- lua/plugins/refactoring.lua
return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("refactoring").setup({
      prompt_func_return_type = {
        go = true,
        typescript = true,
        javascript = true,
      },
      prompt_func_param_type = {
        go = true,
        typescript = true,
        javascript = true,
      },
      printf_statements = {
        go = { 'fmt.Printf("%v\\n", %s)' },
      },
      print_var_statements = {
        go = { 'fmt.Printf("%v: %%+v\\n", %s)' },
        typescript = { 'console.log("%s:", %s)' },
        javascript = { 'console.log("%s:", %s)' },
      },
    })

    -- Load refactoring Telescope extension
    require("telescope").load_extension("refactoring")

    -- Remaps for the refactoring operations
    vim.api.nvim_set_keymap(
      "v",
      "<leader>rr",
      "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
      { noremap = true, desc = "Refactoring menu" }
    )

    -- Extract function supports both normal and visual mode
    vim.api.nvim_set_keymap(
      "n",
      "<leader>re",
      ":lua require('refactoring').refactor('Extract Function')<CR>",
      { noremap = true, desc = "Extract function" }
    )
    vim.api.nvim_set_keymap(
      "v",
      "<leader>re",
      ":lua require('refactoring').refactor('Extract Function')<CR>",
      { noremap = true, desc = "Extract function" }
    )

    -- Extract variable supports only visual mode
    vim.api.nvim_set_keymap(
      "v",
      "<leader>rv",
      ":lua require('refactoring').refactor('Extract Variable')<CR>",
      { noremap = true, desc = "Extract variable" }
    )

    -- Inline variable supports only normal mode
    vim.api.nvim_set_keymap(
      "n",
      "<leader>ri",
      ":lua require('refactoring').refactor('Inline Variable')<CR>",
      { noremap = true, desc = "Inline variable" }
    )

    -- Add filetype-specific keys
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "go", "typescript", "javascript", "typescriptreact", "javascriptreact" },
      callback = function()
        -- Debug print statements
        vim.api.nvim_buf_set_keymap(
          0,
          "n",
          "<leader>rp",
          ":lua require('refactoring').debug_print()<CR>",
          { noremap = true, desc = "Debug print" }
        )
        vim.api.nvim_buf_set_keymap(
          0,
          "v",
          "<leader>rp",
          ":lua require('refactoring').debug_print()<CR>",
          { noremap = true, desc = "Debug print" }
        )
        -- Remove debug print statements
        vim.api.nvim_buf_set_keymap(
          0,
          "n",
          "<leader>rc",
          ":lua require('refactoring').debug_cleanup()<CR>",
          { noremap = true, desc = "Clean debug prints" }
        )
      end,
    })

    -- Update which-key with refactoring descriptions
    local which_key_ok, which_key = pcall(require, "which-key")
    if which_key_ok then
      which_key.register({
        ["<leader>r"] = { name = "Refactoring" },
        ["<leader>rr"] = { desc = "Refactoring menu" },
        ["<leader>re"] = { desc = "Extract function" },
        ["<leader>rv"] = { desc = "Extract variable" },
        ["<leader>ri"] = { desc = "Inline variable" },
        ["<leader>rp"] = { desc = "Debug print" },
        ["<leader>rc"] = { desc = "Clean debug prints" },
      })
    end
  end,
}
