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
-- local function debug_goth_app() _G.debug_goth_app() end
-- local function debug_nextjs_app() _G.debug_nextjs_app() end

local function setup_dap()
  local dap = require("dap")
  local dapui = require("dapui")
  local vt = require("nvim-dap-virtual-text")
  vt.setup({ commented = true })

  dapui.setup()

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

  -- require("plugins.dap.lang.go").setup()
  -- require("plugins.dap.lang.python").setup()
end

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    "theHamsta/nvim-dap-virtual-text",
    "jay-babu/mason-nvim-dap.nvim",
    "williamboman/mason.nvim",
    "leoluz/nvim-dap-go",
    "mfussenegger/nvim-dap-python",
  },
  config = setup_dap,
  keys = {
    { "<leader>db", toggle_dap_breakpoint, desc = "Toggle Breakpoint" },
    { "<leader>dB", set_conditional_breakpoint, desc = "Conditional Breakpoint" },
    { "<leader>dc", dap_continue, desc = "Continue" },
    { "<leader>di", dap_step_into, desc = "Step Into" },
    { "<leader>do", dap_step_over, desc = "Step Over" },
    { "<leader>dO", dap_step_out, desc = "Step Out" },
    { "<leader>dt", dap_terminate, desc = "Terminate" },
    { "<leader>dC", dap_run_to_cursor, desc = "Run to Cursor" },
    { "<leader>dg", dap_goto, desc = "Go to Line (no execute)" },
    { "<leader>dj", dap_down, desc = "Down" },
    { "<leader>dk", dap_up, desc = "Up" },
    { "<leader>dl", dap_run_last, desc = "Run Last" },
    { "<leader>dp", dap_pause, desc = "Pause" },
    { "<leader>dr", dap_repl_toggle, desc = "Toggle REPL" },
    { "<leader>ds", dap_session, desc = "Session" },
    { "<leader>dw", dap_widgets_hover, desc = "Widgets" },
    { "<F5>", dap_continue, desc = "Debug: Continue" },
    { "<F10>", dap_step_over, desc = "Debug: Step Over" },
    { "<F11>", dap_step_into, desc = "Debug: Step Into" },
    { "<F12>", dap_step_out, desc = "Debug: Step Out" },
    { "<leader>du", dapui_toggle, desc = "Toggle UI" },
    { "<leader>de", dapui_eval, desc = "Evaluate" },
    { "<leader>dG", debug_goth_app, desc = "Debug GOTH App" },
    { "<leader>dN", debug_nextjs_app, desc = "Debug Next.js App" },
  },
}
