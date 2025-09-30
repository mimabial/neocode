return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  keys = {
    {
      "<leader>sR",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end,
      mode = { "n", "v" },
      desc = "Search and Replace",
    },
    {
      "<leader>sr",
      function()
        local path = vim.fn.expand("%")
        require("grug-far").open({
          prefills = { paths = string.format('"%s"', path) }
        })
      end,
      desc = "Search and Replace (Current File)",
    },
    {
      "<leader>sW",
      function()
        require("grug-far").open({
          prefills = { search = vim.fn.expand("<cword>") }
        })
      end,
      desc = "Search Word Under Cursor",
    },
    {
      "<leader>sw",
      function()
        local path = vim.fn.expand("%")
        require("grug-far").open({
          prefills = {
            search = vim.fn.expand("<cword>"),
            paths = string.format('"%s"', path)
          }
        })
      end,
      desc = "Search Word (Current File)",
    },
    {
      "<leader>si",
      function()
        require("grug-far").open({ visualSelectionUsage = "operate-within-range" })
      end,
      mode = { "n", "x" },
      desc = "Search Within Range",
    },
    {
      "<leader>sb",
      function()
        local search = vim.fn.getreg("/")
        if search and vim.startswith(search, "\\<") and vim.endswith(search, "\\>") then
          search = "\\b" .. search:sub(3, -3) .. "\\b"
        end
        require("grug-far").open({ prefills = { search = search } })
      end,
      desc = "Search Last Pattern",
    },
  },
  config = function()
    require("grug-far").setup({
      -- Minimal config - grug-far has sensible defaults
      headerMaxWidth = 80,
    })

    -- Add q to close grug-far buffers (same as spectre behavior)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "grug-far",
      callback = function(event)
        vim.keymap.set("n", "q", "<cmd>close<CR>", {
          buffer = event.buf,
          noremap = true,
          silent = true,
          desc = "Close Grug Far"
        })
      end,
    })
  end,
}
