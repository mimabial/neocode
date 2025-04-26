--------------------------------------------------------------------------------
-- Database Integration
--------------------------------------------------------------------------------
--
-- This module provides database integration tools:
--
-- Features:
-- 1. Database connection management
-- 2. SQL query execution
-- 3. Result browsing and exporting
-- 4. Schema exploration
-- 5. SQL formatting
-- 6. Query history
--
-- These tools enable database operations without leaving Neovim.
--------------------------------------------------------------------------------

return {
	-- Database UI
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			"tpope/vim-dadbod", -- Core database functionality
			"kristijanhusak/vim-dadbod-completion", -- SQL completion
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			-- Load SQL completion in SQL files
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "sql", "mysql", "plsql" },
				callback = function()
					-- Check if cmp is available before requiring it
					local has_cmp, cmp = pcall(require, "cmp")
					if has_cmp then
						cmp.setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
					end
				end,
			})

			-- Save connection info
			vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

			-- Use a specific window width
			vim.g.db_ui_winwidth = 40

			-- Define icons
			vim.g.db_ui_icons = {
				expanded = "▾",
				collapsed = "▸",
				saved_query = "*",
				new_query = "+",
				tables = "󰓫",
				buffers = "󰈙",
				connection_ok = "✓",
				connection_error = "✗",
			}

			-- Set default table helper
			vim.g.db_ui_table_helpers = {
				mysql = {
					Count = "select count(1) from {table}",
					Explain = "explain {last_query}",
					Columns = "show columns from {table}",
					Indexes = "show indexes from {table}",
					Foreign = "select * from information_schema.key_column_usage where referenced_table_name is not null and table_name = '{table}'",
					Primary = "select * from information_schema.key_column_usage where constraint_name = 'PRIMARY' and table_name = '{table}'",
					Privileges = "show grants for current_user",
				},
				postgres = {
					Count = "select count(1) from {table}",
					Explain = "explain {last_query}",
					Columns = [[
            select
              a.attname as column_name,
              pg_catalog.format_type(a.atttypid, a.atttypmod) as data_type,
              case when a.attnotnull then 'NO' else 'YES' end as is_nullable,
              pg_get_expr(d.adbin, d.adrelid) as column_default
            from pg_attribute a 
            left join pg_attrdef d on a.attrelid = d.adrelid and a.attnum = d.adnum 
            where a.attnum > 0 
            and not a.attisdropped 
            and a.attrelid = (select oid from pg_class where relname = '{table}' and relkind in ('r', 'p'))
            order by a.attnum
          ]],
					Indexes = "select * from pg_indexes where tablename = '{table}'",
					Foreign = [[
            select
              tc.table_schema as schema_name,
              tc.constraint_name,
              tc.table_name,
              kcu.column_name,
              ccu.table_schema as foreign_schema_name,
              ccu.table_name as foreign_table_name,
              ccu.column_name as foreign_column_name
            from information_schema.table_constraints tc
            join information_schema.key_column_usage kcu
              on tc.constraint_name = kcu.constraint_name
              and tc.table_schema = kcu.table_schema
            join information_schema.constraint_column_usage ccu
              on ccu.constraint_name = tc.constraint_name
              and ccu.table_schema = tc.table_schema
            where tc.constraint_type = 'FOREIGN KEY'
            and tc.table_name = '{table}'
          ]],
					Primary = [[
            select
              tc.constraint_name,
              kcu.column_name
            from information_schema.table_constraints tc
            join information_schema.key_column_usage kcu
              on tc.constraint_name = kcu.constraint_name
            where tc.constraint_type = 'PRIMARY KEY'
            and tc.table_name = '{table}'
          ]],
				},
				sqlite = {
					Count = "select count(1) from {table}",
					Explain = "explain query plan {last_query}",
					Columns = "pragma table_info({table})",
					Indexes = "pragma index_list({table})",
					Foreign = "pragma foreign_key_list({table})",
				},
				sqlserver = {
					Count = "select count(1) from {table}",
					Columns = "exec sp_columns @table_name = N'{table}'",
					Indexes = "exec sp_helpindex @objname = N'{table}'",
				},
			}
		end,
		keys = {
			{ "<leader>du", "<cmd>DBUIToggle<cr>", desc = "Toggle Database UI" },
			{ "<leader>df", "<cmd>DBUIFindBuffer<cr>", desc = "Find DB Buffer" },
			{ "<leader>dr", "<cmd>DBUIRenameBuffer<cr>", desc = "Rename DB Buffer" },
			{ "<leader>dl", "<cmd>DBUILastQueryInfo<cr>", desc = "Last Query Info" },
		},
	},

	-- SQL Query Builder
	{
		"pbogut/vim-dadbod-ssh",
		dependencies = {
			"tpope/vim-dadbod",
		},
		cmd = "DBSSHExecuteCommand",
	},

	-- Database Schema Navigator
	{
		"tpope/vim-dadbod",
		cmd = { "DB", "DBExecute", "DBHistory" },
		keys = {
			{ "<leader>de", "<cmd>DBExecute<cr>", desc = "Execute Query", mode = { "n", "v" } },
			{ "<leader>ds", "<cmd>DBHistory<cr>", desc = "Query History" },
		},
	},

	-- Database connection manager
	{
		"kndndrj/nvim-dbee",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		build = function()
			-- Don't run installation during plugin setup - defer to command call
			-- The installation will be handled when the plugin is first used
		end,
		config = function()
			-- Add setup and install logic here to be run after plugin is loaded
			local dbee = require("dbee")

			-- Set up dbee with the provided options
			dbee.setup({
				sources = {
					require("dbee.sources").MemorySource:new({}),
					require("dbee.sources").FileSource:new({
						-- Path to the connections.json file
						path = vim.fn.stdpath("data") .. "/dbee/connections.json",
					}),
				},

				editor = {
					mappings = {
						execute = "<CR>",
						execute_line = "<S-CR>",
						-- This will be inferred from VISUAL mode selection automatically
						-- if left empty
						execute_selection = nil,
						-- Some other-useful mappings
						toggle_details = "K",
					},
				},

				drawer = {
					-- disable_help = true, -- Uncomment to disable help tabs
					-- disable_details = true, -- Uncomment to disable details tabs
					-- disable_indicators = false, -- Setting this to true disables the query status in the UI
					mappings = {
						-- Main drawer mappings
						toggle_drawer = "<F2>",
						change_page = "<Tab>",
						close = "Q",

						-- Select query view
						execute_query = "<CR>",

						-- Details view
						toggle_details = "K",

						-- Tables view
						copy_name = "y",
						refresh_tables = "r",

						-- Results view
						save = "s",

						-- Help view
						show_limits = "?",
					},
				},

				picker = {
					-- Prompt to use when picking a query
					telescope_prompt = "Select Query",
					telescope_theme = nil,
				},

				result = {
					max_retries = 3,
					max_column_width = 100,
					max_column_bytes = 256,
					-- max_buffer_size = 100 * 1024 * 1024, -- about 100MB
					disable_limit = false,
					limit = 200,
				},

				log = {
					-- Log level (ERROR, WARN, INFO, DEBUG)
					level = "ERROR",
					-- Log file location, defaults to system data directory
					path = nil,
					-- Max allowed log size in bytes (default 5MB)
					max_size = 5 * 1024 * 1024,
				},

				ui = {
					-- If true, the split windows will resize to fit the content
					resize_to_content = true,
					-- Border style for all windows (same as in 'nvim_open_win')
					border = "rounded",
				},
			})

			-- Create user command for installation
			vim.api.nvim_create_user_command("DBeeInstall", function(opts)
				if opts.args == "mason" then
					dbee.install("mason")
				else
					-- Parse arguments to find which drivers to install
					local drivers = {}
					for driver in string.gmatch(opts.args, "%S+") do
						drivers[driver] = "local"
					end
					if next(drivers) then
						dbee.install(drivers)
					else
						-- Default installation if no args provided
						dbee.install({
							postgresql = "local",
							mysql = "local",
						})
					end
				end
			end, {
				nargs = "*",
				desc = "Install DBee drivers (mason|driver1 driver2...)",
				complete = function()
					return { "mason", "postgresql", "mysql", "sqlite", "sqlserver" }
				end,
			})
		end,
		cmd = { "DBee", "DBeeToggle", "DBeeOpen", "DBeeClose", "DBeeInstall" },
		keys = {
			{ "<leader>db", "<cmd>DBeeToggle<cr>", desc = "Toggle DBee" },
		},
	},
}
