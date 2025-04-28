return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    operators = { gc = "Comments", gb = "Block Comments" },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    popup_mappings = {
      scroll_down = "<c-d>",
      scroll_up = "<c-u>",
    },
    window = {
      border = "rounded",
      position = "bottom",
      margin = { 1, 0, 1, 0 },
      padding = { 1, 2, 1, 2 },
      winblend = 0,
    },
    layout = {
      height = { min = 4, max = 25 },
      width = { min = 20, max = 50 },
      spacing = 3,
      align = "center",
    },
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " },
    triggers_blacklist = {
      i = { "j", "k" },
      v = { "j", "k" },
    },
    show_help = true,
    show_keys = true,
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt", "neo-tree" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    
    -- Register all top-level keymaps and groups
    -- This ensures all keymap groups are properly displayed
    wk.register({
      -- Leader key groups
      ["<leader>"] = {
        b = { name = "+Buffer" },
        c = { name = "+Code/LSP" },
        d = { name = "+Debug" },
        f = { name = "+Find/Telescope" },
        g = { name = "+Git" },
        h = { name = "+Git Hunks" },
        L = { name = "+Layouts" },
        n = { name = "+Noice/Notifications" },
        q = { name = "+Quit/Session" },
        s = { name = "+Stack-Specific" },
        t = { name = "+Terminal/Toggle" },
        u = { name = "+UI" },
        w = { name = "+Windows" },
        x = { name = "+Diagnostics/Quickfix" },
        e = { name = "+Explorer" },
        r = { name = "+Rename/Replace" },
      },
      
      -- Navigation key pairs
      ["["] = { name = "+Prev..." },
      ["]"] = { name = "+Next..." },
      
      -- g prefixed commands
      ["g"] = { name = "+Goto/LSP" },
    })

    -- Buffer management
    wk.register({
      ["<leader>b"] = {
        b = { "<cmd>e #<cr>", "Switch to Other Buffer" },
        d = { "<cmd>bdelete<cr>", "Delete Buffer" },
        f = { "<cmd>bfirst<cr>", "First Buffer" },
        h = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
        l = { "<cmd>blast<cr>", "Last Buffer" },
        n = { "<cmd>bnext<cr>", "Next Buffer" },
        p = { "<cmd>bprevious<cr>", "Previous Buffer" },
        e = { "<cmd>Neotree buffers reveal float<cr>", "Buffer Explorer" },
      },
      ["<S-h>"] = { "<cmd>bprevious<cr>", "Previous buffer" },
      ["<S-l>"] = { "<cmd>bnext<cr>", "Next buffer" },
      ["[b"] = { "<cmd>bprevious<cr>", "Prev buffer" },
      ["]b"] = { "<cmd>bnext<cr>", "Next buffer" },
    })

    -- Code & LSP commands
    wk.register({
      ["<leader>c"] = {
        name = "+Code/LSP",
        a = { vim.lsp.buf.code_action, "Code Action" },
        d = { vim.diagnostic.open_float, "Line Diagnostics" },
        f = { vim.lsp.buf.format, "Format" },
        F = { "<cmd>FormatToggle<CR>", "Toggle Format on Save" },
        i = { "<cmd>LspInfo<cr>", "LSP Info" },
        l = { "<cmd>lua require('lint').try_lint()<cr>", "Trigger Linting" },
        r = { vim.lsp.buf.rename, "Rename Symbol" },
        s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
        S = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
        g = { 
          name = "+GOTH",
          c = { function() require("config.utils").new_templ_component() end, "New Templ Component" },
          t = { "<cmd>!go test ./...<cr>", "Run Go Tests" }, 
          m = { "<cmd>!go mod tidy<cr>", "Go Mod Tidy" },
          b = { "<cmd>!go build<cr>", "Go Build" },
          r = { "<cmd>!go run .<cr>", "Go Run" },
        },
        n = { 
          name = "+Next.js",
          c = { function() require("config.utils").new_nextjs_component("client") end, "New Client Component" },
          s = { function() require("config.utils").new_nextjs_component("server") end, "New Server Component" },
          p = { function() require("config.utils").new_nextjs_component("page") end, "New Page" },
          l = { function() require("config.utils").new_nextjs_component("layout") end, "New Layout" },
          d = { "<cmd>!npm run dev<cr>", "Next.js Dev" },
          b = { "<cmd>!npm run build<cr>", "Next.js Build" },
          t = { "<cmd>!npm test<cr>", "Run Tests" },
          i = { "<cmd>!npm install<cr>", "NPM Install" },
        },
      }
    })

    -- Debug commands
    wk.register({
      ["<leader>d"] = {
        name = "+Debug",
        b = { function() require('dap').toggle_breakpoint() end, "Toggle Breakpoint" },
        B = { function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, "Conditional Breakpoint" },
        c = { function() require('dap').continue() end, "Continue" },
        C = { function() require('dap').run_to_cursor() end, "Run to Cursor" },
        e = { function() require('dapui').eval() end, "Evaluate Expression" },
        i = { function() require('dap').step_into() end, "Step Into" },
        o = { function() require('dap').step_over() end, "Step Over" },
        O = { function() require('dap').step_out() end, "Step Out" },
        r = { function() require('dap').repl.toggle() end, "Toggle REPL" },
        R = { function() require('dap').restart() end, "Restart" },
        t = { function() require('dap').terminate() end, "Terminate" },
        u = { function() require('dapui').toggle() end, "Toggle UI" },
        g = { function() _G.debug_goth_app() end, "Debug GOTH App" },
      }
    })

    -- Function keys for debugging
    wk.register({
      ["<F5>"] = { function() require("dap").continue() end, "Continue" },
      ["<F10>"] = { function() require("dap").step_over() end, "Step Over" },
      ["<F11>"] = { function() require("dap").step_into() end, "Step Into" },
      ["<F12>"] = { function() require("dap").step_out() end, "Step Out" },
    })

    -- Find/Telescope commands
    wk.register({
      ["<leader>f"] = {
        name = "+Find/Telescope",
        ["/"] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find in Buffer" },
        b = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
        c = { "<cmd>Telescope commands<cr>", "Find Commands" },
        C = { function() require("telescope.builtin").find_files({cwd = vim.fn.stdpath("config")}) end, "Find Config Files" },
        d = { "<cmd>Telescope diagnostics bufnr=0<cr>", "Find Document Diagnostics" },
        D = { "<cmd>Telescope diagnostics<cr>", "Find Workspace Diagnostics" },
        e = { "<cmd>Telescope file_browser<cr>", "File Browser" },
        f = { "<cmd>Telescope find_files<cr>", "Find Files" },
        g = { "<cmd>Telescope live_grep<cr>", "Find Text (Grep)" },
        h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
        k = { "<cmd>Telescope keymaps<cr>", "Find Keymaps" },
        o = { "<cmd>Telescope vim_options<cr>", "Find Options" },
        n = { "<cmd>Telescope file_browser<cr>", "Browse Next.js Project" },
        p = { "<cmd>Telescope projects<cr>", "Find Projects" },
        r = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
        R = { "<cmd>Telescope frecency<cr>", "Frecent Files" },
        s = { "<cmd>Telescope lsp_document_symbols<cr>", "Find Document Symbols" },
        S = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Find Workspace Symbols" },
        t = { "<cmd>Telescope filetypes<cr>", "Find Filetypes" },
        T = { "<cmd>Telescope builtin<cr>", "Find Telescope Pickers" },
        ["."] = { "<cmd>Telescope resume<cr>", "Resume Last Search" },
      }
    })

    -- Git commands
    wk.register({
      ["<leader>g"] = {
        name = "+Git",
        b = { "<cmd>Telescope git_branches<cr>", "Git Branches" },
        c = { "<cmd>Telescope git_commits<cr>", "Git Commits" },
        d = { "<cmd>DiffviewOpen<cr>", "DiffView Open" },
        D = { "<cmd>DiffviewClose<cr>", "DiffView Close" },
        e = { "<cmd>Neotree git_status reveal float<cr>", "Git Explorer" },
        g = { "<cmd>LazyGit<cr>", "Lazygit" },
        h = { "<cmd>DiffviewFileHistory %<cr>", "File History" },
        H = { "<cmd>DiffviewFileHistory<cr>", "Project History" },
        l = { "<cmd>Git pull<cr>", "Git Pull" },
        p = { "<cmd>Git push<cr>", "Git Push" },
        s = { "<cmd>Telescope git_status<cr>", "Git Status" },
        o = { "<cmd>Octo<cr>", "Octo" },
        r = { "<cmd>Octo pr list<cr>", "PR List" },
        i = { "<cmd>Octo issue list<cr>", "Issue List" },
      }
    })

    -- Git Signs / Hunks 
    wk.register({
      ["<leader>h"] = {
        name = "+Git Hunks",
        b = { function() require("gitsigns").blame_line({ full = true }) end, "Blame Line" },
        B = { function() require("gitsigns").toggle_current_line_blame() end, "Toggle Line Blame" },
        d = { function() require("gitsigns").diffthis() end, "Diff This" },
        D = { function() require("gitsigns").diffthis("~") end, "Diff This ~" },
        p = { function() require("gitsigns").preview_hunk() end, "Preview Hunk" },
        r = { function() require("gitsigns").reset_hunk() end, "Reset Hunk" },
        R = { function() require("gitsigns").reset_buffer() end, "Reset Buffer" },
        s = { function() require("gitsigns").stage_hunk() end, "Stage Hunk" },
        S = { function() require("gitsigns").stage_buffer() end, "Stage Buffer" },
        u = { function() require("gitsigns").undo_stage_hunk() end, "Undo Stage Hunk" },
      }
    })

    -- Noice and notifications
    wk.register({
      ["<leader>n"] = {
        name = "+Noice/Notifications",
        a = { function() require("noice").cmd("all") end, "Noice All" },
        d = { function() require("noice").cmd("dismiss") end, "Dismiss All" },
        h = { function() require("noice").cmd("history") end, "Noice History" },
        l = { function() require("noice").cmd("last") end, "Noice Last Message" },
        e = { function() require("noice").cmd("errors") end, "Noice Errors" },
      }
    })

    -- Quick exit and sessions
    wk.register({
      ["<leader>q"] = {
        name = "+Quit/Session",
        q = { "<cmd>qa<cr>", "Quit All" },
        w = { "<cmd>wqa<cr>", "Save and Quit All" },
        s = { function() require("persistence").load() end, "Restore Session" },
        l = { function() require("persistence").load({ last = true }) end, "Restore Last Session" },
        d = { function() require("persistence").stop() end, "Don't Save Current Session" },
      }
    })

    -- Stack-specific commands
    wk.register({
      ["<leader>s"] = {
        name = "+Stack-Specific",
        g = {
          name = "+GOTH Stack",
          n = { function()
              vim.ui.input({ prompt = "Project name: " }, function(name)
                if name and name ~= "" then
                  local Terminal = require("toggleterm.terminal").Terminal
                  local goth_init = Terminal:new({
                    cmd = string.format("mkdir -p %s && cd %s && go mod init %s && mkdir -p components handlers static", name, name, name),
                    hidden = false,
                    direction = "float",
                    on_exit = function()
                      -- Create main.go, components, etc.
                      vim.cmd("cd " .. name)
                      vim.notify("GOTH project '" .. name .. "' initialized!", vim.log.levels.INFO)
                    end,
                  })
                  goth_init:toggle()
                end
              end)
            end,
            "New GOTH Project" 
          },
          r = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local goth_run = Terminal:new({
                cmd = "templ generate && go run .",
                hidden = false,
                direction = "horizontal",
              })
              goth_run:toggle()
            end,
            "Run GOTH Project" 
          },
          d = { "<cmd>DebugGOTHApp<cr>", "Debug GOTH App" },
          g = { "<cmd>!templ generate<cr>", "Generate Templ Files" },
          c = { function() require("config.utils").new_templ_component() end, "New Templ Component" },
          t = { "<cmd>!go test ./...<cr>", "Run Go Tests" },
          m = { "<cmd>!go mod tidy<cr>", "Go Mod Tidy" },
          b = { "<cmd>!go build<cr>", "Go Build" },
          p = { "<cmd>StackFocus goth<cr>", "Focus GOTH Stack" },
        },
        n = {
          name = "+Next.js Stack",
          n = { 
            function()
              vim.ui.input({ prompt = "Project name: " }, function(name)
                if name and name ~= "" then
                  local Terminal = require("toggleterm.terminal").Terminal
                  local nextjs_init = Terminal:new({
                    cmd = string.format("npx create-next-app@latest %s --typescript --eslint --tailwind --app --src-dir --import-alias '@/*'", name),
                    hidden = false,
                    direction = "float",
                  })
                  nextjs_init:toggle()
                end
              end)
            end,
            "New Next.js Project" 
          },
          d = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local nextjs_dev = Terminal:new({
                cmd = "npm run dev",
                hidden = false,
                direction = "horizontal",
              })
              nextjs_dev:toggle()
            end,
            "Run Development Server" 
          },
          b = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local nextjs_build = Terminal:new({
                cmd = "npm run build",
                hidden = false,
                direction = "horizontal",
              })
              nextjs_build:toggle()
            end,
            "Build for Production" 
          },
          s = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local nextjs_start = Terminal:new({
                cmd = "npm run start",
                hidden = false,
                direction = "horizontal",
              })
              nextjs_start:toggle()
            end,
            "Start Production Server" 
          },
          t = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local nextjs_test = Terminal:new({
                cmd = "npm run test",
                hidden = false,
                direction = "horizontal",
              })
              nextjs_test:toggle()
            end,
            "Run Tests" 
          },
          l = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local nextjs_lint = Terminal:new({
                cmd = "npm run lint",
                hidden = false,
                direction = "horizontal",
              })
              nextjs_lint:toggle()
            end,
            "Lint Project" 
          },
          c = { function() require("config.utils").new_nextjs_component("client") end, "New Client Component" },
          S = { function() require("config.utils").new_nextjs_component("server") end, "New Server Component" },
          p = { function() require("config.utils").new_nextjs_component("page") end, "New Page" },
          L = { function() require("config.utils").new_nextjs_component("layout") end, "New Layout" },
          f = { "<cmd>StackFocus nextjs<cr>", "Focus Next.js Stack" },
          i = {
            function()
              vim.ui.input({ prompt = "Package name: " }, function(package)
                if package and package ~= "" then
                  local Terminal = require("toggleterm.terminal").Terminal
                  local npm_install = Terminal:new({
                    cmd = "npm install " .. package,
                    hidden = false,
                    direction = "float",
                  })
                  npm_install:toggle()
                end
              end)
            end,
            "Install Package"
          },
          D = {
            function()
              vim.ui.input({ prompt = "Dev package name: " }, function(package)
                if package and package ~= "" then
                  local Terminal = require("toggleterm.terminal").Terminal
                  local npm_install_dev = Terminal:new({
                    cmd = "npm install -D " .. package,
                    hidden = false,
                    direction = "float",
                  })
                  npm_install_dev:toggle()
                end
              end)
            end,
            "Install Dev Package"
          },
        },
        r = { "<cmd>lua _G.toggle_htmx_server()<cr>", "Run Server" },
      }
    })

    -- Terminal commands
    wk.register({
      ["<leader>t"] = {
        name = "+Terminal/Toggle",
        f = { "<cmd>ToggleTerm direction=float<cr>", "Terminal (float)" },
        h = { "<cmd>ToggleTerm direction=horizontal<cr>", "Terminal (horizontal)" },
        v = { "<cmd>ToggleTerm direction=vertical<cr>", "Terminal (vertical)" },
        t = { "<cmd>ToggleTerm<cr>", "Toggle terminal" },
        b = { function() require("gitsigns").toggle_current_line_blame() end, "Toggle Line Blame" },
        d = { function() require("gitsigns").toggle_deleted() end, "Toggle Deleted" },
        n = { function() _G.toggle_node() end, "Node Terminal" },
        p = { function() _G.toggle_python() end, "Python Terminal" },
        g = { function() _G.toggle_go() end, "Go Terminal" },
        s = { function() _G.toggle_htmx_server() end, "HTMX Server" },
        c = { function() require("config.utils").toggle_colorcolumn() end, "Toggle Color Column" },
        w = { function() vim.wo.wrap = not vim.wo.wrap; vim.notify("Wrap " .. (vim.wo.wrap and "enabled" or "disabled")) end, "Toggle Wrap" },
        a = { "<cmd>FormatToggle<cr>", "Toggle Auto Format (global)" },
        A = { "<cmd>FormatToggleBuffer<cr>", "Toggle Auto Format (buffer)" },
      }
    })

    -- UI toggles and commands
    wk.register({
      ["<leader>u"] = {
        name = "+UI",
        c = { "<cmd>ColorSchemeToggle<cr>", "Toggle Colorscheme" },
        n = { function() require("notify").dismiss({ silent = true, pending = true }) end, "Dismiss Notifications" },
        r = { "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", "Redraw / Clear Highlight" },
        t = { "<cmd>ToggleTransparency<cr>", "Toggle Transparency" },
        T = { "<cmd>ToggleTransparency<cr>", "Toggle Transparency" },
        l = { "<cmd>Lazy<cr>", "Lazy Plugin Manager" },
        L = { "<cmd>LazyUpdate<cr>", "Update Plugins" },
        m = { "<cmd>Mason<cr>", "Mason LSP Manager" },
        M = { "<cmd>MasonUpdate<cr>", "Update LSP Servers" },
      }
    })

    -- Windows management
    wk.register({
      ["<leader>w"] = {
        name = "+Window",
        ["-"] = { "<C-W>s", "Split window below" },
        ["|"] = { "<C-W>v", "Split window right" },
        ["2"] = { "<C-W>v", "Layout double columns" },
        h = { "<C-W>h", "Go to left window" },
        j = { "<C-W>j", "Go to lower window" },
        k = { "<C-W>k", "Go to upper window" },
        l = { "<C-W>l", "Go to right window" },
        q = { "<C-W>q", "Close window" },
        w = { "<C-W>w", "Other window" },
        ["="] = { "<C-W>=", "Balance windows" },
      },
      -- Better window navigation
      ["<C-h>"] = { "<C-w>h", "Go to left window" },
      ["<C-j>"] = { "<C-w>j", "Go to lower window" },
      ["<C-k>"] = { "<C-w>k", "Go to upper window" },
      ["<C-l>"] = { "<C-w>l", "Go to right window" },
      -- Resize window using ctrl+arrow keys
      ["<C-Up>"] = { "<cmd>resize +2<cr>", "Increase window height" },
      ["<C-Down>"] = { "<cmd>resize -2<cr>", "Decrease window height" },
      ["<C-Left>"] = { "<cmd>vertical resize -2<cr>", "Decrease window width" },
      ["<C-Right>"] = { "<cmd>vertical resize +2<cr>", "Increase window width" },
    })

    -- Diagnostics and quickfix
    wk.register({
      ["<leader>x"] = {
        name = "+Diagnostics/Quickfix",
        d = { "<cmd>TroubleToggle document_diagnostics<cr>", "Document Diagnostics" },
        l = { "<cmd>TroubleToggle loclist<cr>", "Location List" },
        q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix List" },
        t = { "<cmd>TodoTrouble<cr>", "Todo Trouble" },
        T = { "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", "Todo/Fix/Fixme Trouble" },
        w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace Diagnostics" },
        x = { "<cmd>TroubleToggle<cr>", "Toggle Trouble" },
        f = { function() require("config.utils").toggle_qf() end, "Toggle Quickfix" },
      }
    })

    -- Explorer
    wk.register({
      ["<leader>e"] = { function() require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() }) end, "Explorer NeoTree (cwd)" },
      ["<leader>E"] = { function() require("neo-tree.command").execute({ toggle = true, dir = vim.fn.stdpath("config") }) end, "Explorer NeoTree (config)" },
      ["<leader>be"] = { "<cmd>Neotree buffers reveal float<cr>", "Buffer explorer" },
      ["<leader>ge"] = { "<cmd>Neotree git_status reveal float<cr>", "Git status explorer" },
      ["<leader>se"] = { "<cmd>Neotree document_symbols reveal float<cr>", "Symbols Explorer" },
      ["-"] = { "<CMD>Oil<CR>", "Open parent directory" }
    })

    -- Navigation key pairs 
    wk.register({
      ["["] = {
        b = { "<cmd>bprevious<cr>", "Previous Buffer" },
        c = { function() require("gitsigns").prev_hunk() end, "Previous Hunk" },
        d = { vim.diagnostic.goto_prev, "Previous Diagnostic" },
        l = { "<cmd>lprev<cr>", "Previous Location" },
        q = { "<cmd>cprev<cr>", "Previous Quickfix" },
        t = { function() require("todo-comments").jump_prev() end, "Previous Todo" },
      },
      ["]"] = {
        b = { "<cmd>bnext<cr>", "Next Buffer" },
        c = { function() require("gitsigns").next_hunk() end, "Next Hunk" },
        d = { vim.diagnostic.goto_next, "Next Diagnostic" },
        l = { "<cmd>lnext<cr>", "Next Location" },
        q = { "<cmd>cnext<cr>", "Next Quickfix" },
        t = { function() require("todo-comments").jump_next() end, "Next Todo" },
      },
    })

    -- Layout switching
    wk.register({
      ["<leader>L"] = {
        name = "+Layouts",
        ["1"] = { "<cmd>Layout coding<cr>", "Coding Layout" },
        ["2"] = { "<cmd>Layout terminal<cr>", "Terminal Layout" },
        ["3"] = { "<cmd>Layout writing<cr>", "Writing Layout" },
        ["4"] = { "<cmd>Layout debug<cr>", "Debug Layout" },
      },
    })

    -- LSP related keymaps
    wk.register({
      ["g"] = {
        name = "+Goto/LSP",
        d = { vim.lsp.buf.definition, "Go to Definition" },
        D = { vim.lsp.buf.declaration, "Go to Declaration" },
        r = { function() require("telescope.builtin").lsp_references() end, "Go to References" },
        i = { vim.lsp.buf.implementation, "Go to Implementation" },
        t = { vim.lsp.buf.type_definition, "Go to Type Definition" },
        s = { require("telescope.builtin").lsp_document_symbols, "Document Symbols" },
        S = { require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols" },
        ["<C-g>"] = { vim.lsp.buf.signature_help, "Signature Help" },
      },
      -- Document hover display
      ["K"] = { vim.lsp.buf.hover, "Show Documentation" },
    })

    -- Move lines in normal, insert and visual mode
    wk.register({
      ["<A-j>"] = { "<cmd>m .+1<cr>==", "Move line down" },
      ["<A-k>"] = { "<cmd>m .-2<cr>==", "Move line up" },
    }, { mode = "n" })
    
    wk.register({
      ["<A-j>"] = { "<esc><cmd>m .+1<cr>==gi", "Move line down" },
      ["<A-k>"] = { "<esc><cmd>m .-2<cr>==gi", "Move line up" },
    }, { mode = "i" })
    
    wk.register({
      ["<A-j>"] = { ":m '>+1<cr>gv=gv", "Move selection down" },
      ["<A-k>"] = { ":m '<-2<cr>gv=gv", "Move selection up" },
    }, { mode = "v" })

    -- Text editing
    wk.register({
      ["J"] = { "mzJ`z", "Join lines (maintain cursor position)" },
    })
    
    -- Better navigation with center
    wk.register({
      ["<C-d>"] = { "<C-d>zz", "Scroll down half a page and center" },
      ["<C-u>"] = { "<C-u>zz", "Scroll up half a page and center" },
      ["n"] = { "nzzzv", "Next search result and center" },
      ["N"] = { "Nzzzv", "Previous search result and center" },
    })
    
    -- Clear search with Esc
    wk.register({
      ["<esc>"] = { "<cmd>noh<cr><esc>", "Escape and clear hlsearch" },
    }, { mode = { "i", "n" } })
    
    -- Save file
    wk.register({
      ["<C-s>"] = { "<cmd>w<cr><esc>", "Save file" },
    }, { mode = { "i", "x", "n", "s" } })
    
    -- Better indenting in visual mode
    wk.register({
      ["<"] = { "<gv", "Unindent line" },
      [">"] = { ">gv", "Indent line" },
      ["p"] = { '"_dP', "Better paste" },
    }, { mode = "v" })
  end,
}
