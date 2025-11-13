return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  keys = {
    {
      "<leader>sl",
      function()
        require("grug-far").toggle_instance({
          instanceName = "grug-far",
          transient = true,
          prefills = require("grug-far").get_last_search(),
        })
      end,
      desc = "Resume last search",
    },
    {
      "<leader>sr",
      function()
        require("grug-far").toggle_instance({
          instanceName = "grug-far",
          transient = true,
          prefills = { paths = vim.fn.fnameescape(vim.fn.expand("%:p")) },
        })
      end,
      desc = "Search and Replace",
    },
    {
      "<leader>scr",
      function()
        require("grug-far").toggle_instance({
          instanceName = "grug-far",
          transient = true,
        })
      end,
      desc = "Search and Replace CWD",
    },
    {
      "<leader>sgr",
      function()
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if vim.v.shell_error ~= 0 then
          vim.notify("Not in a git repository", vim.log.levels.WARN)
          return
        end
        require("grug-far").open({
          transient = true,
          prefills = { paths = vim.fn.fnameescape(git_root) },
        })
      end,
      desc = "Search and Replace GIT",
    },
    {
      "<leader>shr",
      function()
        require("grug-far").open({
          transient = true,
          prefills = { paths = vim.fn.fnameescape(vim.fn.expand("~")) },
        })
      end,
      desc = "Search and Replace HOME",
    },
    {
      "<leader>sw",
      function()
        require("grug-far").toggle_instance({
          instanceName = "grug-far",
          transient = true,
          prefills = {
            search = vim.fn.expand("<cword>"),
            paths = vim.fn.fnameescape(vim.fn.expand("%:p")),
          },
        })
      end,
      desc = "Search Word",
    },
    {
      "<leader>sw",
      mode = "v",
      function()
        require("grug-far").with_visual_selection({
          instanceName = "grug-far",
          transient = true,
          prefills = { paths = vim.fn.fnameescape(vim.fn.expand("%:p")) },
        })
      end,
      desc = "Search Selection",
    },
    {
      "<leader>scw",
      function()
        require("grug-far").toggle_instance({
          instanceName = "grug-far",
          transient = true,
          prefills = { search = vim.fn.expand("<cword>") },
        })
      end,
      desc = "Search Word CWD",
    },
    {
      "<leader>scw",
      mode = "v",
      function()
        require("grug-far").with_visual_selection({
          instanceName = "grug-far",
          transient = true,
        })
      end,
      desc = "Search Selection CWD",
    },
    {
      "<leader>sgw",
      function()
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if vim.v.shell_error ~= 0 then
          vim.notify("Not in a git repository", vim.log.levels.WARN)
          return
        end
        require("grug-far").open({
          transient = true,
          prefills = {
            search = vim.fn.expand("<cword>"),
            paths = vim.fn.fnameescape(git_root),
          },
        })
      end,
      desc = "Search Word GIT",
    },
    {
      "<leader>sgw",
      mode = "v",
      function()
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if vim.v.shell_error ~= 0 then
          vim.notify("Not in a git repository", vim.log.levels.WARN)
          return
        end
        require("grug-far").with_visual_selection({
          transient = true,
          prefills = { paths = vim.fn.fnameescape(git_root) },
        })
      end,
      desc = "Search Selection GIT",
    },
    {
      "<leader>shw",
      function()
        require("grug-far").open({
          transient = true,
          prefills = {
            search = vim.fn.expand("<cword>"),
            paths = vim.fn.fnameescape(vim.fn.expand("~")),
          },
        })
      end,
      desc = "Search Word HOME",
    },
    {
      "<leader>shw",
      mode = "v",
      function()
        require("grug-far").with_visual_selection({
          transient = true,
          prefills = { paths = vim.fn.fnameescape(vim.fn.expand("~")) },
        })
      end,
      desc = "Search Selection HOME",
    },
  },

  opts = {
    windowCreationCommand = "vsplit",
    startInInsertMode = true,
    icons = { enabled = false },
    engines = {
      ripgrep = {
        placeholders = {
          enabled = false, -- Removes all placeholder text
        },
        extraArgs = "--glob=!.git/*"
          .. "--glob=!**/.viminfo* "
          .. "--glob=!**/.zcompdump* "
          .. "--glob=!**/Trash/** "
          .. "--glob=!**/logs/** "
          .. "--glob=!**/backup/** "
          .. "--glob=!**/cfg_backups/**",
      },
    },
    prefills = {
      flags = "--hidden "
        .. "--glob !**/hyde-shell "
        .. "--glob !**/dotfiles/** "
        .. "--glob !**/lib/hyde/** "
        .. "--glob !**/.codeium/** "
        .. "--glob !**/state/nvim/** "
        .. "--glob !**/share/nvim/** "
        .. "--glob !**/*Code*OSS*/**",
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
