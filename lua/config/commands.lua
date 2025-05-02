-- lua/config/commands.lua
-- Centralized Neovim user commands (ReloadConfig, ExplorerToggle, HlsLensToggle, and Layout)

local M = {}
local api = vim.api

-- Utility to safely require modules
local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify(string.format("[Commands] Could not load '%s': %s", mod, m), vim.log.levels.WARN)
    return nil
  end
  return m
end

function M.setup()
  -- ReloadConfig: clear loaded config/plugins and re-source init.lua
  api.nvim_create_user_command("ReloadConfig", function()
    for name, _ in pairs(package.loaded) do
      if name:match("^(config)\\.") or name:match("^(plugins)\\.") then
        package.loaded[name] = nil
      end
    end
    dofile(vim.fn.stdpath("config") .. "/init.lua")
    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO, { title = "Config" })
  end, { desc = "Reload Neovim configuration" })

  -- ExplorerToggle: switch default_explorer and open it
  api.nvim_create_user_command("ExplorerToggle", function(opts)
    local ex = opts.args == "snacks" and "snacks" or "oil"
    vim.g.default_explorer = ex
    local lazy = safe_require("lazy")
    if ex == "oil" then
      local oil = safe_require("oil")
      if oil then
        oil.open()
      elseif lazy then
        lazy.load({ plugins = { "oil.nvim" } })
        vim.defer_fn(function()
          local ok, mod = pcall(require, "oil")
          if ok then
            mod.open()
          end
        end, 100)
      end
    else
      local snacks = safe_require("snacks")
      if snacks and snacks.explorer then
        snacks.explorer()
      elseif lazy then
        lazy.load({ plugins = { "snacks.nvim" } })
        vim.defer_fn(function()
          local ok, mod = pcall(require, "snacks")
          if ok and mod.explorer then
            mod.explorer()
          end
        end, 100)
      end
    end
  end, {
    nargs = "?",
    complete = function()
      return { "oil", "snacks" }
    end,
    desc = "Set and open default explorer (oil or snacks)",
  })

  -- HlsLensToggle: toggle search lens highlighting
  api.nvim_create_user_command("HlsLensToggle", function()
    vim.g.hlslens_disabled = not vim.g.hlslens_disabled
    vim.notify("HlsLens " .. (vim.g.hlslens_disabled and "disabled" or "enabled"), vim.log.levels.INFO)
    if not vim.g.hlslens_disabled then
      if vim.fn.getreg("/") ~= "" then
        vim.cmd("set hlsearch")
        local ok, hlslens = pcall(require, "hlslens")
        if ok then
          hlslens.start()
        end
      end
    end
  end, { desc = "Toggle HlsLens search highlighting" })

  -- Layout: predefined window layouts
  api.nvim_create_user_command("Layout", function(opts)
    local layout = opts.args
    local lazy = safe_require("lazy")

    -- Helper to open Oil explorer
    local function open_oil()
      local oil = safe_require("oil")
      if oil then
        oil.open()
      elseif lazy then
        lazy.load({ plugins = { "oil.nvim" } })
        vim.defer_fn(function()
          local ok, m = pcall(require, "oil")
          if ok then
            m.open()
          end
        end, 100)
      end
    end

    -- Helper to open a terminal via toggleterm
    local function open_term()
      local toggleterm = safe_require("toggleterm")
      if toggleterm and toggleterm.toggle then
        toggleterm.toggle(1, 15, nil, "horizontal")
      elseif lazy then
        lazy.load({ plugins = { "toggleterm.nvim" } })
        vim.defer_fn(function()
          local ok, tt = pcall(require, "toggleterm")
          if ok and tt.toggle then
            tt.toggle(1, 15, nil, "horizontal")
          end
        end, 100)
      end
    end

    if layout == "coding" then
      open_oil()
      api.nvim_command("wincmd l")
    elseif layout == "terminal" then
      open_oil()
      api.nvim_command("wincmd l")
      open_term()
    elseif layout == "writing" then
      api.nvim_command("only")
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
      if _G.Util and _G.Util.center_buffer then
        _G.Util.center_buffer()
      end
    elseif layout == "debug" then
      api.nvim_command("only")
      local dapui = safe_require("dapui")
      if dapui and dapui.open then
        dapui.open()
      elseif lazy then
        lazy.load({ plugins = { "nvim-dap-ui" } })
        vim.defer_fn(function()
          local ok, dui = pcall(require, "dapui")
          if ok and dui.open then
            dui.open()
          else
            vim.notify("DAP UI is not loaded", vim.log.levels.WARN)
          end
        end, 100)
      end
    else
      vim.notify("Available layouts: coding, terminal, writing, debug", vim.log.levels.INFO)
    end
  end, {
    nargs = "?",
    complete = function()
      return { "coding", "terminal", "writing", "debug" }
    end,
    desc = "Switch workspace layout",
  })
end

return M
