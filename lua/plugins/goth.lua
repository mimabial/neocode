return {
  -- Add custom formatter config for Templ files
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
          args = { "fmt", "$FILENAME" },
          stdin = false,
        },
        gofumpt = {
          command = "gofumpt",
          args = { "-l", "-w", "$FILENAME" },
          stdin = false,
        },
      },
    },
  },

  -- Show HTML preview (useful for HTMX development)

  {
    "turbio/bracey.vim",
    build = "npm install --prefix server",
    cmd = { "Bracey", "BraceyStop", "BraceyReload" },
    -- Fix for local changes issue
    init = function()
      -- Create the directory if it doesn't exist
      local server_dir = vim.fn.stdpath("data") .. "/lazy/bracey.vim/server"
      if vim.fn.isdirectory(server_dir) == 1 then
        -- Check if package-lock.json exists and has local changes
        local lock_file = server_dir .. "/package-lock.json"
        if vim.fn.filereadable(lock_file) == 1 then
          -- Add to gitignore if needed
          local gitignore = server_dir .. "/.gitignore"
          if vim.fn.filereadable(gitignore) == 0 then
            local f = io.open(gitignore, "w")
            if f then
              f:write("package-lock.json\n")
              f:close()
            end
          else
            -- Append to existing gitignore if package-lock.json is not there
            local has_lockfile = false
            for line in io.lines(gitignore) do
              if line == "package-lock.json" then
                has_lockfile = true
                break
              end
            end
            
            if not has_lockfile then
              local f = io.open(gitignore, "a")
              if f then
                f:write("\npackage-lock.json\n")
                f:close()
              end
            end
          end
        end
      end
    end,
  },

  -- Templ syntax support
  {
    "joerdav/templ.vim",
    ft = "templ",
  },
  
  -- Go comprehensive support
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
    end,
    build = ':lua require("go.install").update_all_sync()',
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
      
      -- Add custom query for HTMX attributes
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
    end,
  },
  
  -- Provide visual components for Templ files (preview)
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    opts = {
      color_square_width = 2,
    },
  },
  
  -- Add HTMX snippets for GOTH stack
  {
    "L3MON4D3/LuaSnip",
    config = function(_, _)
      require("luasnip.loaders.from_vscode").lazy_load()
      
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      
      -- HTMX specific snippets
      ls.add_snippets("html", {
        s("hx-get", {
          t('hx-get="'),
          i(1, "/path"),
          t('"'),
        }),
        s("hx-post", {
          t('hx-post="'),
          i(1, "/path"),
          t('"'),
        }),
        s("hx-put", {
          t('hx-put="'),
          i(1, "/path"),
          t('"'),
        }),
        s("hx-delete", {
          t('hx-delete="'),
          i(1, "/path"),
          t('"'),
        }),
        s("hx-patch", {
          t('hx-patch="'),
          i(1, "/path"),
          t('"'),
        }),
        s("hx-trigger", {
          t('hx-trigger="'),
          i(1, "event"),
          t('"'),
        }),
        s("hx-swap", {
          t('hx-swap="'),
          i(1, "innerHTML"),
          t('"'),
        }),
        s("hx-target", {
          t('hx-target="'),
          i(1, "#id"),
          t('"'),
        }),
        s("hx-boost", {
          t('hx-boost="'),
          i(1, "true"),
          t('"'),
        }),
        s("hx-push-url", {
          t('hx-push-url="'),
          i(1, "true"),
          t('"'),
        }),
        s("hx-select", {
          t('hx-select="'),
          i(1, "#id"),
          t('"'),
        }),
        s("hx-confirm", {
          t('hx-confirm="'),
          i(1, "Are you sure?"),
          t('"'),
        }),
      })
      
      -- Templ specific snippets
      ls.add_snippets("templ", {
        -- Templ component
        s("templ-component", {
          t({"package components", "", ""}),
          t({"type "}), i(1, "ComponentName"), t({"Props struct {", "  "}),
          i(2, "// props here"),
          t({"", "}", "", ""}),
          t({"templ "}), f(function(args) return args[1][1] end, {1}), t({" (props "}), f(function(args) return args[1][1] end, {1}), t({"Props) {", "  "}),
          i(0, "<div>Component content here</div>"),
          t({"", "}"})
        }),
        
        -- Import React component in Templ
        s("templ-react", {
          t({"package components", "", ""}),
          t({"import \"github.com/a-h/templ\""}),
          t({"", "", "script reactComponent() {", "  "}),
          i(1, "// React component code here"),
          t({"", "}", "", ""}),
          t({"templ "}), i(2, "ComponentName"), t({" () {", "  "}),
          t({"<div>"}),
          t({"  <script>"}),
          t({"    reactComponent()"}),
          t({"  </script>"}),
          i(0, "  <div id=\"react-root\"></div>"),
          t({"</div>"}),
          t({"", "}"})
        }),
        
        -- Form snippet for Templ
        s("templ-form", {
          t({"<form hx-post=\""}), i(1, "/path"), t({"\" hx-swap=\"outerHTML\">", "  "}),
          i(2, "<input type=\"text\" name=\"name\" />"),
          t({"", "  <button type=\"submit\">Submit</button>", "</form>"})
        }),
        
        -- HTMX snippets for Templ
        s("hx-get", {
          t('hx-get="'),
          i(1, "/path"),
          t('"'),
        }),
        s("hx-post", {
          t('hx-post="'),
          i(1, "/path"),
          t('"'),
        }),
        s("hx-trigger", {
          t('hx-trigger="'),
          i(1, "event"),
          t('"'),
        }),
        s("hx-swap", {
          t('hx-swap="'),
          i(1, "innerHTML"),
          t('"'),
        }),
        s("hx-target", {
          t('hx-target="'),
          i(1, "#id"),
          t('"'),
        }),
        
        -- Go snippets for Templ handlers
        s("go-handler", {
          t({"package handlers", "", ""}),
          t({"import (", "\t\"net/http\"", "", "\t\""}), i(1, "github.com/username/project"), t({"/components\"", ")", "", ""}),
          t({"func "}), i(2, "HandlerName"), t({" (w http.ResponseWriter, r *http.Request) {", "\t"}),
          i(0, "// Handler logic"),
          t({"", "}"})
        }),
        
        -- Go HTTP handler with Templ
        s("go-templ-handler", {
          t({"package handlers", "", ""}),
          t({"import (", "\t\"net/http\"", "", "\t\""}), i(1, "github.com/username/project"), t({"/components\"", ")", "", ""}),
          t({"func "}), i(2, "HandlerName"), t({" (w http.ResponseWriter, r *http.Request) {", "\t"}),
          t({"// Create component data", "\tdata := struct{", "\t\t"}), i(3, "Title string"), 
          t({"\t}{", "\t\t"}), i(4, "\"Page Title\""), 
          t({"\t}", "", "\t// Render the component", "\tcomponents."}), i(5, "Component"), t({"(data).Render(r.Context(), w)"}),
          t({"", "}"})
        })
      })
      
      -- File templates for common Go files in GOTH stack
      ls.add_snippets("go", {
        -- Main.go template
        s("go-main", {
          t({"package main", "", "import (", "\t\"log\"", "\t\"net/http\"", "", "\t\""}), 
          i(1, "github.com/username/project"), t({"/handlers\"", ")", "", "func main() {", "\t// Setup routes", "\tmux := http.NewServeMux()", "\t"}),
          i(2, "mux.HandleFunc(\"/\", handlers.Index)"),
          t({"\t", "\t// Start server", "\tlog.Println(\"Server starting on :"}), i(3, "3000"), t({"...\")", "\tif err := http.ListenAndServe(\":"}), 
          f(function(args) return args[1][1] end, {3}), t({"\", mux); err != nil {", "\t\tlog.Fatal(err)", "\t}", "}"})
        }),
        
        -- Handler with Templ
        s("go-templ-route", {
          t({"func "}), i(1, "HandlerName"), t({" (w http.ResponseWriter, r *http.Request) {", "\t// Get data from request or database", "\t"}),
          i(2, "// Get data"),
          t({"\t", "\t// Create view model", "\tvm := struct {", "\t\t"}), i(3, "Title string"),
          t({"\t}{", "\t\t"}), i(4, "\"Title value\""),
          t({"\t}", "\t", "\t// Render template", "\tcomponents."}), i(5, "Component"), t({"(vm).Render(r.Context(), w)"}),
          t({"", "}"})
        }),
        
        -- Go test file
        s("go-test", {
          t({"package "}), i(1, "package_name"), t({"_test", "", "import (", "\t\"testing\"", "\t\"net/http/httptest\"", "\t\"net/http\"", ")", "", "func Test"}),
          i(2, "Function"), t({"(t *testing.T) {", "\t// Setup", "\t"}),
          i(3, "// Test setup"),
          t({"\t", "\t// Create request", "\treq := httptest.NewRequest(http.MethodGet, \"/\", nil)", "\tres := httptest.NewRecorder()", "\t", "\t// Call handler", "\thandler := http.HandlerFunc("}),
          i(4, "HandlerFunc"), t({")", "\thandler.ServeHTTP(res, req)", "\t", "\t// Assertions", "\tif status := res.Code; status != http.StatusOK {", "\t\tt.Errorf(\"handler returned wrong status code: got %v want %v\", status, http.StatusOK)", "\t}", "\t"}),
          i(0, "// Add more assertions"),
          t({"", "}"})
        })
      })
    end,
  },
  
  -- Go debugging support with Delve
  {
    "leoluz/nvim-dap-go",
    dependencies = {
      "mfussenegger/nvim-dap"
    },
    config = function()
      require("dap-go").setup({
        -- Additional configuration for better debugging experience
        dap_configurations = {
          {
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
          {
            type = "go",
            name = "Debug GOTH app",
            request = "launch",
            program = "${workspaceFolder}/main.go",
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
      
      -- Custom function to debug GOTH app
      _G.debug_goth_app = function()
        local dap = require("dap")
        
        -- Try to find main.go in workspace
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
        
        dap.continue()
      end
      
      -- Add custom command
      vim.api.nvim_create_user_command("DebugGOTHApp", function()
        _G.debug_goth_app()
      end, { desc = "Debug GOTH Application" })
    end,
  },
  
  -- Schema validator for HTML/HTMX attributes
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- last release is way too old
  },
  
  -- Enhanced HTML support for HTMX
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Initialize opts.servers if it doesn't exist
      opts.servers = opts.servers or {}
      
      -- Add HTMX attributes to HTML LSP
      opts.servers.html = opts.servers.html or {}
      opts.servers.html.settings = opts.servers.html.settings or {}
      opts.servers.html.settings.html = opts.servers.html.settings.html or {}
      
      -- Safely load schemas - FIX: The previous code was trying to access schemas
      -- as a table property, but it's a function. This is what caused the error.
      local status_ok, schema_store = pcall(require, "schemastore")
      if status_ok then
        -- Get HTML schemas from schemastore and add them to HTML LSP configuration
        local html_schemas = {}
        
        -- Try to get html schemas safely
        local schemas = schema_store.json.schemas()
        for _, schema in ipairs(schemas) do
          if schema.fileMatch and vim.tbl_contains(schema.fileMatch, "*.html") then
            table.insert(html_schemas, schema.url)
          end
        end
        
        -- Add HTMX schema if available
        local htmx_schema = nil
        for _, schema in ipairs(schemas) do
          if schema.name and schema.name:lower():match("htmx") then
            htmx_schema = schema.url
            break
          end
        end
        
        if htmx_schema then
          table.insert(html_schemas, htmx_schema)
        end
        
        -- Set custom data if we have any schemas
        if #html_schemas > 0 then
          opts.servers.html.settings.html.customData = html_schemas
        end
      end
      
      -- Add special configuration for templ files
      opts.servers.templ = opts.servers.templ or {
        filetypes = { "templ" },
      }
      
      return opts
    end,
  },
  
  -- Add custom formatter config for Templ files
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
          args = { "fmt", "$FILENAME" },
          stdin = false,
        },
        gofumpt = {
          command = "gofumpt",
          args = { "-l", "-w", "$FILENAME" },
          stdin = false,
        },
      },
    },
  },
  
  -- File browser configured for Go projects
  {
    "nvim-neo-tree/neo-tree.nvim",
    optional = true,
    opts = function(_, opts)
      if not opts.filesystem then
        return opts
      end
      
      -- Add better filtering for Go projects
      if not opts.filesystem.filtered_items then
        opts.filesystem.filtered_items = {}
      end
      
      -- Add common Go-related ignore patterns
      opts.filesystem.filtered_items.never_show = vim.list_extend(
        opts.filesystem.filtered_items.never_show or {},
        {
          ".git",
          "go.sum", -- Generally don't need to edit go.sum directly
          "vendor", -- Vendor directory is generally not edited directly
          "bin",    -- Compiled binaries
        }
      )
      
      return opts
    end,
  },
  
  -- Add custom command for starting a GOTH project
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
      if opts.defaults then
        -- Add GOTH-specific keymaps in the which-key menu
        opts.defaults["<leader>gs"] = { 
          name = "+GOTH Stack",
          -- Start a new GOTH project
          n = { 
            function()
              vim.ui.input({ prompt = "Project name: " }, function(name)
                if not name or name == "" then
                  return
                end
                
                -- Create a new terminal for project initialization
                local Terminal = require("toggleterm.terminal").Terminal
                local goth_init = Terminal:new({
                  cmd = string.format("mkdir -p %s && cd %s && go mod init %s && mkdir -p components handlers static", name, name, name),
                  hidden = false,
                  direction = "float",
                  on_exit = function()
                    vim.cmd("cd " .. name)
                    -- Create main.go
                    local main_file = io.open(name .. "/main.go", "w")
                    if main_file then
                      main_file:write(string.format([[
package main

import (
	"log"
	"net/http"
)

func main() {
	// Setup static file server
	fs := http.FileServer(http.Dir("static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	// Setup routes
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello from %s!"))
	})

	// Start server
	log.Println("Server starting on :3000...")
	if err := http.ListenAndServe(":3000", nil); err != nil {
		log.Fatal(err)
	}
}
]], name))
                      main_file:close()
                    end
                    
                    -- Create basic templ component
                    os.execute("mkdir -p " .. name .. "/components")
                    local component_file = io.open(name .. "/components/layout.templ", "w")
                    if component_file then
                      component_file:write([[
package components

type LayoutProps struct {
	Title string
	Content templ.Component
}

templ Layout(props LayoutProps) {
	<!DOCTYPE html>
	<html lang="en">
		<head>
			<meta charset="UTF-8"/>
			<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
			<title>{ props.Title }</title>
			<script src="https://unpkg.com/htmx.org@1.9.4"></script>
			<script src="https://cdn.tailwindcss.com"></script>
		</head>
		<body class="bg-gray-100 min-h-screen">
			<main class="container mx-auto p-4">
				{ props.Content }
			</main>
		</body>
	</html>
}

templ HomePage() {
	@Layout{
		Title: "GOTH App",
		Content: homeContent(),
	}
}

templ homeContent() {
	<div class="bg-white p-6 rounded-lg shadow-md">
		<h1 class="text-2xl font-bold mb-4">Welcome to your GOTH App</h1>
		<p class="mb-4">This is a starter template using Go, Templ, and HTMX.</p>
		
		<div hx-get="/api/hello" hx-trigger="load" hx-swap="innerHTML">
			Loading...
		</div>
		
		<button 
			class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mt-4"
			hx-post="/api/click"
			hx-swap="outerHTML"
		>
			Click me
		</button>
	</div>
}
]])
                      component_file:close()
                    end
                    
                    -- Create a handler
                    os.execute("mkdir -p " .. name .. "/handlers")
                    local handler_file = io.open(name .. "/handlers/handlers.go", "w")
                    if handler_file then
                      handler_file:write(string.format([[
package handlers

import (
	"net/http"

	"%s/components"
)

// Index renders the homepage
func Index(w http.ResponseWriter, r *http.Request) {
	components.HomePage().Render(r.Context(), w)
}

// HelloAPI is a simple API endpoint that returns HTML
func HelloAPI(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte("<p class=\"text-green-500 font-semibold\">Hello from the server!</p>"))
}

// ClickHandler handles button clicks
func ClickHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(`
		<div class="bg-green-100 p-4 rounded-md">
			<p class="text-green-800">Thanks for clicking!</p>
			<button 
				class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded mt-2"
				hx-post="/api/reset"
				hx-swap="outerHTML"
			>
				Reset
			</button>
		</div>
	`))
}

// ResetHandler resets the button
func ResetHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(`
		<button 
			class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mt-4"
			hx-post="/api/click"
			hx-swap="outerHTML"
		>
			Click me
		</button>
	`))
}
]], name))
                      handler_file:close()
                    end
                    
                    -- Update main.go with handlers
                    main_file = io.open(name .. "/main.go", "w")
                    if main_file then
                      main_file:write(string.format([[
package main

import (
	"log"
	"net/http"

	"%s/handlers"
)

func main() {
	// Setup static file server
	fs := http.FileServer(http.Dir("static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	// Setup routes
	http.HandleFunc("/", handlers.Index)
	http.HandleFunc("/api/hello", handlers.HelloAPI)
	http.HandleFunc("/api/click", handlers.ClickHandler)
	http.HandleFunc("/api/reset", handlers.ResetHandler)

	// Start server
	log.Println("Server starting on :3000...")
	if err := http.ListenAndServe(":3000", nil); err != nil {
		log.Fatal(err)
	}
}
]], name))
                      main_file:close()
                    end
                    
                    -- Create directory for static files
                    os.execute("mkdir -p " .. name .. "/static")
                    
                    -- Create a .gitignore file
                    local gitignore_file = io.open(name .. "/.gitignore", "w")
                    if gitignore_file then
                      gitignore_file:write([[
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with `go test -c`
*.test

# Output of the go coverage tool, specifically when used with LiteIDE
*.out

# Dependency directories (remove the comment below to include it)
# vendor/

# Go workspace file
go.work

# Templ generated files
*_templ.go
]])
                      gitignore_file:close()
                    end
                    
                    -- Notify the user
                    vim.notify("GOTH project '" .. name .. "' initialized! Run 'cd " .. name .. " && templ generate && go run .'", vim.log.levels.INFO)
                  end,
                })
                goth_init:toggle()
              end)
            end,
            "New GOTH Project" 
          },
          -- Run current GOTH project
          r = { 
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local goth_run = Terminal:new({
                cmd = "templ generate && go run .",
                hidden = false,
                direction = "horizontal",
                on_open = function(term)
                  vim.cmd("startinsert!")
                end,
              })
              goth_run:toggle()
            end,
            "Run GOTH Project" 
          },
          -- Start a debug session
          d = { "<cmd>DebugGOTHApp<cr>", "Debug GOTH App" },
          -- Generate templ files
          g = { 
            function()
              vim.cmd("!templ generate")
              vim.notify("Templ files generated", vim.log.levels.INFO)
            end,
            "Generate Templ Files" 
          },
          -- Create a new templ component
          c = { function() require("config.utils").new_templ_component() end, "New Templ Component" },
        }
      end
      
      return opts
    end,
  },
}
