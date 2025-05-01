---@diagnostic disable: missing-fields
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- Creates a beautiful debugger UI
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
    },
    -- Virtual text for the debugger
    "theHamsta/nvim-dap-virtual-text",
    -- Mason DAP integration
    "jay-babu/mason-nvim-dap.nvim",
    -- Installs the debug adapters for you
    "williamboman/mason.nvim",
    -- Add stack-specific adapters
    "leoluz/nvim-dap-go",
    "mfussenegger/nvim-dap-python",
  },
  keys = {
    -- Basic debugging
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Toggle Breakpoint",
    },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Conditional Breakpoint",
    },
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<leader>di",
      function()
        require("dap").step_into()
      end,
      desc = "Step Into",
    },
    {
      "<leader>do",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<leader>dO",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
    {
      "<leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = "Terminate",
    },

    -- Additional debugging commands
    {
      "<leader>dC",
      function()
        require("dap").run_to_cursor()
      end,
      desc = "Run to Cursor",
    },
    {
      "<leader>dg",
      function()
        require("dap").goto_()
      end,
      desc = "Go to Line (no execute)",
    },
    {
      "<leader>dj",
      function()
        require("dap").down()
      end,
      desc = "Down",
    },
    {
      "<leader>dk",
      function()
        require("dap").up()
      end,
      desc = "Up",
    },
    {
      "<leader>dl",
      function()
        require("dap").run_last()
      end,
      desc = "Run Last",
    },
    {
      "<leader>dp",
      function()
        require("dap").pause()
      end,
      desc = "Pause",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.toggle()
      end,
      desc = "Toggle REPL",
    },
    {
      "<leader>ds",
      function()
        require("dap").session()
      end,
      desc = "Session",
    },
    {
      "<leader>dw",
      function()
        require("dap.ui.widgets").hover()
      end,
      desc = "Widgets",
    },

    -- Function Keys
    {
      "<F5>",
      function()
        require("dap").continue()
      end,
      desc = "Debug: Continue",
    },
    {
      "<F10>",
      function()
        require("dap").step_over()
      end,
      desc = "Debug: Step Over",
    },
    {
      "<F11>",
      function()
        require("dap").step_into()
      end,
      desc = "Debug: Step Into",
    },
    {
      "<F12>",
      function()
        require("dap").step_out()
      end,
      desc = "Debug: Step Out",
    },

    -- UI Integration
    {
      "<leader>du",
      function()
        require("dapui").toggle()
      end,
      desc = "Toggle UI",
    },
    {
      "<leader>de",
      function()
        require("dapui").eval()
      end,
      desc = "Evaluate",
    },

    -- Stack-specific debug commands
    {
      "<leader>dG",
      function()
        _G.debug_goth_app()
      end,
      desc = "Debug GOTH App",
    },
    {
      "<leader>dN",
      function()
        _G.debug_nextjs_app()
      end,
      desc = "Debug Next.js App",
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    local mason_dap = require("mason-nvim-dap")

    -- Configure Mason DAP integration
    mason_dap.setup({
      -- Makes a best effort to setup the various debuggers with reasonable debug configurations
      automatic_installation = true,
      ensure_installed = { "delve", "js-debug-adapter", "node-debug2-adapter", "python" },
      handlers = {
        function(config)
          -- All sources with no handler get passed here
          mason_dap.default_setup(config)
        end,
        -- Stack-specific handlers
        delve = function(config)
          -- Special config for Go debugging
          dap.configurations.go = {
            {
              type = "delve",
              name = "Debug Go",
              request = "launch",
              program = "${file}",
            },
            {
              type = "delve",
              name = "Debug Go Project",
              request = "launch",
              program = "${workspaceFolder}",
            },
            {
              type = "delve",
              name = "Debug Test",
              request = "launch",
              mode = "test",
              program = "${file}",
            },
            {
              type = "delve",
              name = "Debug Test Function",
              request = "launch",
              mode = "test",
              program = "${file}",
              args = { "-test.run", "^${dlv:TestName}$" },
            },
          }

          -- Apply default setup
          mason_dap.default_setup(config)
        end,
        ["js-debug-adapter"] = function(config)
          -- Special config for JS/TS debugging in Next.js
          dap.configurations.javascript = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch Next.js",
              cwd = "${workspaceFolder}",
              runtimeExecutable = "npm",
              runtimeArgs = { "run", "dev" },
              console = "integratedTerminal",
              skipFiles = { "<node_internals>/**", "node_modules/**" },
            },
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch Current File",
              cwd = "${workspaceFolder}",
              program = "${file}",
              console = "integratedTerminal",
              skipFiles = { "<node_internals>/**", "node_modules/**" },
            },
          }

          dap.configurations.typescript = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch Next.js",
              cwd = "${workspaceFolder}",
              runtimeExecutable = "npm",
              runtimeArgs = { "run", "dev" },
              console = "integratedTerminal",
              skipFiles = { "<node_internals>/**", "node_modules/**" },
              sourceMaps = true,
              resolveSourceMapLocations = {
                "${workspaceFolder}/**",
                "!**/node_modules/**",
              },
            },
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch Current File",
              cwd = "${workspaceFolder}",
              program = "${file}",
              console = "integratedTerminal",
              skipFiles = { "<node_internals>/**", "node_modules/**" },
              sourceMaps = true,
              resolveSourceMapLocations = {
                "${workspaceFolder}/**",
                "!**/node_modules/**",
              },
            },
          }

          -- Apply default setup
          mason_dap.default_setup(config)
        end,
        python = function(config)
          -- Special config for Python
          dap.configurations.python = {
            {
              type = "python",
              request = "launch",
              name = "Launch File",
              program = "${file}",
              pythonPath = function()
                -- Find and use activated virtual environment if available
                local venv = os.getenv("VIRTUAL_ENV")
                if venv then
                  return venv .. "/bin/python"
                end

                -- Try to detect common virtual environment patterns
                local cwd = vim.fn.getcwd()
                local venv_paths = {
                  cwd .. "/.venv/bin/python",
                  cwd .. "/venv/bin/python",
                  cwd .. "/env/bin/python",
                }

                for _, path in ipairs(venv_paths) do
                  if vim.fn.executable(path) == 1 then
                    return path
                  end
                end

                -- Fall back to system Python
                return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
              end,
            },
            {
              type = "python",
              request = "launch",
              name = "Launch with Arguments",
              program = "${file}",
              args = function()
                local args_string = vim.fn.input("Arguments: ")
                return vim.split(args_string, " ")
              end,
              pythonPath = function()
                local venv = os.getenv("VIRTUAL_ENV")
                if venv then
                  return venv .. "/bin/python"
                end
                return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
              end,
            },
          }

          -- Apply default setup
          mason_dap.default_setup(config)
        end,
      },
    })

    -- Set up DAP UI
    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
      mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      -- Expand lines larger than the window
      expand_lines = vim.fn.has("nvim-0.7") == 1,
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            "breakpoints",
            "stacks",
            "watches",
          },
          size = 40, -- 40 columns
          position = "left",
        },
        {
          elements = {
            "repl",
            "console",
          },
          size = 0.25, -- 25% of total lines
          position = "bottom",
        },
      },
      controls = {
        enabled = true,
        element = "repl",
        icons = {
          pause = "",
          play = "",
          step_into = "",
          step_over = "",
          step_out = "",
          step_back = "",
          run_last = "",
          terminate = "",
        },
      },
      floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = "rounded", -- Border style
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      windows = { indent = 1 },
      render = {
        max_type_length = nil, -- Can be integer or nil.
        max_value_lines = 100, -- Can be integer or nil.
      },
    })

    -- Set up DAP Virtual Text for enhanced debugging experience
    require("nvim-dap-virtual-text").setup({
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,
      virt_text_pos = "inline",
      all_frames = false,
      virt_lines = false,
      virt_text_win_col = nil,
    })

    -- Go debugging
    require("dap-go").setup()

    -- Python debugging
    require("dap-python").setup()

    -- Auto open/close DAP UI
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- GOTH stack debugging function
    _G.debug_goth_app = function()
      -- Try to find main.go in workspace
      local main_file = vim.fn.findfile("main.go", vim.fn.getcwd() .. "/**")
      if main_file == "" then
        vim.notify("Could not find main.go file to debug", vim.log.levels.ERROR)
        return
      end

      -- Check for templ files and generate them if found
      local has_templ = vim.fn.glob("**/*.templ") ~= ""
      if has_templ then
        local result = vim.fn.system("templ generate")
        if vim.v.shell_error ~= 0 then
          vim.notify("Error generating templ files: " .. result, vim.log.levels.ERROR)
          return
        end
        vim.notify("Generated templ files before debugging", vim.log.levels.INFO)
      end

      -- Configure and start debugging
      dap.configurations.go = {
        {
          type = "delve",
          name = "Debug GOTH App",
          request = "launch",
          program = main_file,
          buildFlags = "",
        },
      }

      vim.notify("Starting GOTH app debugging...", vim.log.levels.INFO)
      dap.continue()
    end

    -- Next.js debugging function
    _G.debug_nextjs_app = function()
      -- Check if it's a Next.js project
      local package_json = vim.fn.findfile("package.json", vim.fn.getcwd() .. ";")
      if package_json == "" then
        vim.notify("No package.json found. Is this a Next.js project?", vim.log.levels.ERROR)
        return
      end

      -- Read package.json to verify it's a Next.js project
      local content = vim.fn.readfile(package_json)
      local package_content = table.concat(content, "\n")
      if not string.find(package_content, '"next"') then
        vim.notify("This doesn't appear to be a Next.js project", vim.log.levels.WARN)
      end

      -- Configure debug adapter for Next.js
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      -- Start debugging
      vim.notify("Starting Next.js debugging...", vim.log.levels.INFO)
      dap.continue()
    end

    -- Add custom commands
    vim.api.nvim_create_user_command("DebugGOTHApp", function()
      _G.debug_goth_app()
    end, { desc = "Debug GOTH Application" })

    vim.api.nvim_create_user_command("DebugNextJSApp", function()
      _G.debug_nextjs_app()
    end, { desc = "Debug Next.js Application" })

    -- Set up sign icons
    vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpointSign", linehl = "", numhl = "" })
    vim.fn.sign_define(
      "DapBreakpointCondition",
      { text = "", texthl = "DapBreakpointConditionSign", linehl = "", numhl = "" }
    )
    vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapLogPointSign", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStoppedSign", linehl = "DapStoppedLine", numhl = "" })
    vim.fn.sign_define(
      "DapBreakpointRejected",
      { text = "", texthl = "DapBreakpointRejectedSign", linehl = "", numhl = "" }
    )

    -- Set up sign colors when gruvbox-material is active
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        if vim.g.colors_name == "gruvbox-material" then
          local colors = _G.get_gruvbox_colors and _G.get_gruvbox_colors()
            or {
              red = "#ea6962",
              orange = "#e78a4e",
              yellow = "#d8a657",
              green = "#89b482",
              aqua = "#7daea3",
            }

          vim.api.nvim_set_hl(0, "DapBreakpointSign", { fg = colors.red, bold = true })
          vim.api.nvim_set_hl(0, "DapBreakpointConditionSign", { fg = colors.orange, bold = true })
          vim.api.nvim_set_hl(0, "DapLogPointSign", { fg = colors.green, bold = true })
          vim.api.nvim_set_hl(0, "DapStoppedSign", { fg = colors.yellow, bold = true })
          vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#32302f" })
          vim.api.nvim_set_hl(0, "DapBreakpointRejectedSign", { fg = colors.aqua, bold = true })
        end
      end,
    })
  end,
}
