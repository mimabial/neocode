return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal (float)" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal (horizontal)" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal (vertical)" },
    { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    { "<C-/>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    { "<C-_>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = [[<C-\>]],
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    shell = vim.o.shell,
    auto_scroll = true,
    float_opts = {
      border = "curved",
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    -- Terminal mode keymaps
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
      vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    end

    -- if you only want these mappings for toggle term use term://*toggleterm#* instead
    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

    -- Custom terminal commands
    local Terminal = require("toggleterm.terminal").Terminal

    -- Lazygit terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      dir = "git_dir",
      hidden = true,
      direction = "float",
      float_opts = {
        border = "curved",
      },
    })

    -- Function to toggle lazygit
    function _G.toggle_lazygit()
      lazygit:toggle()
    end

    -- Node terminal
    local node = Terminal:new({
      cmd = "node",
      hidden = true,
      direction = "float",
    })

    function _G.toggle_node()
      node:toggle()
    end

    -- Python terminal
    local python = Terminal:new({
      cmd = "python",
      hidden = true,
      direction = "float",
    })

    function _G.toggle_python()
      python:toggle()
    end

    -- Register keymaps for these terminals
    vim.api.nvim_set_keymap("n", "<leader>gg", "<cmd>lua toggle_lazygit()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>tn", "<cmd>lua toggle_node()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>tp", "<cmd>lua toggle_python()<CR>", { noremap = true, silent = true })
  end,
}
