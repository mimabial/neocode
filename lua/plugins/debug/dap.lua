---@diagnostic disable: missing-fields
---@diagnostic disable: undefined-global

local function toggle_dap_breakpoint()
  require("dap").toggle_breakpoint()
end
local function set_conditional_breakpoint()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end
local function dap_continue()
  require("dap").continue()
end
local function dap_step_into()
  require("dap").step_into()
end
local function dap_step_over()
  require("dap").step_over()
end
local function dap_step_out()
  require("dap").step_out()
end
local function dap_terminate()
  require("dap").terminate()
end
local function dap_run_to_cursor()
  require("dap").run_to_cursor()
end
local function dap_goto()
  require("dap").goto_()
end
local function dap_down()
  require("dap").down()
end
local function dap_up()
  require("dap").up()
end
local function dap_run_last()
  require("dap").run_last()
end
local function dap_pause()
  require("dap").pause()
end
local function dap_repl_toggle()
  require("dap").repl.toggle()
end
local function dap_session()
  require("dap").session()
end
local function dap_widgets_hover()
  require("dap.ui.widgets").hover()
end
local function dapui_toggle()
  require("dapui").toggle()
end
local function dapui_eval()
  require("dapui").eval()
end

local function setup_dap()
  local dap = require("dap")
  local dapui = require("dapui")
  local vt = require("nvim-dap-virtual-text")
  vt.setup({ commented = true })

  dapui.setup({
    controls = {
      element = "repl",
      enabled = true,
    },
    floating = {
      border = "single",
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    layouts = {
      {
        elements = {
          { id = "scopes",      size = 0.25 },
          { id = "breakpoints", size = 0.25 },
          { id = "stacks",      size = 0.25 },
          { id = "watches",     size = 0.25 },
        },
        position = "left",
        size = 40,
      },
      {
        elements = {
          { id = "repl",    size = 0.5 },
          { id = "console", size = 0.5 },
        },
        position = "bottom",
        size = 10,
      },
    },
  })

  require("mason-nvim-dap").setup({
    automatic_installation = true,
    handlers = {},
  })

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end

  require("dap-vscode-js").setup({
    debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
    adapters = {
      'pwa-node',
      'pwa-chrome',
      'pwa-msedge',
      'node-terminal',
      'pwa-extensionHost'
    },
  })

  for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
    dap.configurations[language] = {
      -- Launch single file
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        protocol = "inspector",
        console = "integratedTerminal",
      },
      -- Attach to process
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        protocol = "inspector",
      },
      -- Debug Next.js dev server
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Next.js (server)",
        program = "${workspaceFolder}/node_modules/next/dist/bin/next",
        args = { "dev" },
        cwd = "${workspaceFolder}",
        env = {
          NODE_OPTIONS = "--inspect=9229"
        },
        sourceMaps = true,
        protocol = "inspector",
        console = "integratedTerminal",
      },
      -- Debug Next.js in Chrome
      {
        type = "pwa-chrome",
        request = "launch",
        name = "Debug Next.js (client)",
        url = "http://localhost:3000",
        webRoot = "${workspaceFolder}",
        sourceMaps = true,
        userDataDir = false,
        runtimeExecutable = "/usr/bin/google-chrome-stable", -- Adjust path as needed
      },
      -- Debug Jest tests
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Jest Tests",
        program = "${workspaceFolder}/node_modules/.bin/jest",
        args = { "--runInBand", "--no-coverage", "--no-cache" },
        cwd = "${workspaceFolder}",
        env = { CI = "true" },
        console = "integratedTerminal",
        sourceMaps = true,
      },
      -- Debug npm script
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug npm script",
        runtimeExecutable = "npm",
        runtimeArgs = function()
          return { "run", vim.fn.input("Script name: ") }
        end,
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        sourceMaps = true,
      },
    }
  end

  vim.fn.sign_define('DapBreakpoint', {
    text = '●',
    texthl = 'DapBreakpoint',
    linehl = '',
    numhl = ''
  })
  vim.fn.sign_define('DapBreakpointCondition', {
    text = '◐',
    texthl = 'DapBreakpointCondition',
    linehl = '',
    numhl = ''
  })
  vim.fn.sign_define('DapStopped', {
    text = '▶',
    texthl = 'DapStopped',
    linehl = 'DapStoppedLine',
    numhl = ''
  })

  -- Setup colors
  local function setup_dap_highlights()
    local colors = require("config.ui").get_colors()
    vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = colors.red })
    vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = colors.yellow })
    vim.api.nvim_set_hl(0, 'DapStopped', { fg = colors.green })
    vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = colors.select_bg })
  end

  setup_dap_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_dap_highlights })
end

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    "theHamsta/nvim-dap-virtual-text",
    "jay-babu/mason-nvim-dap.nvim",
    "williamboman/mason.nvim",
    "mfussenegger/nvim-dap-python",
    {
      "microsoft/vscode-js-debug",
      opt = true,
      build = function()
        vim.env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1"
        vim.cmd("!npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out")
      end
    },
    {
      "mxsdev/nvim-dap-vscode-js",
      dependencies = { "mfussenegger/nvim-dap" },
    },
  },
  config = setup_dap,
  keys = {
    { "<leader>db", toggle_dap_breakpoint,      desc = "Toggle Breakpoint" },
    { "<leader>dB", set_conditional_breakpoint, desc = "Conditional Breakpoint" },
    { "<leader>dc", dap_continue,               desc = "Continue" },
    { "<leader>di", dap_step_into,              desc = "Step Into" },
    { "<leader>do", dap_step_over,              desc = "Step Over" },
    { "<leader>dO", dap_step_out,               desc = "Step Out" },
    { "<leader>dt", dap_terminate,              desc = "Terminate" },
    { "<leader>dC", dap_run_to_cursor,          desc = "Run to Cursor" },
    { "<leader>dg", dap_goto,                   desc = "Go to Line (no execute)" },
    { "<leader>dj", dap_down,                   desc = "Down" },
    { "<leader>dk", dap_up,                     desc = "Up" },
    { "<leader>dl", dap_run_last,               desc = "Run Last" },
    { "<leader>dp", dap_pause,                  desc = "Pause" },
    { "<leader>dr", dap_repl_toggle,            desc = "Toggle REPL" },
    { "<leader>ds", dap_session,                desc = "Session" },
    { "<leader>dw", dap_widgets_hover,          desc = "Widgets" },
    { "<F5>",       dap_continue,               desc = "Debug: Continue" },
    { "<F10>",      dap_step_over,              desc = "Debug: Step Over" },
    { "<F11>",      dap_step_into,              desc = "Debug: Step Into" },
    { "<F12>",      dap_step_out,               desc = "Debug: Step Out" },
    { "<leader>du", dapui_toggle,               desc = "Toggle UI" },
    { "<leader>de", dapui_eval,                 desc = "Evaluate" },
  },
}
