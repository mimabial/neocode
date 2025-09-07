-- lua/plugins/toggleterm.lua
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",      desc = "Terminal (float)" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal (horizontal)" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>",   desc = "Terminal (vertical)" },
    { "<leader>tt", "<cmd>ToggleTerm<cr>",                      desc = "Toggle terminal" },
    { "<C-/>",      "<cmd>ToggleTerm<cr>",                      desc = "Toggle terminal" },
    { "<C-_>",      "<cmd>ToggleTerm<cr>",                      desc = "Toggle terminal" },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return math.floor(vim.o.lines * 0.3)
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
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
    -- Float options
    float_opts = {
      border = "single",
      winblend = 0,
      highlights = {
        border = "FloatBorder",
        background = "Normal",
      },
      width = function()
        return math.floor(vim.o.columns * 0.85)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
    },
    -- Winbar to show current process
    winbar = {
      enabled = true,
      name_formatter = function(term)
        if not term or not term.cmd then
          return " Terminal" -- Default fallback name
        end

        local title = term.display_name or term.name
        local icon = ""

        -- Determine icon based on cmd
        if term.cmd:match("go") then
          icon = ""
        elseif term.cmd:match("npm") or term.cmd:match("yarn") or term.cmd:match("pnpm") then
          icon = ""
        elseif term.cmd:match("git") or term.cmd:match("lazygit") then
          icon = ""
        elseif term.cmd:match("docker") then
          icon = ""
        elseif term.cmd:match("node") then
          icon = ""
        elseif term.cmd:match("python") then
          icon = ""
        else
          icon = ""
        end

        return icon .. " " .. title
      end,
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    -- Terminal mode keymaps
    local function set_terminal_keymaps()
      local buf = vim.api.nvim_get_current_buf()
      local map_opts = { buffer = buf, noremap = true, silent = true }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], map_opts)
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], map_opts)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], map_opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], map_opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], map_opts)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], map_opts)
      vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], map_opts)

      -- Normal mode mapping for q to close
      vim.keymap.set("n", "q", function()
        local term = require("toggleterm.terminal").get_focused_id()
        if term then
          require("toggleterm").toggle(term)
        else
          vim.cmd("close")
        end
      end, map_opts)
    end

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = set_terminal_keymaps,
    })

    -- Custom terminal factory
    local Terminal = require("toggleterm.terminal").Terminal

    -- Helper to create terminal commands
    local function create_term_cmd(name, cmd, opts)
      local term_opts = vim.tbl_deep_extend("force", {
        cmd = cmd,
        hidden = true,
        direction = "float",
        float_opts = {
          border = "curved",
        },
        on_open = function(term)
          vim.cmd("startinsert!")
        end,
        on_exit = function(_)
          -- Refresh git status if this was a git command
          if cmd:match("git") and package.loaded["gitsigns"] then
            require("gitsigns").refresh()
          end
        end,
      }, opts or {})

      -- Create the terminal
      local term = Terminal:new(term_opts)

      -- Create the toggle function
      _G["toggle_" .. name] = function()
        term:toggle()
      end

      -- Create user command
      vim.api.nvim_create_user_command(name, function()
        term:toggle()
      end, { desc = term_opts.desc or ("Toggle " .. name) })

      -- Create keymap if provided
      if opts and opts.keymap then
        vim.keymap.set("n", opts.keymap, function()
          term:toggle()
        end, { desc = term_opts.desc or ("Toggle " .. name) })
      end

      return term
    end

    -- Generic terminals
    create_term_cmd("FloatTerm", vim.o.shell, {
      display_name = "Shell",
      keymap = "<leader>tf",
    })

    -- Lazygit terminal
    create_term_cmd("LazyGit", "lazygit", {
      display_name = "LazyGit",
      desc = "Git UI",
      dir = "git_dir",
      keymap = "<leader>gg",
    })

    -- Create stack-specific terminals

    -- GOTH stack terminals
    create_term_cmd("GoRun", "go run .", {
      display_name = "Go Run",
      desc = "Run Go project",
      keymap = "<leader>gr",
    })

    create_term_cmd("GoTest", "go test ./...", {
      display_name = "Go Test",
      desc = "Run Go tests",
      keymap = "<leader>gt",
    })

    create_term_cmd("TemplGenerate", "templ generate && echo 'Templ files generated successfully!'", {
      display_name = "Templ Generate",
      desc = "Generate Templ files",
      keymap = "<leader>tg",
    })

    create_term_cmd("GOTHServer", function()
      -- Check if using Air for live reload
      if vim.fn.filereadable(".air.toml") == 1 then
        return "air"
      else
        return "templ generate && go run ."
      end
    end, {
      display_name = "GOTH Server",
      desc = "Start GOTH server",
      keymap = "<leader>gs",
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.notify("󰟓 Starting GOTH server...", vim.log.levels.INFO, { title = "GOTH" })
      end,
    })

    -- Next.js stack terminals
    create_term_cmd("NextDev", "npm run dev", {
      display_name = "Next.js Dev",
      desc = "Next.js development server",
      keymap = "<leader>nd",
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.notify(" Starting Next.js development server...", vim.log.levels.INFO, { title = "Next.js" })
      end,
    })

    create_term_cmd("NextBuild", "npm run build", {
      display_name = "Next.js Build",
      desc = "Build Next.js application",
      keymap = "<leader>nb",
    })

    create_term_cmd("NextStart", "npm run start", {
      display_name = "Next.js Start",
      desc = "Start Next.js production server",
      keymap = "<leader>ns",
    })

    create_term_cmd("NextLint", "npm run lint", {
      display_name = "Next.js Lint",
      desc = "Run Next.js linter",
      keymap = "<leader>nl",
    })

    -- Stack-specific keymaps
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "go", "templ" },
      callback = function()
        vim.keymap.set("n", "<leader>sr", function()
          _G.toggle_GOTHServer()
        end, { buffer = true, desc = "Run GOTH Server" })

        vim.keymap.set("n", "<leader>st", function()
          _G.toggle_GoTest()
        end, { buffer = true, desc = "Run Go Tests" })

        vim.keymap.set("n", "<leader>sg", function()
          _G.toggle_TemplGenerate()
        end, { buffer = true, desc = "Generate Templ Files" })
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      callback = function()
        vim.keymap.set("n", "<leader>sr", function()
          _G.toggle_NextDev()
        end, { buffer = true, desc = "Run Next.js Server" })

        vim.keymap.set("n", "<leader>sb", function()
          _G.toggle_NextBuild()
        end, { buffer = true, desc = "Build Next.js App" })

        vim.keymap.set("n", "<leader>sl", function()
          _G.toggle_NextLint()
        end, { buffer = true, desc = "Lint Next.js App" })
      end,
    })

    -- Create dynamic menu command to list available terminals
    vim.api.nvim_create_user_command("Terminals", function()
      local terms = require("toggleterm.terminal").get_all(true)
      if #terms == 0 then
        vim.notify("No terminals available", vim.log.levels.INFO)
        return
      end

      local choices = {}
      for _, term in ipairs(terms) do
        table.insert(choices, {
          name = term.display_name or term.name or term.cmd,
          id = term.id,
          cmd = term.cmd,
        })
      end

      vim.ui.select(choices, {
        prompt = "Select terminal to toggle:",
        format_item = function(item)
          return string.format("%d: %s (%s)", item.id, item.name, item.cmd)
        end,
      }, function(choice)
        if choice then
          require("toggleterm").toggle(choice.id)
        end
      end)
    end, { desc = "List and select terminals" })
  end,
}
