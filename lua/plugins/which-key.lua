return {
  "folke/which-key.nvim",
  dependencies = { "folke/snacks.nvim" },
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
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
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
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    
    -- Root groups
    wk.add({
      ["<leader>b"] = { name = "+Buffer" },
      ["<leader>c"] = { name = "+Code/LSP" },
      ["<leader>d"] = { name = "+Debug" },
      ["<leader>f"] = { name = "+Find/Telescope" },
      ["<leader>g"] = { name = "+Git" },
      ["<leader>h"] = { name = "+Git Hunks" },
      ["<leader>L"] = { name = "+Layouts" },
      ["<leader>n"] = { name = "+Noice/Notifications" },
      ["<leader>q"] = { name = "+Quit/Session" },
      ["<leader>s"] = { name = "+Stack-Specific" },
      ["<leader>t"] = { name = "+Terminal/Toggle" },
      ["<leader>u"] = { name = "+UI" },
      ["<leader>w"] = { name = "+Window" },
      ["<leader>x"] = { name = "+Diagnostics/Quickfix" },
      ["<leader>e"] = { name = "+Explorer" },
      ["["] = { name = "+Previous" },
      ["]"] = { name = "+Next" },
      ["g"] = { name = "+Goto/LSP" },
    })
      
    -- Buffer management
    wk.add({
      ["<leader>bb"] = { "<cmd>e #<cr>", "Switch to Other Buffer" },
      ["<leader>bd"] = { "<cmd>bdelete<cr>", "Delete Buffer" },
      ["<leader>bf"] = { "<cmd>bfirst<cr>", "First Buffer" },
      ["<leader>bh"] = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
      ["<leader>bl"] = { "<cmd>blast<cr>", "Last Buffer" },
      ["<leader>bn"] = { "<cmd>bnext<cr>", "Next Buffer" },
      ["<leader>bp"] = { "<cmd>bprevious<cr>", "Previous Buffer" },
      ["<leader>be"] = { "<cmd>Neotree buffers reveal float<cr>", "Buffer Explorer" },
    })
    
    -- Buffer navigation with Shift
    wk.add({
      ["<S-h>"] = { "<cmd>bprevious<cr>", "Previous buffer" },
      ["<S-l>"] = { "<cmd>bnext<cr>", "Next buffer" },
      ["[b"] = { "<cmd>bprevious<cr>", "Previous buffer" },
      ["]b"] = { "<cmd>bnext<cr>", "Next buffer" },
    })
    
    -- LSP and Code actions
    wk.add({
      ["<leader>ca"] = { vim.lsp.buf.code_action, "Code Action" },
      ["<leader>cd"] = { vim.diagnostic.open_float, "Line Diagnostics" },
      ["<leader>cf"] = { function() vim.lsp.buf.format({ async = true }) end, "Format" },
      ["<leader>cF"] = { "<cmd>FormatToggle<CR>", "Toggle Format on Save" },
      ["<leader>ci"] = { "<cmd>LspInfo<cr>", "LSP Info" },
      ["<leader>cl"] = { "<cmd>lua require('lint').try_lint()<cr>", "Trigger Linting" },
      ["<leader>cr"] = { vim.lsp.buf.rename, "Rename Symbol" },
      ["<leader>cs"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
      ["<leader>cS"] = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
      ["<leader>cR"] = { "<cmd>ReloadConfig<cr>", "Reload Config" },
    })
    
    -- GOTH stack specific
    wk.add({
      ["<leader>cg"] = { name = "+GOTH" },
      ["<leader>cgc"] = { function() require("config.utils").new_templ_component() end, "New Templ Component" },
      ["<leader>cgt"] = { "<cmd>!go test ./...<cr>", "Run Go Tests" },
      ["<leader>cgb"] = { "<cmd>!go build<cr>", "Go Build" },
      ["<leader>cgm"] = { "<cmd>!go mod tidy<cr>", "Go Mod Tidy" },
      ["<leader>cgr"] = { "<cmd>!go run .<cr>", "Go Run" },
    })
    
    -- Next.js specific
    wk.add({
      ["<leader>cn"] = { name = "+Next.js" },
      ["<leader>cnc"] = { function() require("config.utils").new_nextjs_component("client") end, "New Client Component" },
      ["<leader>cns"] = { function() require("config.utils").new_nextjs_component("server") end, "New Server Component" },
      ["<leader>cnp"] = { function() require("config.utils").new_nextjs_component("page") end, "New Page" },
      ["<leader>cnl"] = { function() require("config.utils").new_nextjs_component("layout") end, "New Layout" },
      ["<leader>cnb"] = { "<cmd>!npm run build<cr>", "Next.js Build" },
      ["<leader>cnd"] = { "<cmd>!npm run dev<cr>", "Next.js Dev" },
      ["<leader>cnt"] = { "<cmd>!npm test<cr>", "Run Tests" },
      ["<leader>cni"] = { "<cmd>!npm install<cr>", "NPM Install" },
    })
    
    -- Debug mode keymaps
    wk.add({
      ["<leader>db"] = { function() require("dap").toggle_breakpoint() end, "Toggle Breakpoint" },
      ["<leader>dB"] = { function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "Conditional Breakpoint" },
      ["<leader>dc"] = { function() require("dap").continue() end, "Continue" },
      ["<leader>dC"] = { function() require("dap").run_to_cursor() end, "Run to Cursor" },
      ["<leader>de"] = { function() require("dapui").eval() end, "Evaluate Expression" },
      ["<leader>di"] = { function() require("dap").step_into() end, "Step Into" },
      ["<leader>do"] = { function() require("dap").step_over() end, "Step Over" },
      ["<leader>dO"] = { function() require("dap").step_out() end, "Step Out" },
      ["<leader>dr"] = { function() require("dap").repl.toggle() end, "Toggle REPL" },
      ["<leader>dR"] = { function() require("dap").restart() end, "Restart" },
      ["<leader>dt"] = { function() require("dap").terminate() end, "Terminate" },
      ["<leader>du"] = { function() require("dapui").toggle() end, "Toggle UI" },
      ["<leader>dg"] = { function() _G.debug_goth_app() end, "Debug GOTH App" },
    })
    
    -- Function keys for debugging
    wk.add({
      ["<F5>"] = { function() require("dap").continue() end, "Continue" },
      ["<F10>"] = { function() require("dap").step_over() end, "Step Over" },
      ["<F11>"] = { function() require("dap").step_into() end, "Step Into" },
      ["<F12>"] = { function() require("dap").step_out() end, "Step Out" },
    })
    
    -- Telescope / Find
    wk.add({
      ["<leader>f/"] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find in Buffer" },
      ["<leader>fb"] = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
      ["<leader>fc"] = { "<cmd>Telescope commands<cr>", "Find Commands" },
      ["<leader>fC"] = { function() require("telescope.builtin").find_files({cwd = vim.fn.stdpath("config")}) end, "Find Config Files" },
      ["<leader>fd"] = { "<cmd>Telescope diagnostics bufnr=0<cr>", "Find Document Diagnostics" },
      ["<leader>fD"] = { "<cmd>Telescope diagnostics<cr>", "Find Workspace Diagnostics" },
      ["<leader>fe"] = { "<cmd>Telescope file_browser<cr>", "File Browser" },
      ["<leader>ff"] = { "<cmd>Telescope find_files<cr>", "Find Files" },
      ["<leader>fg"] = { "<cmd>Telescope live_grep<cr>", "Find Text (Grep)" },
      ["<leader>fh"] = { "<cmd>Telescope help_tags<cr>", "Find Help" },
      ["<leader>fk"] = { "<cmd>Telescope keymaps<cr>", "Find Keymaps" },
      ["<leader>fn"] = { "<cmd>Telescope file_browser<cr>", "Browse Next.js Project" },
      ["<leader>fo"] = { "<cmd>Telescope vim_options<cr>", "Find Options" },
      ["<leader>fp"] = { "<cmd>Telescope projects<cr>", "Find Projects" },
      ["<leader>fr"] = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
      ["<leader>fR"] = { "<cmd>Telescope frecency<cr>", "Frecent Files" },
      ["<leader>fs"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Find Document Symbols" },
      ["<leader>fS"] = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Find Workspace Symbols" },
      ["<leader>ft"] = { "<cmd>Telescope filetypes<cr>", "Find Filetypes" },
      ["<leader>fT"] = { "<cmd>Telescope builtin<cr>", "Find Telescope Pickers" },
      ["<leader>f."] = { "<cmd>Telescope resume<cr>", "Resume Last Search" },
    })
    
    -- Git commands
    wk.add({
      ["<leader>gb"] = { "<cmd>Telescope git_branches<cr>", "Git Branches" },
      ["<leader>gc"] = { "<cmd>Telescope git_commits<cr>", "Git Commits" },
      ["<leader>gd"] = { "<cmd>DiffviewOpen<cr>", "DiffView Open" },
      ["<leader>gD"] = { "<cmd>DiffviewClose<cr>", "DiffView Close" },
      ["<leader>ge"] = { "<cmd>Neotree git_status reveal float<cr>", "Git Explorer" },
      ["<leader>gg"] = { "<cmd>LazyGit<cr>", "Lazygit" },
      ["<leader>gh"] = { "<cmd>DiffviewFileHistory %<cr>", "File History" },
      ["<leader>gH"] = { "<cmd>DiffviewFileHistory<cr>", "Project History" },
      ["<leader>gl"] = { "<cmd>Git pull<cr>", "Git Pull" },
      ["<leader>gp"] = { "<cmd>Git push<cr>", "Git Push" },
      ["<leader>gs"] = { "<cmd>Telescope git_status<cr>", "Git Status" },
      ["<leader>go"] = { "<cmd>Octo<cr>", "Octo" },
      ["<leader>gi"] = { "<cmd>Octo issue list<cr>", "Issue List" },
      ["<leader>gr"] = { "<cmd>Octo pr list<cr>", "PR List" },
    })
    
    -- Git Signs / Hunks 
    wk.add({
      ["<leader>hb"] = { function() require("gitsigns").blame_line({ full = true }) end, "Blame Line" },
      ["<leader>hB"] = { function() require("gitsigns").toggle_current_line_blame() end, "Toggle Line Blame" },
      ["<leader>hd"] = { function() require("gitsigns").diffthis() end, "Diff This" },
      ["<leader>hD"] = { function() require("gitsigns").diffthis("~") end, "Diff This ~" },
      ["<leader>hp"] = { function() require("gitsigns").preview_hunk() end, "Preview Hunk" },
      ["<leader>hr"] = { function() require("gitsigns").reset_hunk() end, "Reset Hunk" },
      ["<leader>hR"] = { function() require("gitsigns").reset_buffer() end, "Reset Buffer" },
      ["<leader>hs"] = { function() require("gitsigns").stage_hunk() end, "Stage Hunk" },
      ["<leader>hS"] = { function() require("gitsigns").stage_buffer() end, "Stage Buffer" },
      ["<leader>hu"] = { function() require("gitsigns").stage_hunk() end, "Undo Stage Hunk" },
    })
    
    -- Noice and notifications
    wk.add({
      ["<leader>na"] = { function() require("noice").cmd("all") end, "Noice All" },
      ["<leader>nd"] = { function() require("noice").cmd("dismiss") end, "Dismiss All" },
      ["<leader>nh"] = { function() require("noice").cmd("history") end, "Noice History" },
      ["<leader>nl"] = { function() require("noice").cmd("last") end, "Noice Last Message" },
      ["<leader>ne"] = { function() require("noice").cmd("errors") end, "Noice Errors" },
      ["<leader>nn"] = { function() require("noice").cmd("telescope") end, "Telescope Noice" },
    })
    
    -- Quick exit and sessions
    wk.add({
      ["<leader>qq"] = { "<cmd>qa<cr>", "Quit All" },
      ["<leader>qw"] = { "<cmd>wqa<cr>", "Save and Quit All" },
      ["<leader>qs"] = { function() require("persistence").load() end, "Restore Session" },
      ["<leader>ql"] = { function() require("persistence").load({ last = true }) end, "Restore Last Session" },
      ["<leader>qd"] = { function() require("persistence").stop() end, "Don't Save Current Session" },
    })
    
    -- Stack-specific commands
    wk.add({
      ["<leader>sg"] = { name = "+GOTH Stack" },
      ["<leader>sgn"] = { function()
          vim.ui.input({ prompt = "Project name: " }, function(name)
            if name and name ~= "" then
              local Terminal = require("toggleterm.terminal").Terminal
              local goth_init = Terminal:new({
                cmd = string.format("mkdir -p %s && cd %s && go mod init %s && mkdir -p components handlers static", name, name, name),
                hidden = false,
                direction = "float",
                on_exit = function()
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
      ["<leader>sgr"] = { function()
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
      ["<leader>sgd"] = { "<cmd>DebugGOTHApp<cr>", "Debug GOTH App" },
      ["<leader>sgg"] = { "<cmd>!templ generate<cr>", "Generate Templ Files" },
      ["<leader>sgc"] = { function() require("config.utils").new_templ_component() end, "New Templ Component" },
      ["<leader>sgt"] = { "<cmd>!go test ./...<cr>", "Run Go Tests" },
      ["<leader>sgm"] = { "<cmd>!go mod tidy<cr>", "Go Mod Tidy" },
      ["<leader>sgb"] = { "<cmd>!go build<cr>", "Go Build" },
      ["<leader>sgp"] = { "<cmd>StackFocus goth<cr>", "Focus GOTH Stack" },
    })
    
    wk.add({
      ["<leader>sn"] = { name = "+Next.js Stack" },
      ["<leader>snn"] = { function()
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
      ["<leader>snd"] = { function()
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
      ["<leader>snb"] = { function()
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
      ["<leader>sns"] = { function()
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
      ["<leader>snt"] = { function()
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
      ["<leader>snl"] = { function()
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
      ["<leader>snc"] = { function() require("config.utils").new_nextjs_component("client") end, "New Client Component" },
      ["<leader>snS"] = { function() require("config.utils").new_nextjs_component("server") end, "New Server Component" },
      ["<leader>snp"] = { function() require("config.utils").new_nextjs_component("page") end, "New Page" },
      ["<leader>snL"] = { function() require("config.utils").new_nextjs_component("layout") end, "New Layout" },
      ["<leader>snf"] = { "<cmd>StackFocus nextjs<cr>", "Focus Next.js Stack" },
      ["<leader>sni"] = { function()
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
      ["<leader>snD"] = { function()
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
    })
    
    -- Shared commands
    wk.add({
      ["<leader>sr"] = { "<cmd>lua _G.toggle_htmx_server()<cr>", "Run Server" },
    })
    
    -- Terminal commands
    wk.add({
      ["<leader>tf"] = { "<cmd>ToggleTerm direction=float<cr>", "Terminal (float)" },
      ["<leader>th"] = { "<cmd>ToggleTerm direction=horizontal<cr>", "Terminal (horizontal)" },
      ["<leader>tv"] = { "<cmd>ToggleTerm direction=vertical<cr>", "Terminal (vertical)" },
      ["<leader>tt"] = { "<cmd>ToggleTerm<cr>", "Toggle terminal" },
      ["<leader>tb"] = { function() require("gitsigns").toggle_current_line_blame() end, "Toggle Line Blame" },
      ["<leader>td"] = { function() require("gitsigns").toggle_deleted() end, "Toggle Deleted" },
      ["<leader>tn"] = { function() _G.toggle_node() end, "Node Terminal" },
      ["<leader>tp"] = { function() _G.toggle_python() end, "Python Terminal" },
      ["<leader>tg"] = { function() _G.toggle_go() end, "Go Terminal" },
      ["<leader>ts"] = { function() _G.toggle_htmx_server() end, "HTMX Server" },
      ["<leader>tc"] = { function() require("config.utils").toggle_colorcolumn() end, "Toggle Color Column" },
      ["<leader>tw"] = { function() vim.wo.wrap = not vim.wo.wrap; vim.notify("Wrap " .. (vim.wo.wrap and "enabled" or "disabled")) end, "Toggle Wrap" },
      ["<leader>ta"] = { "<cmd>FormatToggle<cr>", "Toggle Auto Format (global)" },
      ["<leader>tA"] = { "<cmd>FormatToggleBuffer<cr>", "Toggle Auto Format (buffer)" },
    })
    
    -- UI toggles and commands
    wk.add({
      ["<leader>uc"] = { "<cmd>ColorSchemeToggle<cr>", "Toggle Colorscheme" },
      ["<leader>un"] = { function() require("notify").dismiss({ silent = true, pending = true }) end, "Dismiss Notifications" },
      ["<leader>ur"] = { "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", "Redraw / Clear Highlight" },
      ["<leader>ut"] = { "<cmd>ToggleTransparency<cr>", "Toggle Transparency" },
      ["<leader>uT"] = { "<cmd>ToggleTransparency<cr>", "Toggle Transparency" },
      ["<leader>ul"] = { "<cmd>Lazy<cr>", "Lazy Plugin Manager" },
      ["<leader>uL"] = { "<cmd>LazyUpdate<cr>", "Update Plugins" },
      ["<leader>um"] = { "<cmd>Mason<cr>", "Mason LSP Manager" },
      ["<leader>uM"] = { "<cmd>MasonUpdate<cr>", "Update LSP Servers" },
      ["<leader>uh"] = { "<cmd>ToggleInlayHints<CR>", "Toggle inlay hints" },
    })

    -- Windows management
    wk.add({
      ["<leader>w-"] = { "<C-W>s", "Split window below" },
      ["<leader>w|"] = { "<C-W>v", "Split window right" },
      ["<leader>w2"] = { "<C-W>v", "Layout double columns" },
      ["<leader>wh"] = { "<C-W>h", "Go to left window" },
      ["<leader>wj"] = { "<C-W>j", "Go to lower window" },
      ["<leader>wk"] = { "<C-W>k", "Go to upper window" },
      ["<leader>wl"] = { "<C-W>l", "Go to right window" },
      ["<leader>wq"] = { "<C-W>q", "Close window" },
      ["<leader>ww"] = { "<C-W>w", "Other window" },
      ["<leader>w="] = { "<C-W>=", "Balance windows" },
    })

    -- Diagnostics and quickfix
    wk.add({
      ["<leader>xx"] = { "<cmd>TroubleToggle<cr>", "Toggle Trouble" },
      ["<leader>xd"] = { "<cmd>TroubleToggle document_diagnostics<cr>", "Document Diagnostics" },
      ["<leader>xl"] = { "<cmd>TroubleToggle loclist<cr>", "Location List" },
      ["<leader>xq"] = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix List" },
      ["<leader>xt"] = { "<cmd>TodoTrouble<cr>", "Todo Trouble" },
      ["<leader>xT"] = { "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", "Todo/Fix/Fixme Trouble" },
      ["<leader>xw"] = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace Diagnostics" },
      ["<leader>xf"] = { function() require("config.utils").toggle_qf() end, "Toggle Quickfix" },
    })

    -- Navigation key pairs 
    wk.add({
      ["[b"] = { "<cmd>bprevious<cr>", "Previous Buffer" },
      ["[c"] = { function() require("gitsigns").prev_hunk() end, "Previous Hunk" },
      ["[d"] = { vim.diagnostic.goto_prev, "Previous Diagnostic" },
      ["[l"] = { "<cmd>lprev<cr>", "Previous Location" },
      ["[q"] = { "<cmd>cprev<cr>", "Previous Quickfix" },
      ["[t"] = { function() require("todo-comments").jump_prev() end, "Previous Todo" },
      
      ["]b"] = { "<cmd>bnext<cr>", "Next Buffer" },
      ["]c"] = { function() require("gitsigns").next_hunk() end, "Next Hunk" },
      ["]d"] = { vim.diagnostic.goto_next, "Next Diagnostic" },
      ["]l"] = { "<cmd>lnext<cr>", "Next Location" },
      ["]q"] = { "<cmd>cnext<cr>", "Next Quickfix" },
      ["]t"] = { function() require("todo-comments").jump_next() end, "Next Todo" },
    })

    -- Layout switcher
    wk.add({
      ["<leader>L1"] = { "<cmd>Layout coding<cr>", "Coding Layout" },
      ["<leader>L2"] = { "<cmd>Layout terminal<cr>", "Terminal Layout" },
      ["<leader>L3"] = { "<cmd>Layout writing<cr>", "Writing Layout" },
      ["<leader>L4"] = { "<cmd>Layout debug<cr>", "Debug Layout" },
    })

    -- LSP related keymaps
    wk.add({
      ["gd"] = { vim.lsp.buf.definition, "Go to Definition" },
      ["gD"] = { vim.lsp.buf.declaration, "Go to Declaration" },
      ["gr"] = { function() require("telescope.builtin").lsp_references() end, "Go to References" },
      ["gi"] = { vim.lsp.buf.implementation, "Go to Implementation" },
      ["gt"] = { vim.lsp.buf.type_definition, "Type Definition" },
      ["K"] = { vim.lsp.buf.hover, "Show Documentation" },
      ["<C-k>"] = { vim.lsp.buf.signature_help, "Signature Help" },
    })

    -- Explorer related keymaps
    wk.add({
      ["<leader>e"] = { function() require("config.utils").open_oil() end, "File Explorer (Oil)" },
      ["<leader>E"] = { function() require("config.utils").open_oil(nil, true) end, "File Explorer Float (Oil)" },
      ["-"] = { "<CMD>Oil<CR>", "Open parent directory" },
      ["_"] = { "<CMD>Oil .<CR>", "Open project root" },
    })

    -- Add Explorer section to root groups
    wk.add({
      ["<leader>f"] = { 
        name = "+Find/Telescope/Files",
        e = { function() require("config.utils").open_oil() end, "Oil Explorer" },
        E = { function() require("config.utils").open_oil(nil, true) end, "Oil Explorer (float)" },
        n = { "<cmd>Neotree toggle<cr>", "Neo-tree Explorer" },
        N = { "<cmd>Neotree float<cr>", "Neo-tree Explorer (float)" },
        t = { function() require("config.utils").toggle_explorer() end, "Toggle Explorer Type" },
        g = { function() require("snacks").picker.grep() end, "Live Grep" },
      },
    })

    -- Stack-specific oil commands
    wk.add({
      ["<leader>sg"] = { 
        name = "+GOTH Stack",
        -- Add oil commands for GOTH
        e = { function() require("config.utils").oil_goth(false) end, "GOTH Files (Oil)" },
        E = { function() require("config.utils").oil_goth(true) end, "GOTH Files (Oil float)" },
      },
      ["<leader>sn"] = {
        name = "+Next.js Stack",
        -- Add oil commands for Next.js
        e = { function() require("config.utils").oil_nextjs(false) end, "Next.js Files (Oil)" },
        E = { function() require("config.utils").oil_nextjs(true) end, "Next.js Files (Oil float)" },
      },
    })

    -- Move Lines (normal mode)
    wk.add({
      ["<A-j>"] = { "<cmd>m .+1<cr>==", "Move line down" },
      ["<A-k>"] = { "<cmd>m .-2<cr>==", "Move line up" },
    }, { mode = "n" })

    -- Move Lines (insert mode)
    wk.add({
      ["<A-j>"] = { "<esc><cmd>m .+1<cr>==gi", "Move line down" },
      ["<A-k>"] = { "<esc><cmd>m .-2<cr>==gi", "Move line up" },
    }, { mode = "i" })

    -- Move Lines (visual mode)
    wk.add({
      ["<A-j>"] = { ":m '>+1<cr>gv=gv", "Move selection down" },
      ["<A-k>"] = { ":m '<-2<cr>gv=gv", "Move selection up" },
    }, { mode = "v" })

    -- Better window navigation
    wk.add({
      ["<C-h>"] = { "<C-w>h", "Go to left window" },
      ["<C-j>"] = { "<C-w>j", "Go to lower window" },
      ["<C-k>"] = { "<C-w>k", "Go to upper window" },
      ["<C-l>"] = { "<C-w>l", "Go to right window" },
    })

    -- Resize window using <ctrl> arrow keys
    wk.add({
      ["<C-Up>"] = { "<cmd>resize +2<cr>", "Increase window height" },
      ["<C-Down>"] = { "<cmd>resize -2<cr>", "Decrease window height" },
      ["<C-Left>"] = { "<cmd>vertical resize -2<cr>", "Decrease window width" },
      ["<C-Right>"] = { "<cmd>vertical resize +2<cr>", "Increase window width" },
    })

    -- Clear search with <esc>
    wk.add({
      ["<esc>"] = { "<cmd>noh<cr><esc>", "Escape and clear hlsearch" },
    }, { mode = { "i", "n" } })

    -- Save file
    wk.add({
      ["<C-s>"] = { "<cmd>w<cr><esc>", "Save file" },
    }, { mode = { "i", "x", "n", "s" } })

    -- Better indenting
    wk.add({
      ["<"] = { "<gv", "Unindent line" },
      [">"] = { ">gv", "Indent line" },
    }, { mode = "v" })

    -- Paste over currently selected text without yanking it
    wk.add({
      ["p"] = { '"_dP', "Better paste" },
    }, { mode = "v" })

    -- Maintain cursor position when joining lines
    wk.add({
      ["J"] = { "mzJ`z", "Join lines and maintain cursor position" },
    })

    -- Better navigation
    wk.add({
      ["<C-d>"] = { "<C-d>zz", "Scroll down half a page and center" },
      ["<C-u>"] = { "<C-u>zz", "Scroll up half a page and center" },
      ["n"] = { "nzzzv", "Next search result and center" },
      ["N"] = { "Nzzzv", "Previous search result and center" },
    })
  end
}
