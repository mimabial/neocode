return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  keys = {
    {
      "<leader>sr",
      function()
        require("spectre").open()
      end,
      desc = "Replace in files (Spectre)",
    },
  },
  opts = {
    open_cmd = "noswapfile vnew",
  },
  config = function(_, opts)
    require("spectre").setup(opts)

    -- Add q to close spectre buffers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "spectre_panel",
      callback = function(event)
        vim.keymap.set("n", "q", "<cmd>close<CR>", {
          buffer = event.buf,
          noremap = true,
          silent = true,
          desc = "Close Spectre"
        })
      end,
    })
  end,
}
