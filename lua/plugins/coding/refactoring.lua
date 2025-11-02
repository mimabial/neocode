return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  keys = {
    {
      "<leader>sh",
      function()
        require("grug-far").open({
          transient = true,
          prefills = require("grug-far").get_last_search(),
        })
      end,
      desc = "Resume last search",
    },
    {
      "<leader>sr",
      function()
        require("grug-far").open({
          transient = true,
          prefills = { paths = vim.fn.expand("%:p") },
        })
      end,
      desc = "Search and Replace (Current File)",
    },
    {
      "<leader>sR",
      function()
        require("grug-far").open({
          transient = true,
        })
      end,
      desc = "Search and Replace (Project)",
    },
    {
      "<leader>sw",
      function()
        require("grug-far").open({
          transient = true,
          prefills = {
            search = vim.fn.expand("<cword>"),
            paths = vim.fn.expand("%:p"),
          },
        })
      end,
      desc = "Search Word (Current File)",
    },
    {
      "<leader>sw",
      mode = "v",
      function()
        require("grug-far").with_visual_selection({
          transient = true,
          prefills = { paths = vim.fn.expand("%:p") },
        })
      end,
      desc = "Search Selection (Current File)",
    },
    {
      "<leader>sW",
      function()
        require("grug-far").open({
          transient = true,
          prefills = { search = vim.fn.expand("<cword>") },
        })
      end,
      desc = "Search Word (Project)",
    },
    {
      "<leader>sW",
      mode = "v",
      function()
        require("grug-far").with_visual_selection({
          transient = true,
        })
      end,
      desc = "Search Selection (Project)",
    },
  },

  opts = {
    windowCreationCommand = "vsplit",
    startInInsertMode = false,
    icons = { enabled = false },
    engines = {
      ripgrep = {
        placeholders = {
          enabled = false, -- Removes all placeholder text
        },
      },
    },
  },

  config = function(_, opts)
    require("grug-far").setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "grug-far",
      callback = function()
        local width = vim.o.columns < 120 and vim.o.columns or math.min(math.floor(vim.o.columns * 0.5), 120)
        vim.cmd("vertical resize " .. width)

        -- vim.opt_local.number = false
        -- vim.opt_local.relativenumber = true
        -- vim.opt_local.signcolumn = "no"
        -- vim.opt_local.cursorline = true

        local bufnr = vim.api.nvim_get_current_buf()
        vim.keymap.set("n", "r", "<localleader>r", { buffer = bufnr, remap = true, desc = "Replace current" })
        vim.keymap.set("n", "n", "<down>", { buffer = bufnr, remap = true, desc = "Next result" })
        vim.keymap.set("n", "N", "<up>", { buffer = bufnr, remap = true, desc = "Previous result" })
        vim.keymap.set("n", "q", "<localleader>c", { buffer = bufnr, remap = true, desc = "Close" })
        vim.keymap.set("n", "<ESC>", "<localleader>c", { buffer = bufnr, remap = true, desc = "Close" })

        vim.keymap.set("n", "tc", function()
          require("grug-far").get_instance(0):toggle_flags({ "--ignore-case" })
        end, { buffer = bufnr, desc = "Toggle case sensitivity" })

        vim.keymap.set("n", "ti", function()
          local instance = require("grug-far").get_instance(0)
          instance:toggle_flags({ "--no-ignore" })
        end, { buffer = bufnr, desc = "Toggle gitignore" })

        vim.keymap.set("n", "th", function()
          local instance = require("grug-far").get_instance(0)
          instance:toggle_flags({ "--hidden" })
        end, { buffer = bufnr, desc = "Toggle hidden files" })
      end,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
      callback = function()
        vim.schedule(function()
          local wins = vim.api.nvim_list_wins()
          if #wins == 1 then
            local buf = vim.api.nvim_win_get_buf(wins[1])
            if vim.bo[buf].filetype == "grug-far" then
              vim.cmd("quit")
            end
          end
        end)
      end,
    })
  end,
}
