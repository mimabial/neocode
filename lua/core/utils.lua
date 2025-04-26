--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------
--
-- This file provides utility functions that can be used throughout the config.
--
-- Functions are organized by functionality:
-- 1. Plugin helpers
-- 2. Path and file operations
-- 3. Buffer and window operations
-- 4. Command helpers
-- 5. Logging and debugging
--
-- Import this module using: local utils = require("core.utils")
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Plugin Helpers
--------------------------------------------------------------------------------

-- Check if a plugin is installed
function M.has_plugin(plugin)
	local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
	return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
end

-- Initialize plugin if it exists, otherwise show warning
function M.load_plugin(plugin_name)
	local status_ok, plugin = pcall(require, plugin_name)
	if not status_ok then
		vim.notify("Plugin " .. plugin_name .. " not found!", vim.log.levels.WARN)
		return nil
	end
	return plugin
end

-- Require and setup a plugin with given options (if needed)
function M.setup_plugin(plugin_name, opts)
	local plugin = M.load_plugin(plugin_name)
	if plugin and opts then
		plugin.setup(opts)
	end
	return plugin
end

--------------------------------------------------------------------------------
-- Path and File Operations
--------------------------------------------------------------------------------

-- Get the root directory of the current project
function M.get_root()
	local root = vim.fn.getcwd()

	-- Try common root patterns
	local patterns = {
		".git", -- Git
		".svn", -- Subversion
		".hg", -- Mercurial
		"package.json", -- Node.js
		"Cargo.toml", -- Rust
		"go.mod", -- Go
		"pyproject.toml", -- Python
		"Makefile", -- Make
		".root", -- Generic marker
	}

	for _, pattern in ipairs(patterns) do
		-- Start from current working directory
		local find_root = vim.fn.finddir(pattern, root .. ";")
		if find_root ~= "" then
			-- Found match, use its directory as root
			return vim.fn.fnamemodify(find_root, ":h")
		end
		find_root = vim.fn.findfile(pattern, root .. ";")
		if find_root ~= "" then
			-- Found match, use its directory as root
			return vim.fn.fnamemodify(find_root, ":h")
		end
	end

	-- Default to current working directory
	return root
end

-- Get the relative path of a file from the project root
function M.relative_path(filepath)
	local root = M.get_root()
	return string.gsub(filepath, "^" .. vim.pesc(root) .. "/", "")
end

-- Check if a file exists
function M.file_exists(file)
	local stat = vim.loop.fs_stat(file)
	return stat and stat.type == "file"
end

-- Check if a directory exists
function M.dir_exists(path)
	local stat = vim.loop.fs_stat(path)
	return stat and stat.type == "directory"
end

-- Create a directory if it doesn't exist
function M.ensure_dir(path)
	if not M.dir_exists(path) then
		vim.fn.mkdir(path, "p")
	end
end

-- Read a file into a string
function M.read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

-- Write a string to a file
function M.write_file(path, content)
	local file = io.open(path, "w")
	if not file then
		return false
	end
	file:write(content)
	file:close()
	return true
end

--------------------------------------------------------------------------------
-- Buffer and Window Operations
--------------------------------------------------------------------------------

-- Get all buffer numbers
function M.get_buffers()
	return vim.tbl_filter(function(buf)
		return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
	end, vim.api.nvim_list_bufs())
end

-- Close all buffers except the current one
function M.close_other_buffers()
	local current = vim.api.nvim_get_current_buf()
	for _, bufnr in ipairs(M.get_buffers()) do
		if bufnr ~= current then
			vim.cmd("bd " .. bufnr)
		end
	end
end

-- Enable line numbers
function M.enable_line_numbers()
	vim.wo.number = true
	vim.wo.relativenumber = true
end

-- Disable line numbers
function M.disable_line_numbers()
	vim.wo.number = false
	vim.wo.relativenumber = false
end

-- Toggle line numbers
function M.toggle_line_numbers()
	if vim.wo.number or vim.wo.relativenumber then
		M.disable_line_numbers()
	else
		M.enable_line_numbers()
	end
end

-- Toggle a boolean option
function M.toggle_option(option)
	vim.opt[option] = not vim.opt[option]:get()
	vim.notify(option .. " is now " .. (vim.opt[option]:get() and "enabled" or "disabled"), vim.log.levels.INFO)
end

-- Maximize current window
function M.maximize_window()
	local current_win = vim.api.nvim_get_current_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if win ~= current_win then
			vim.api.nvim_win_hide(win)
		end
	end
end

