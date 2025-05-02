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
    auto_scroll = true, -- automatically scroll to the bottom on terminal output
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
      border = "curved",
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
      width = function()
        return math.floor(vim.o.columns * 0.85)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
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
        width = math.floor(vim.o.columns * 0.9),
        height = math.floor(vim.o.lines * 0.9),
      },
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
      end,
    })

    function _G.toggle_lazygit()
      lazygit:toggle()
    end

    -- Node terminal
    local node = Terminal:new({
      cmd = "node",
      hidden = true,
      direction = "float",
      float_opts = {
        border = "curved",
      },
      on_open = function(term)
        vim.cmd("startinsert!")
      end,
    })

    function _G.toggle_node()
      node:toggle()
    end

    -- Python terminal
    local python = Terminal:new({
      cmd = function()
        -- Try to find a virtual environment first
        local venv = vim.fn.finddir(".venv", vim.fn.getcwd() .. ";")
        if venv ~= "" then
          return venv .. "/bin/python"
        end

        -- Check for pipenv
        local pipenv = vim.fn.system("command -v pipenv >/dev/null 2>&1 && echo 'true' || echo 'false'")
        if vim.trim(pipenv) == "true" then
          return "pipenv run python"
        end

        -- Fallback to system python
        return "python"
      end,
      hidden = true,
      direction = "float",
      float_opts = {
        border = "curved",
      },
      on_open = function(term)
        vim.cmd("startinsert!")
      end,
    })

    function _G.toggle_python()
      python:toggle()
    end

    -- Go terminal
    local go_term = Terminal:new({
      cmd = "go",
      hidden = true,
      direction = "float",
      float_opts = {
        border = "curved",
      },
      on_open = function(term)
        vim.cmd("startinsert!")
      end,
    })

    function _G.toggle_go()
      go_term:toggle()
    end

    -- NPM terminal with dev option
    local npm_dev = Terminal:new({
      cmd = "npm run dev",
      hidden = true,
      direction = "float",
      float_opts = {
        border = "curved",
      },
      on_open = function(term)
        vim.cmd("startinsert!")
      end,
    })

    function _G.toggle_npm_dev()
      npm_dev:toggle()
    end

    -- Htmx terminal with server option (for GOTH stack)
    local htmx_server = Terminal:new({
      cmd = function()
        -- Check if this is a Go project with templ files
        local has_templ = vim.fn.glob("**/*.templ") ~= ""
        if has_templ then
          return "go run ."
        end

        -- Fallback to a simple HTTP server
        return "python -m http.server"
      end,
      hidden = true,
      direction = "float",
      float_opts = {
        border = "curved",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.7),
      },
      on_open = function(term)
        vim.notify("Started server", vim.log.levels.INFO)
        vim.cmd("startinsert!")
      end,
    })

    function _G.toggle_htmx_server()
      htmx_server:toggle()
    end

    -- Register keymaps for these terminals
    vim.api.nvim_set_keymap("n", "<leader>gg", "<cmd>lua toggle_lazygit()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>tn", "<cmd>lua toggle_node()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>tp", "<cmd>lua toggle_python()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>tg", "<cmd>lua toggle_go()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>td", "<cmd>lua toggle_npm_dev()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>ts", "<cmd>lua toggle_htmx_server()<CR>", { noremap = true, silent = true })

    -- Stack-specific keymaps
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "go", "templ" },
      callback = function()
        vim.keymap.set("n", "<leader>sr", function()
          toggle_htmx_server()
        end, { buffer = true, desc = "Run GOTH Server" })
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      callback = function()
        vim.keymap.set("n", "<leader>sr", function()
          toggle_npm_dev()
        end, { buffer = true, desc = "Run Next.js Server" })
      end,
    })
  end,
}
