-- lua/plugins/goth.lua
return {
  -- Templ syntax support
  {
    "joerdav/templ.vim",
    ft = "templ",
    priority = 90,
  },
  
  -- Live HTML/Templ preview
  {
    "turbio/bracey.vim",
    build = "npm install --prefix server",
    cmd = { "Bracey", "BraceyStop", "BraceyReload" },
    -- Fix for local changes issue
    init = function()
      local server_dir = vim.fn.stdpath("data") .. "/lazy/bracey.vim/server"
      if vim.fn.isdirectory(server_dir) == 1 then
        local lock_file = server_dir .. "/package-lock.json"
        if vim.fn.filereadable(lock_file) == 1 then
          local gitignore = server_dir .. "/.gitignore"
          if vim.fn.filereadable(gitignore) == 0 then
            vim.fn.writefile({ "package-lock.json" }, gitignore)
          else
            local lines = vim.fn.readfile(gitignore)
            local found = false
            for _, line in ipairs(lines) do
              if line == "package-lock.json" then
                found = true
                break
              end
            end
            if not found then
              table.insert(lines, "package-lock.json")
              vim.fn.writefile(lines, gitignore)
            end
          end
        end
      end
    end,
    priority = 70,
  },
  
  -- Comprehensive Go support
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lsp_cfg = true,
      lsp_on_attach = function(client, bufnr)
        -- Custom on_attach to enhance Go development experience
        local wk = require("which-key")
        wk.register({
          ["<leader>sg"] = {
            name = "Go",
            a = { "<cmd>GoAlt<cr>", "Go to alternate file" },
            A = { "<cmd>GoAltV<cr>", "Go to alternate file in vsplit" },
            t = { "<cmd>GoTest<cr>", "Test function" },
            T = { "<cmd>GoTestFunc<cr>", "Test file" },
            c = { "<cmd>GoCoverage<cr>", "Test coverage" },
            C = { "<cmd>GoCoverageToggle<cr>", "Toggle coverage" },
            i = { "<cmd>GoImports<cr>", "Organize imports" },
            I = { "<cmd>GoImpl<cr>", "Generate interface implementation" },
            l = { "<cmd>GoLint<cr>", "Run linter" },
            m = { "<cmd>GoModTidy<cr>", "Go mod tidy" },
            r = { "<cmd>GoRun<cr>", "Run current file" },
            s = { "<cmd>GoFillStruct<cr>", "Fill struct" },
            e = { "<cmd>GoIfErr<cr>", "Add if err" },
            d = { "<cmd>GoDoc<cr>", "Show documentation" },
            v = { "<cmd>GoVet<cr>", "Go vet" },
            p = { "<cmd>GoPkgOutline<cr>", "Package outline" },
            g = { "<cmd>GoGenerate<cr>", "Go generate" },
            j = { "<cmd>GoAddTag json<cr>", "Add JSON tags" },
            y = { "<cmd>GoAddTag yaml<cr>", "Add YAML tags" },
          },
        }, { buffer = bufnr })
      end,
      lsp_document_formatting = true,
      lsp_inlay_hints = {
        enable = true,
      },
      luasnip = true,
      trouble = true,
      dap_debug = true,
      dap_debug_gui = true,
      gocoverage_sign = "│",
      test_runner = "go",
      run_in_floaterm = true,
      test_efm = true, -- ErrorFormat for go test
      lsp_keymaps = false, -- use custom keymaps
      lsp_codelens = true,
      diagnostic = {
        hdlr = true, -- hook lsp diagnostic handler
        underline = true,
        virtual_text = true,
        signs = true,
        update_in_insert = false,
      },
      gopls_cmd = { "gopls" },
      gopls_remote_auto = true,
      fillstruct = "gopls",
      gofmt = "gofumpt", -- gofumpt + goimports
      log_path = vim.fn.expand("$HOME") .. "/tmp/gonvim.log",
    },
    event = { "CmdlineEnter", "BufReadPost", "BufNewFile" },
    ft = { "go", "gomod", "gosum", "gowork", "gotmpl", "gohtmltmpl", "templ" },
    config = function(_, opts)
      require("go").setup(opts)
      
      -- Create command to run the current Go project
      vim.api.nvim_create_user_command("GoRun", function()
        local Terminal = require("toggleterm.terminal").Terminal
        local go_run = Terminal:new({
          cmd = "go run .",
          direction = "float",
          close_on_exit = false,
          on_open = function(term)
            vim.cmd("startinsert!")
          end,
        })
        go_run:toggle()
      end, { desc = "Run Go project" })
      
      -- Create command to start a GOTH server (go run + templ generate)
      vim.api.nvim_create_user_command("GOTHServer", function()
        local Terminal = require("toggleterm.terminal").Terminal
        local goth_server = Terminal:new({
          -- First generate templ files, then run
          cmd = "templ generate && go run .",
          direction = "float",
          close_on_exit = false,
          on_open = function(term)
            vim.cmd("startinsert!")
            vim.notify("Starting GOTH server...", vim.log.levels.INFO)
          end,
        })
        goth_server:toggle()
      end, { desc = "Start GOTH server" })
    end,
    build = ':lua require("go.install").update_all_sync()',
    priority = 80,
  },

  -- Enhanced formatter config for Templ files
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        templ = { "templ" },
        go = { "gofumpt", "goimports" },
      },
      formatters = {
        templ = {
          command = "templ",
          args = function()
            -- Newer versions use `fmt -` for stdin
            -- Check templ version
            local version_output = vim.fn.system("templ version 2>&1") or ""
            if version_output:match("v0%.2") or version_output:match("v1%.") then
              return { "fmt", "-" }
            else
              return { "fmt", "$FILENAME" }
            end
          end,
          stdin = function()
            -- Support stdin for newer versions
            local version_output = vim.fn.system("templ version 2>&1") or ""
            return version_output:match("v0%.2") or version_output:match("v1%.")
          end,
        },
        gofumpt = {
          command = "gofumpt",
          args = { "-l", "-w", "$FILENAME" },
          stdin = false,
        },
        goimports = {
          command = "goimports",
          args = { "-w", "$FILENAME" },
          stdin = false,
        },
      },
    },
    priority = 50,
  },
  
  -- Enhance tree-sitter for Go/Templ
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "go", "gomod", "gosum", "gowork", "html", "css"
        })
      end
      
      -- Add templ parser configuration
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      
      -- Make sure templ parser is properly configured
      parser_config.templ = {
        install_info = {
          url = "https://github.com/vrischmann/tree-sitter-templ.git",
          files = {"src/parser.c", "src/scanner.c"},
          branch = "master",
        },
        filetype = "templ",
      }
      
      -- Add HTMX queries for syntax highlighting
      local htmx_queries = [[
        ;; HTMX attributes
        ((attribute
          (attribute_name) @_attr_name
          (attribute_value) @attribute.htmx)
         (#match? @_attr_name "^hx-"))

        ;; Tag with HTMX attributes
        ((element
          (start_tag
            (attribute
              (attribute_name) @_attr_name)))
         (#match? @_attr_name "^hx-")
         ;; Label this tag node
         @tag.htmx)
      ]]
      
      -- Try to safely add the queries
      local ok, queries = pcall(require, "nvim-treesitter.query")
      if ok and queries then
        local query_path = vim.fn.stdpath("config") .. "/queries/html/highlights.scm"
        vim.fn.mkdir(vim.fn.fnamemodify(query_path, ":h"), "p")
        if not vim.loop.fs_stat(query_path) then
          local file = io.open(query_path, "w")
          if file then
            file:write(htmx_queries)
            file:close()
            vim.notify("Added HTMX queries for syntax highlighting", vim.log.levels.INFO)
          end
        end
      end
    end,
    priority = 65,
  },
  
  -- Go debugging support
  {
    "leoluz/nvim-dap-go",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("dap-go").setup({
        dap_configurations = {
          {
            type = "go",
            name = "Debug GOTH app",
            request = "launch",
            program = "${workspaceFolder}/main.go",
          },
          {
            type = "go",
            name = "Debug test",
            request = "launch",
            mode = "test",
            program = "${file}",
          },
          {
            type = "go",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}",
          },
        },
        delve = {
          path = "dlv",
          initialize_timeout_sec = 20,
          port = "${port}",
          args = {},
          build_flags = "",
        },
      })
      
      -- Create a command to debug the GOTH app 
      vim.api.nvim_create_user_command("GOTHDebug", function()
        local dap = require("dap")
        
        -- Try to find main.go
        local main_file = vim.fn.findfile("main.go", vim.fn.getcwd() .. "/**")
        if main_file == "" then
          vim.notify("Could not find main.go file to debug", vim.log.levels.ERROR)
          return
        end
        
        -- Configure and start debugging
        dap.configurations.go = {
          {
            type = "go",
            name = "Debug GOTH App",
            request = "launch",
            program = main_file,
            buildFlags = "",
          }
        }
        
        -- Run templ generate first
        local result = vim.fn.system("templ generate")
        if vim.v.shell_error ~= 0 then
          vim.notify("Error generating templ files: " .. result, vim.log.levels.ERROR)
          return
        end
        
        dap.continue()
      end, { desc = "Debug GOTH Application" })
      
      -- Add keymapping for GOTH debugging
      vim.keymap.set("n", "<leader>dg", "<cmd>GOTHDebug<CR>", { desc = "Debug GOTH App" })
    end,
    ft = { "go", "templ" },
    priority = 70,
  },
  
  -- Add utility functions specific to GOTH stack
  {
    "nvim-lua/plenary.nvim",
    optional = true,
    config = function()
      -- Create a utility function to create templ components
      _G.new_templ_component = function()
        -- Get the component name from user input
        local component_name = vim.fn.input("Component Name: ")
        if component_name == "" then
          vim.notify("Component name cannot be empty", vim.log.levels.ERROR)
          return
        end
        
        -- Create a new buffer
        local bufnr = vim.api.nvim_create_buf(true, false)
        
        -- Set buffer name
        vim.api.nvim_buf_set_name(bufnr, component_name .. ".templ")
        
        -- Set filetype
        vim.api.nvim_buf_set_option(bufnr, "filetype", "templ")
        
        -- Generate component content
        local content = {
          "package components",
          "",
          "type " .. component_name .. "Props struct {",
          "  // Add props here",
          "}",
          "",
          "templ " .. component_name .. "(props " .. component_name .. "Props) {",
          "  <div>",
          "    <h1>" .. component_name .. " Component</h1>",
          "    <p>Content goes here</p>",
          "  </div>",
          "}"
        }
        
        -- Set buffer content
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
        
        -- Open the buffer in the current window
        vim.api.nvim_win_set_buf(0, bufnr)
        
        -- Position cursor at the props section
        vim.api.nvim_win_set_cursor(0, {4, 0})
        
        -- Enter insert mode
        vim.cmd("startinsert!")
      end
      
      -- Create a command to create a new templ component
      vim.api.nvim_create_user_command("TemplNew", function()
        _G.new_templ_component()
      end, { desc = "Create a new Templ component" })
      
      -- Create a command to reload all templ files
      vim.api.nvim_create_user_command("TemplReload", function()
        local result = vim.fn.system("templ generate")
        if vim.v.shell_error ~= 0 then
          vim.notify("Error generating templ files: " .. result, vim.log.levels.ERROR)
        else
          vim.notify("Templ files regenerated", vim.log.levels.INFO)
        end
      end, { desc = "Regenerate all Templ files" })
      
      -- Add GOTH stack keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go", "templ" },
        callback = function()
          vim.keymap.set("n", "<leader>sgr", "<cmd>GoRun<CR>", { buffer = true, desc = "Run Go project" })
          vim.keymap.set("n", "<leader>sgs", "<cmd>GOTHServer<CR>", { buffer = true, desc = "Start GOTH server" })
          vim.keymap.set("n", "<leader>sgd", "<cmd>GOTHDebug<CR>", { buffer = true, desc = "Debug GOTH project" })
          vim.keymap.set("n", "<leader>sgt", "<cmd>TemplNew<CR>", { buffer = true, desc = "New Templ component" })
          vim.keymap.set("n", "<leader>sgR", "<cmd>TemplReload<CR>", { buffer = true, desc = "Reload Templ files" })
        end
      })
    end,
    priority = 60,
  },
  
  -- Create snippets directory and file for Go and Templ
  {
    "nvim-lua/plenary.nvim",
    optional = true,
    config = function()
      -- Create snippets directory if it doesn't exist
      local snippets_dir = vim.fn.stdpath("config") .. "/snippets"
      if vim.fn.isdirectory(snippets_dir) == 0 then
        vim.fn.mkdir(snippets_dir, "p")
      end
      
      -- Create Go snippets file
      local go_snippets_file = snippets_dir .. "/go.lua"
      if vim.fn.filereadable(go_snippets_file) == 0 then
        local file = io.open(go_snippets_file, "w")
        if file then
          file:write([[
-- Go snippets for GOTH stack
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local snippets = {
  -- HTTP Handler
  s("handler", {
    t({"func "}), i(1, "HandlerName"), t({" (w http.ResponseWriter, r *http.Request) {", "\t"}),
    i(0, "// Implementation"),
    t({"", "}"})
  }),
  
  -- Error handling
  s("iferr", {
    t({"if err != nil {", "\t"}),
    i(1, "return err"),
    t({"", "}"})
  }),
  
  -- Templ component handler
  s("templhandler", {
    t({"func "}), i(1, "HandlerName"), t({" (w http.ResponseWriter, r *http.Request) {", "\t"}),
    t({"// Call templ component", "\tcomponents."}), i(2, "Component"), t({"("}), i(3, ""), t({").Render(r.Context(), w)"}),
    t({"", "}"})
  }),
  
  -- Main function for GOTH app
  s("gothmain", {
    t({"package main", "", "import (", "\t\"log\"", "\t\"net/http\"", "", "\t\""}), 
    i(1, "github.com/username/project"), t({"/components\"", "\t\""}),
    f(function(args) return args[1][1] end, {1}), t({"/handlers\"", ")", "", "func main() {", "\t// Setup routes", "\tmux := http.NewServeMux()", "\t"}),
    i(2, "mux.HandleFunc(\"/\", handlers.Index)"),
    t({"\t", "\t// Serve static files", "\tfs := http.FileServer(http.Dir(\"static\"))", "\tmux.Handle(\"/static/\", http.StripPrefix(\"/static/\", fs))", "\t", "\t// Start server", "\tlog.Println(\"Server starting on :"}), i(3, "3000"), t({"...\")", "\tif err := http.ListenAndServe(\":"}), 
    f(function(args) return args[1][1] end, {3}), t({"\", mux); err != nil {", "\t\tlog.Fatal(err)", "\t}", "}"})
  }),
}

return snippets
]])
          file:close()
          vim.notify("Created Go snippets file", vim.log.levels.INFO)
        end
      end
      
      -- Create Templ snippets file
      local templ_snippets_file = snippets_dir .. "/templ.lua"
      if vim.fn.filereadable(templ_snippets_file) == 0 then
        local file = io.open(templ_snippets_file, "w")
        if file then
          file:write([[
-- Templ snippets for GOTH stack
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local snippets = {
  -- Basic component
  s("component", {
    t({"package components", "", "type "}), i(1, "Component"), t({"Props struct {", "\t"}),
    i(2, "// Props"),
    t({"", "}", "", "templ "}), f(function(args) return args[1][1] end, {1}), t({" (props "}), f(function(args) return args[1][1] end, {1}), t({"Props) {", "\t"}),
    i(0, "<div>Component content</div>"),
    t({"", "}"})
  }),
  
  -- Layout component
  s("layout", {
    t({"package components", "", "type LayoutProps struct {", "\tTitle string", "\tContent templ.Component", "}", "", "templ Layout(props LayoutProps) {", "\t<!DOCTYPE html>", "\t<html lang=\"en\">", "\t\t<head>", "\t\t\t<meta charset=\"UTF-8\"/>", "\t\t\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"/>", "\t\t\t<title>{ props.Title }</title>", "\t\t\t<script src=\"https://unpkg.com/htmx.org@1.9.4\"></script>", "\t\t\t<script src=\"https://cdn.tailwindcss.com\"></script>", "\t\t</head>", "\t\t<body class=\"bg-gray-100 min-h-screen\">", "\t\t\t<main class=\"container mx-auto p-4\">", "\t\t\t\t{ props.Content }", "\t\t\t</main>", "\t\t</body>", "\t</html>", "}"})
  }),

  -- HTMX snippets
  s("hx-get", {
    t("hx-get=\""), i(1, "/path"), t("\"")
  }),
  s("hx-post", {
    t("hx-post=\""), i(1, "/path"), t("\"")
  }),
  s("hx-put", {
    t("hx-put=\""), i(1, "/path"), t("\"")
  }),
  s("hx-delete", {
    t("hx-delete=\""), i(1, "/path"), t("\"")
  }),
  s("hx-patch", {
    t("hx-patch=\""), i(1, "/path"), t("\"")
  }),
  s("hx-trigger", {
    t("hx-trigger=\""), i(1, "event"), t("\"")
  }),
  s("hx-swap", {
    t("hx-swap=\""), i(1, "innerHTML"), t("\"")
  }),
  s("hx-target", {
    t("hx-target=\""), i(1, "#id"), t("\"")
  }),
  s("hx-boost", {
    t("hx-boost=\""), i(1, "true"), t("\"")
  }),
  
  -- Form snippet with HTMX
  s("form", {
    t({"<form hx-post=\""}), i(1, "/path"), t({"\" hx-swap=\"outerHTML\">", "\t"}),
    i(2, "<input type=\"text\" name=\"name\" />"),
    t({"", "\t<button type=\"submit\" class=\"px-4 py-2 bg-blue-500 text-white rounded\">Submit</button>", "</form>"})
  }),
  
  -- Button with HTMX
  s("button", {
    t({"<button", "\tclass=\"px-4 py-2 bg-blue-500 hover:bg-blue-700 text-white font-bold rounded\"", "\thx-"}), i(1, "post"), t({"=\""}), i(2, "/path"), t({"\"", "\thx-swap=\"outerHTML\"", ">"}),
    i(3, "Button Text"),
    t({"</button>"})
  }),
}

return snippets
]])
          file:close()
          vim.notify("Created Templ snippets file", vim.log.levels.INFO)
        end
      end
    end,
  },
}
