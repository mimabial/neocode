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
      filetypes = { "TelescopePrompt" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    
    -- Document existing key chains
    wk.register({
      -- Leader key groups
      ["<leader>"] = {
        b = { name = "+Buffer" },
        c = { name = "+Code/LSP" },
        d = { name = "+Debug" },
        f = { name = "+Find/Telescope" },
        g = { name = "+Git" },
        h = { name = "+Git Hunks" },
        l = { name = "+LSP" },
        n = { name = "+Noice/Notifications" },
        q = { name = "+Quit/Session" },
        r = { name = "+Rename/Replace" },
        s = { name = "+Stack-Specific" },
        t = { name = "+Terminal/Toggle" },
        u = { name = "+UI" },
        w = { name = "+Windows" },
        x = { name = "+Diagnostics/Quickfix" },
      },
      
      -- Stack-specific commands group
      ["<leader>s"] = {
        name = "+Stack-Specific",
        g = {
          name = "+GOTH Stack",
          c = { function() require("config.utils").new_templ_component() end, "New Templ Component" },
          p = { "<cmd>let g:current_stack='goth'<cr>", "Focus GOTH Stack" },
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
          f = { "<cmd>let g:current_stack='nextjs'<cr>", "Focus Next.js Stack" },
          d = { "<cmd>!npm run dev<cr>", "Next.js Dev" },
          b = { "<cmd>!npm run build<cr>", "Next.js Build" },
          t = { "<cmd>!npm test<cr>", "Run Tests" },
          i = { "<cmd>!npm install<cr>", "NPM Install" },
        },
      },
      
      -- Git related
      g = {
        name = "Goto/Git",
        d = { vim.lsp.buf.definition, "Go to definition" },
        D = { vim.lsp.buf.declaration, "Go to declaration" },
        r = { function() require("telescope.builtin").lsp_references() end, "Go to references" },
        i = { vim.lsp.buf.implementation, "Go to implementation" },
      },
      
      -- Brackets
      ["["] = { name = "Previous..." },
      ["]"] = { name = "Next..." },
    })
    
    -- Buffer commands
    wk.register({
      ["<leader>b"] = {
        ["b"] = { "<cmd>e #<cr>", "Switch to Other Buffer" },
        ["d"] = { "<cmd>bdelete<cr>", "Delete Buffer" },
        ["f"] = { "<cmd>bfirst<cr>", "First Buffer" },
        ["h"] = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
        ["l"] = { "<cmd>blast<cr>", "Last Buffer" },
        ["n"] = { "<cmd>bnext<cr>", "Next Buffer" },
        ["p"] = { "<cmd>bprevious<cr>", "Previous Buffer" },
        ["e"] = { "<cmd>Neotree buffers reveal float<cr>", "Buffer Explorer" },
      },
    })
    
    -- Code/LSP commands
    wk.register({
      ["<leader>c"] = {
        name = "Code/LSP",
        ["a"] = { vim.lsp.buf.code_action, "Code Action" },
        ["d"] = { vim.diagnostic.open_float, "Line Diagnostics" },
        ["f"] = { vim.lsp.buf.format, "Format" },
        ["F"] = { "<cmd>FormatToggle<CR>", "Toggle Format on Save" },
        ["i"] = { "<cmd>LspInfo<cr>", "LSP Info" },
        ["l"] = { "<cmd>lua require('lint').try_lint()<cr>", "Trigger Linting" },
        ["r"] = { vim.lsp.buf.rename, "Rename Symbol" },
        ["s"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
        ["S"] = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
        ["g"] = { 
          name = "+GOTH",
          ["c"] = { function() require("config.utils").new_templ_component() end, "New Templ Component" },
          ["t"] = { "<cmd>!go test ./...<cr>", "Run Go Tests" }, 
        },
        ["n"] = { 
          name = "+Next.js",
          ["c"] = { function() require("config.utils").new_nextjs_component("client") end, "New Client Component" },
          ["s"] = { function() require("config.utils").new_nextjs_component("server") end, "New Server Component" },
        },
      }
    })
    
    -- Debug commands
    wk.register({
      ["<leader>d"] = {
        name = "Debug",
        ["b"] = { function() require('dap').toggle_breakpoint() end, "Toggle Breakpoint" },
        ["B"] = { function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, "Conditional Breakpoint" },
        ["c"] = { function() require('dap').continue() end, "Continue" },
        ["C"] = { function() require('dap').run_to_cursor() end, "Run to Cursor" },
        ["e"] = { function() require('dapui').eval() end, "Evaluate Expression" },
        ["i"] = { function() require('dap').step_into() end, "Step Into" },
        ["o"] = { function() require('dap').step_over() end, "Step Over" },
        ["O"] = { function() require('dap').step_out() end, "Step Out" },
        ["r"] = { function() require('dap').repl.toggle() end, "Toggle REPL" },
        ["R"] = { function() require('dap').restart() end, "Restart" },
        ["t"] = { function() require('dap').terminate() end, "Terminate" },
        ["u"] = { function() require('dapui').toggle() end, "Toggle UI" },
      }
    })
    
    -- Find/Telescope commands
    wk.register({
      ["<leader>f"] = {
        name = "Find/Telescope",
        ["/"] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find in Buffer" },
        ["b"] = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
        ["c"] = { "<cmd>Telescope commands<cr>", "Find Commands" },
        ["C"] = { function() require("telescope.builtin").find_files({cwd = vim.fn.stdpath("config")}) end, "Find Config Files" },
        ["d"] = { "<cmd>Telescope diagnostics bufnr=0<cr>", "Find Document Diagnostics" },
        ["D"] = { "<cmd>Telescope diagnostics<cr>", "Find Workspace Diagnostics" },
        ["e"] = { "<cmd>Telescope file_browser<cr>", "File Browser" },
        ["f"] = { "<cmd>Telescope find_files<cr>", "Find Files" },
        ["g"] = { "<cmd>Telescope live_grep<cr>", "Find Text (Grep)" },
        ["h"] = { "<cmd>Telescope help_tags<cr>", "Find Help" },
        ["k"] = { "<cmd>Telescope keymaps<cr>", "Find Keymaps" },
        ["o"] = { "<cmd>Telescope vim_options<cr>", "Find Options" },
        ["p"] = { "<cmd>Telescope projects<cr>", "Find Projects" },
        ["r"] = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
        ["R"] = { "<cmd>Telescope frecency<cr>", "Frecent Files" },
        ["s"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Find Document Symbols" },
        ["S"] = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Find Workspace Symbols" },
        ["t"] = { "<cmd>Telescope filetypes<cr>", "Find Filetypes" },
        ["T"] = { "<cmd>Telescope builtin<cr>", "Find Telescope Pickers" },
        ["."] = { "<cmd>Telescope resume<cr>", "Resume Last Search" },
      }
    })
    
    -- Git commands
    wk.register({
      ["<leader>g"] = {
        name = "Git",
        ["b"] = { "<cmd>Telescope git_branches<cr>", "Git Branches" },
        ["c"] = { "<cmd>Telescope git_commits<cr>", "Git Commits" },
        ["d"] = { "<cmd>DiffviewOpen<cr>", "DiffView Open" },
        ["D"] = { "<cmd>DiffviewClose<cr>", "DiffView Close" },
        ["e"] = { "<cmd>Neotree git_status reveal float<cr>", "Git Explorer" },
        ["g"] = { "<cmd>LazyGit<cr>", "Lazygit" },
        ["h"] = { "<cmd>DiffviewFileHistory %<cr>", "File History" },
        ["H"] = { "<cmd>DiffviewFileHistory<cr>", "Project History" },
        ["l"] = { "<cmd>Git pull<cr>", "Git Pull" },
        ["p"] = { "<cmd>Git push<cr>", "Git Push" },
        ["s"] = { "<cmd>Telescope git_status<cr>", "Git Status" },
      }
    })
    
    -- Git Signs / Hunks 
    wk.register({
      ["<leader>h"] = {
        name = "Git Hunks",
        ["b"] = { function() require("gitsigns").blame_line({ full = true }) end, "Blame Line" },
        ["B"] = { function() require("gitsigns").toggle_current_line_blame() end, "Toggle Line Blame" },
        ["d"] = { function() require("gitsigns").diffthis() end, "Diff This" },
        ["D"] = { function() require("gitsigns").diffthis("~") end, "Diff This ~" },
        ["p"] = { function() require("gitsigns").preview_hunk() end, "Preview Hunk" },
        ["r"] = { function() require("gitsigns").reset_hunk() end, "Reset Hunk" },
        ["R"] = { function() require("gitsigns").reset_buffer() end, "Reset Buffer" },
        ["s"] = { function() require("gitsigns").stage_hunk() end, "Stage Hunk" },
        ["S"] = { function() require("gitsigns").stage_buffer() end, "Stage Buffer" },
        ["u"] = { function() require("gitsigns").undo_stage_hunk() end, "Undo Stage Hunk" },
      }
    })
    
    -- Terminal commands
    wk.register({
      ["<leader>t"] = {
        name = "Terminal/Toggle",
        ["f"] = { "<cmd>ToggleTerm direction=float<cr>", "Terminal (float)" },
        ["h"] = { "<cmd>ToggleTerm direction=horizontal<cr>", "Terminal (horizontal)" },
        ["v"] = { "<cmd>ToggleTerm direction=vertical<cr>", "Terminal (vertical)" },
        ["t"] = { "<cmd>ToggleTerm<cr>", "Toggle terminal" },
        ["b"] = { function() require("gitsigns").toggle_current_line_blame() end, "Toggle Line Blame" },
        ["d"] = { function() require("gitsigns").toggle_deleted() end, "Toggle Deleted" },
        ["n"] = { function() _G.toggle_node() end, "Node Terminal" },
        ["p"] = { function() _G.toggle_python() end, "Python Terminal" },
        ["c"] = { function() require("config.utils").toggle_colorcolumn() end, "Toggle Color Column" },
        ["w"] = { function() vim.wo.wrap = not vim.wo.wrap; vim.notify("Wrap " .. (vim.wo.wrap and "enabled" or "disabled")) end, "Toggle Wrap" },
        ["a"] = { "<cmd>FormatToggle<cr>", "Toggle Auto Format (global)" },
        ["A"] = { "<cmd>FormatToggleBuffer<cr>", "Toggle Auto Format (buffer)" },
      }
    })
    
    -- UI toggles and commands
    wk.register({
      ["<leader>u"] = {
        name = "UI",
        ["c"] = { "<cmd>ColorSchemeToggle<cr>", "Toggle Colorscheme" },
        ["n"] = { function() require("notify").dismiss({ silent = true, pending = true }) end, "Dismiss Notifications" },
        ["r"] = { "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", "Redraw / Clear Highlight" },
        ["t"] = { "<cmd>ToggleTransparency<cr>", "Toggle Transparency" },
        ["l"] = { "<cmd>Lazy<cr>", "Lazy Plugin Manager" },
        ["L"] = { "<cmd>LazyUpdate<cr>", "Update Plugins" },
        ["m"] = { "<cmd>Mason<cr>", "Mason LSP Manager" },
        ["M"] = { "<cmd>MasonUpdate<cr>", "Update LSP Servers" },
      }
    })
    
    -- Windows management
    wk.register({
      ["<leader>w"] = {
        name = "Window",
        ["-"] = { "<C-W>s", "Split window below" },
        ["|"] = { "<C-W>v", "Split window right" },
        ["2"] = { "<C-W>v", "Layout double columns" },
        ["h"] = { "<C-W>h", "Go to left window" },
        ["j"] = { "<C-W>j", "Go to lower window" },
        ["k"] = { "<C-W>k", "Go to upper window" },
        ["l"] = { "<C-W>l", "Go to right window" },
        ["q"] = { "<C-W>q", "Close window" },
        ["w"] = { "<C-W>w", "Other window" },
        ["="] = { "<C-W>=", "Balance windows" },
      }
    })
    
    -- Diagnostics and quickfix
    wk.register({
      ["<leader>x"] = {
        name = "Diagnostics/Quickfix",
        ["d"] = { "<cmd>TroubleToggle document_diagnostics<cr>", "Document Diagnostics" },
        ["l"] = { "<cmd>TroubleToggle loclist<cr>", "Location List" },
        ["q"] = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix List" },
        ["t"] = { "<cmd>TodoTrouble<cr>", "Todo Trouble" },
        ["T"] = { "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", "Todo/Fix/Fixme Trouble" },
        ["w"] = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace Diagnostics" },
        ["x"] = { "<cmd>TroubleToggle<cr>", "Toggle Trouble" },
        ["f"] = { function() require("config.utils").toggle_qf() end, "Toggle Quickfix" },
      }
    })
    
    -- Navigation key pairs 
    wk.register({
      ["["] = {
        ["b"] = { "<cmd>bprevious<cr>", "Previous Buffer" },
        ["c"] = { function() require("gitsigns").prev_hunk() end, "Previous Hunk" },
        ["d"] = { vim.diagnostic.goto_prev, "Previous Diagnostic" },
        ["l"] = { "<cmd>lprev<cr>", "Previous Location" },
        ["q"] = { "<cmd>cprev<cr>", "Previous Quickfix" },
        ["t"] = { function() require("todo-comments").jump_prev() end, "Previous Todo" },
      },
      ["]"] = {
        ["b"] = { "<cmd>bnext<cr>", "Next Buffer" },
        ["c"] = { function() require("gitsigns").next_hunk() end, "Next Hunk" },
        ["d"] = { vim.diagnostic.goto_next, "Next Diagnostic" },
        ["l"] = { "<cmd>lnext<cr>", "Next Location" },
        ["q"] = { "<cmd>cnext<cr>", "Next Quickfix" },
        ["t"] = { function() require("todo-comments").jump_next() end, "Next Todo" },
      },
    })
    
    -- Layout switcher
    wk.register({
      ["<leader>L"] = {
        name = "Layouts",
        ["1"] = { "<cmd>Layout coding<cr>", "Coding Layout" },
        ["2"] = { "<cmd>Layout terminal<cr>", "Terminal Layout" },
        ["3"] = { "<cmd>Layout writing<cr>", "Writing Layout" },
        ["4"] = { "<cmd>Layout debug<cr>", "Debug Layout" },
      },
    })
    
    -- Function keys for debugging
    wk.register({
      ["<F5>"] = { function() require("dap").continue() end, "Debug: Continue" },
      ["<F10>"] = { function() require("dap").step_over() end, "Debug: Step Over" },
      ["<F11>"] = { function() require("dap").step_into() end, "Debug: Step Into" },
      ["<F12>"] = { function() require("dap").step_out() end, "Debug: Step Out" },
    })
    
    -- LSP related keymaps
    wk.register({
      ["g"] = {
        ["d"] = { vim.lsp.buf.definition, "Go to Definition" },
        ["D"] = { vim.lsp.buf.declaration, "Go to Declaration" },
        ["r"] = { function() require("telescope.builtin").lsp_references() end, "Go to References" },
        ["i"] = { vim.lsp.buf.implementation, "Go to Implementation" },
        ["K"] = { vim.lsp.buf.hover, "Show Documentation" },
      },
    })
    
    -- Additional key mappings
    vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Lazygit" })
    vim.keymap.set("n", "<leader>ut", "<cmd>ColorSchemeToggle<cr>", { desc = "Toggle colorscheme" })
    vim.keymap.set("n", "<leader>uT", "<cmd>ToggleTransparency<cr>", { desc = "Toggle transparency" })
    vim.keymap.set("n", "<leader>cr", "<cmd>ReloadConfig<cr>", { desc = "Reload config" })
  end,
}