function M.toggle_diagnostic_hints(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local is_enabled = vim.diagnostic.is_enabled({ bufnr = bufnr })
	vim.diagnostic.enable(not is_enabled, { bufnr = bufnr })
	vim.notify(
		("Diagnostics %s for buffer %d"):format(is_enabled and "disabled" or "enabled", bufnr),
		vim.log.levels.INFO
	)
end

function M.toggle_inlay_hints(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	-- Check if inlay hints are enabled
	local ok, res = pcall(vim.lsp.inlay_hint.is_enabled, { bufnr = bufnr })
	if not ok then
		res = vim.lsp.inlay_hint.is_enabled(bufnr)
	end

	-- Determine the new state
	local enable = not (res == true or res == 1)

	-- Set the new state with the correct parameters
	ok = pcall(vim.lsp.inlay_hint.enable, bufnr, { enabled = enable })
	if not ok then
		vim.lsp.inlay_hint.enable(bufnr, { enabled = enable })
	end
end

--------------------------------------------------------------------------------
-- Command Helpers
--------------------------------------------------------------------------------

-- Run system command and get output
function M.system(cmd)
	local handle = io.popen(cmd)
	if not handle then
		return nil
	end
	local result = handle:read("*a")
	handle:close()
	return result
end

-- Run a command silently
function M.silent_command(cmd)
	vim.cmd("silent! " .. cmd)
end

-- Execute a callback with error handling
function M.try(func, ...)
	local status, result = pcall(func, ...)
	if not status then
		vim.notify(result, vim.log.levels.ERROR)
		return nil
	end
	return result
end

-- Create a user command with auto-complete
function M.create_command(name, fn, opts)
	opts = opts or {}
	vim.api.nvim_create_user_command(name, fn, opts)
end

--------------------------------------------------------------------------------
-- Logging and Debugging
--------------------------------------------------------------------------------

-- Better notify with optional title
function M.notify(msg, level, opts)
	opts = opts or {}
	level = level or vim.log.levels.INFO

	-- Use nvim-notify if available
	if M.has_plugin("nvim-notify") then
		require("notify")(msg, level, opts)
	else
		vim.notify(msg, level)
	end
end

-- Write to debug log
function M.debug(...)
	local args = { ... }
	local str_args = {}
	for i, arg in ipairs(args) do
		if type(arg) == "table" then
			str_args[i] = vim.inspect(arg)
		else
			str_args[i] = tostring(arg)
		end
	end

	local msg = table.concat(str_args, " ")
	local debug_file = vim.fn.stdpath("cache") .. "/neocode_debug.log"

	-- Append to log file
	local file = io.open(debug_file, "a")
	if file then
		local timestamp = os.date("%Y-%m-%d %H:%M:%S")
		file:write(timestamp .. " " .. msg .. "\n")
		file:close()
	end
end

-- Profile a function
function M.profile(name, fn, ...)
	local start_time = vim.loop.hrtime()
	local result = { fn(...) }
	local end_time = vim.loop.hrtime()
	local elapsed = (end_time - start_time) / 1000000
	M.notify(string.format("Execution of %s took %.2f ms", name, elapsed), vim.log.levels.DEBUG)
	return unpack(result)
end

-- Get stacktrace
function M.get_stacktrace()
	local trace = debug.traceback()
	return trace
end

--------------------------------------------------------------------------------
-- Miscellaneous
--------------------------------------------------------------------------------

-- Get OS name
function M.get_os()
	if vim.fn.has("win32") == 1 then
		return "Windows"
	elseif vim.fn.has("macunix") == 1 then
		return "macOS"
	else
		return "Linux"
	end
end

-- Check if running in headless mode
function M.is_headless()
	return #vim.api.nvim_list_uis() == 0
end

-- Convert bytes to human-readable size
function M.format_bytes(bytes)
	local units = { "B", "KB", "MB", "GB", "TB" }
	local i = 1
	while bytes >= 1024 and i < #units do
		bytes = bytes / 1024
		i = i + 1
	end
	return string.format("%.2f %s", bytes, units[i])
end

-- Format date/time
function M.format_date(timestamp)
	return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

-- Deep merge two tables
function M.deep_merge(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" and type(t1[k]) == "table" then
			M.deep_merge(t1[k], v)
		else
			t1[k] = v
		end
	end
	return t1
end

-- Generate a random string
function M.random_string(length)
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local result = {}
	for i = 1, length do
		local rand = math.random(1, #chars)
		table.insert(result, chars:sub(rand, rand))
	end
	return table.concat(result)
end

-- Initialize the utils module
function M.init()
	-- Seed random number generator
	math.randomseed(os.time())
	-- Create necessary directories
	M.ensure_dir(vim.fn.stdpath("cache") .. "/neocode")
end

-- Call init function when the module is loaded
M.init()

return M
