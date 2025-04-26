--------------------------------------------------------------------------------
-- Terminal Integration
--------------------------------------------------------------------------------
--
-- This module provides enhanced terminal functionality:
--
-- Features:
-- 1. Floating terminal
-- 2. Multiple terminal instances
-- 3. Terminal navigation
-- 4. Toggle functionality
-- 5. Terminal commands and history
-- 6. Customizable appearance
--
-- These tools make it easier to use the terminal without leaving Neovim.
--------------------------------------------------------------------------------

return {
	-- Enhanced terminal
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "TermExec" },
		keys = {
			{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal Float" },
			{ "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal Horizontal" },
			{ "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal Vertical" },
			{ "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
			{ "<leader>1", "<cmd>1ToggleTerm<cr>", desc = "Terminal #1" },
			{ "<leader>2", "<cmd>2ToggleTerm<cr>", desc = "Terminal #2" },
			{ "<leader>3", "<cmd>3ToggleTerm<cr>", desc = "Terminal #3" },
			{ "<leader>4", "<cmd>4ToggleTerm<cr>", desc = "Terminal #4" },
			{ "<F7>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
			{ "<C-`>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
		},
		opts = {
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return math.floor(vim.o.columns * 0.4)
				end
			end,
			on_open = function()
				-- Disable line numbers in terminal
				vim.cmd("setlocal nonumber norelativenumber signcolumn=no")
				-- Start in insert mode
				vim.cmd("startinsert")
			end,
			open_mapping = [[<F7>]],
			hide_numbers = true,
			shade_filetypes = {},
			shade_terminals = true,
			shading_factor = 2,
			start_in_insert = true,
			insert_mappings = true,
			persist_size = true,
			direction = "float",
			close_on_exit = true,
			shell = vim.o.shell,
			float_opts = {
				border = "curved",
				winblend = 0,
				highlights = {
					border = "Normal",
					background = "Normal",
				},
			},
			winbar = {
				enabled = true,
				name_formatter = function(term)
					return term.name or term.id
				end,
			},
		},
		config = function(_, opts)
			require("toggleterm").setup(opts)

			-- Custom terminal commands
			local Terminal = require("toggleterm.terminal").Terminal

			-- Lazygit terminal
			local lazygit = Terminal:new({
				cmd = "lazygit",
				dir = "git_dir",
				direction = "float",
				float_opts = {
					border = "curved",
				},
				on_open = function(term)
					vim.cmd("startinsert!")
					vim.api.nvim_buf_set_keymap(
						term.bufnr,
						"n",
						"q",
						"<cmd>close<CR>",
						{ noremap = true, silent = true }
					)
				end,
			})

			-- Node terminal
			local node = Terminal:new({
				cmd = "node",
				direction = "float",
				hidden = true,
			})

			-- Python terminal
			local python = Terminal:new({
				cmd = "python",
				direction = "float",
				hidden = true,
			})

			-- HTTP Server terminal
			local http_server = Terminal:new({
				cmd = "python -m http.server 8000",
				direction = "float",
				hidden = true,
			})

			-- Register user commands
			vim.api.nvim_create_user_command("Lazygit", function()
				lazygit:toggle()
			end, { desc = "Open Lazygit" })

			vim.api.nvim_create_user_command("Node", function()
				node:toggle()
			end, { desc = "Open Node REPL" })

			vim.api.nvim_create_user_command("Python", function()
				python:toggle()
			end, { desc = "Open Python REPL" })

			vim.api.nvim_create_user_command("HttpServer", function()
				http_server:toggle()
			end, { desc = "Start HTTP Server" })

			-- Additional keymaps
			vim.keymap.set("n", "<leader>gg", "<cmd>Lazygit<CR>", { desc = "Lazygit" })
			vim.keymap.set("n", "<leader>tn", "<cmd>Node<CR>", { desc = "Node REPL" })
			vim.keymap.set("n", "<leader>tp", "<cmd>Python<CR>", { desc = "Python REPL" })
			vim.keymap.set("n", "<leader>ts", "<cmd>HttpServer<CR>", { desc = "HTTP Server" })

			-- Terminal mode mappings
			function _G.set_terminal_keymaps()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
				vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
				vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
				vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
			end

			-- Auto command to set terminal keymaps when entering terminal
			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "term://*",
				callback = function()
					set_terminal_keymaps()
				end,
			})
		end,
	},

	-- Send code to REPL
	{
		"michaelb/sniprun",
		build = "bash ./install.sh",
		cmd = { "SnipRun", "SnipInfo", "SnipReset", "SnipReplMemoryClean", "SnipClose", "SnipLive" },
		keys = {
			{ "<leader>r", "<Plug>SnipRun", mode = "v", desc = "Run Code Snippet" },
			{ "<leader>R", "<Plug>SnipRunOperator", desc = "Run Code Snippet Operator" },
			{ "<leader>rs", "<cmd>SnipRun<CR>", desc = "Run Snippet" },
			{ "<leader>rc", "<cmd>SnipClose<CR>", desc = "Close SnipRun" },
			{ "<leader>rl", "<cmd>SnipLive<CR>", desc = "Live mode" },
			{ "<leader>rr", "<cmd>SnipReset<CR>", desc = "Reset Sniprun" },
		},
		config = function()
			require("sniprun").setup({
				selected_interpreters = {}, -- Use those instead of the default for the current filetype
				repl_enable = { "Python3_original", "JavaScript", "Lua_original" }, -- Enable REPL-like behavior for the given interpreters
				repl_disable = {}, -- Disable REPL-like behavior for the given interpreters
				interpreter_options = {
					-- Interpreter-specific options, see docs / :SnipInfo <name>
					Python3_original = {
						use_on_warning = true,
					},
				},
				-- You can combo different display modes as desired
				display = {
					"Classic", -- Display results in the command line
					"VirtualTextOk", -- Display results as virtual text
				},
				live_display = { "VirtualTextOk" }, -- Display mode used in live mode
				display_options = {
					terminal_width = 45,
					notification_timeout = 5, -- Timeout for nvim_notify output
				},
				-- Customize highlight groups (setting this overrides colorscheme)
				snipruncolors = {
					SniprunVirtualTextOk = { bg = "#66eeff", fg = "#000000", ctermbg = "Cyan", cterfg = "Black" },
					SniprunFloatingWinOk = { fg = "#66eeff", ctermfg = "Cyan" },
					SniprunVirtualTextErr = { bg = "#881515", fg = "#000000", ctermbg = "DarkRed", cterfg = "Black" },
					SniprunFloatingWinErr = { fg = "#881515", ctermfg = "DarkRed" },
				},
				live_mode_toggle = "off", -- Live mode on by default, use to toggle a key a value
				borders = "single", -- Display borders around floating windows
				inline_messages = 0, -- Inline_message (0/1) is a one-line way to display messages

				-- If you have issues with REPL-like behavior, try tweaking these
				stop_capture = nil, -- If nil, captures endlessly until broken by the user
				halt_for_input = nil, -- Halt and get input on lines beginning with "=>"
			})
		end,
	},

	-- Enhanced REPL experience
	{
		"hkupty/iron.nvim",
		keys = {
			{ "<leader>is", "<cmd>IronRepl<cr>", desc = "Iron REPL" },
			{ "<leader>ir", "<cmd>IronRestart<cr>", desc = "Restart Iron REPL" },
			{ "<leader>if", "<cmd>IronFocus<cr>", desc = "Focus Iron REPL" },
			{ "<leader>ih", "<cmd>IronHide<cr>", desc = "Hide Iron REPL" },
		},
		config = function()
			local iron = require("iron.core")

			iron.setup({
				config = {
					-- Whether a repl should be discarded or not
					scratch_repl = true,
					-- Your repl definitions come here
					repl_definition = {
						sh = {
							-- Can be a table or a function that
							-- returns a table (see below)
							command = { "zsh" },
						},
						python = {
							command = { "ipython" },
							format = require("iron.fts.common").bracketed_paste,
						},
						lua = {
							command = { "lua" },
						},
						javascript = {
							command = { "node" },
						},
						typescript = {
							command = { "ts-node" },
						},
					},
					-- How the repl window will be displayed
					-- See below for more information
					repl_open_cmd = require("iron.view").right(50),
				},
				-- If the highlight is on, you can change how it looks
				-- For the available options, check nvim_set_hl
				highlight = {
					italic = true,
				},
				keymaps = {
					send_motion = "<leader>sc",
					visual_send = "<leader>sc",
					send_line = "<leader>sl",
					send_file = "<leader>sf",
					send_mark = "<leader>sm",
					mark_motion = "<leader>mc",
					mark_visual = "<leader>mc",
					remove_mark = "<leader>md",
					cr = "<leader>s<cr>",
					interrupt = "<leader>s<space>",
					exit = "<leader>sq",
					clear = "<leader>cl",
				},
				-- If you don't want to map any keys, you can set the value to an empty
				-- table and map them yourself
				ignore_blank_lines = true, -- Whether to ignore blank lines or not when sending visual selection
			})
		end,
	},

	-- Command runner
	{
		"stevearc/overseer.nvim",
		keys = {
			{ "<leader>oo", "<cmd>OverseerRun<cr>", desc = "Run Task" },
			{ "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Toggle Tasks" },
			{ "<leader>oc", "<cmd>OverseerBuild<cr>", desc = "Build Task" },
			{ "<leader>ob", "<cmd>OverseerRunCmd<cr>", desc = "Run Command" },
			{ "<leader>ol", "<cmd>OverseerLoadBundle<cr>", desc = "Load Bundle" },
			{ "<leader>os", "<cmd>OverseerSaveBundle<cr>", desc = "Save Bundle" },
			{ "<leader>oa", "<cmd>OverseerQuickAction<cr>", desc = "Quick Action" },
			{ "<leader>od", "<cmd>OverseerTaskAction<cr>", desc = "Task Action" },
		},
		config = function()
			require("overseer").setup({
				-- Task list appearance
				task_list = {
					direction = "bottom",
					min_height = 15,
					max_height = 20,
					height = nil,
					bindings = {
						["?"] = "ShowHelp",
						["<CR>"] = "RunAction",
						["<C-e>"] = "Edit",
						["o"] = "Open",
						["<C-v>"] = "OpenVsplit",
						["<C-s>"] = "OpenSplit",
						["<C-f>"] = "OpenFloat",
						["<C-q>"] = "OpenQuickFix",
						["p"] = "TogglePreview",
						["<C-l>"] = "IncreaseDetail",
						["<C-h>"] = "DecreaseDetail",
						["L"] = "IncreaseAllDetail",
						["H"] = "DecreaseAllDetail",
						["["] = "DecreaseWidth",
						["]"] = "IncreaseWidth",
						["{"] = "PrevTask",
						["}"] = "NextTask",
						["<C-c>"] = "Dispose",
						["<C-k>"] = "SignalTask",
						["<C-r>"] = "RestartTask",
						["<C-x>"] = "ToggleAutoDispose",
					},
				},
				task_win = {
					border = "rounded",
					height = 10,
					width = 80,
					win_opts = {
						winblend = 10,
					},
				},
				confirm = {
					border = "rounded",
					win_opts = {
						winblend = 10,
					},
				},
				task_editor = {
					border = "rounded",
					win_opts = {
						winblend = 10,
					},
				},
				form = {
					border = "rounded",
					win_opts = {
						winblend = 10,
					},
				},
				strategy = {
					toggleterm = {
						direction = "float",
						close_on_exit = false,
						open_on_start = true,
						quit_on_exit = "never",
					},
				},
				-- Template list appearance
				template_win = {
					border = "rounded",
					win_opts = {
						winblend = 10,
					},
				},
				-- Common task components
				component_aliases = {
					-- Display output in a toggleable terminal
					toggleterm = {
						"on_output_summarize",
						"on_exit_set_status",
						"on_complete_notify",
						"on_complete_dispose",
					},
					-- Run a command through a shell
					default = {
						"on_result_diagnostics",
						"on_result_diagnostics_quickfix",
						"on_output_summarize",
						"on_exit_set_status",
						"on_complete_notify",
					},
				},
				-- Predefined templates for common tasks
				templates = {
					"builtin",
					{
						name = "Run current file",
						builder = function()
							local file = vim.fn.expand("%:p")
							local cmd = file
							local ft = vim.bo.filetype
							if ft == "python" then
								cmd = "python " .. file
							elseif ft == "javascript" or ft == "typescript" then
								cmd = "node " .. file
							elseif ft == "lua" then
								cmd = "lua " .. file
							elseif ft == "sh" or ft == "bash" then
								cmd = "bash " .. file
							elseif ft == "go" then
								cmd = "go run " .. file
							elseif ft == "rust" then
								cmd = "cargo run"
							elseif ft == "c" or ft == "cpp" then
								local out = vim.fn.expand("%:r")
								cmd = "gcc " .. file .. " -o " .. out .. " && " .. out
							elseif ft == "java" then
								local class = vim.fn.expand("%:r")
								cmd = "javac " .. file .. " && java " .. class
							end
							return {
								cmd = cmd,
								components = { "default" },
							}
						end,
					},
				},
			})
		end,
	},

	-- Code runner
	{
		"CRAG666/code_runner.nvim",
		keys = {
			{ "<leader>cr", "<cmd>RunCode<CR>", desc = "Run Code" },
			{ "<leader>crf", "<cmd>RunFile<CR>", desc = "Run File" },
			{ "<leader>crp", "<cmd>RunProject<CR>", desc = "Run Project" },
			{ "<leader>crc", "<cmd>RunClose<CR>", desc = "Close Runner" },
		},
		config = function()
			require("code_runner").setup({
				-- Choose default mode (valid term, tab, float, toggle, buf)
				mode = "float",
				-- Focus on runner window (only works on toggle, term and tab mode)
				focus = true,
				-- Startinsert when entering runner window (only works on toggle, term and tab mode)
				startinsert = true,
				term = {
					-- Position to open terminal
					position = "bot",
					-- Window size, can be a number or function that returns a number
					size = 12,
				},
				float = {
					-- Key that close the code_runner floating window
					close_key = "q",
					-- Window border (see ':h nvim_open_win')
					border = "rounded",
					-- Num from 0 - 1 for measurements
					height = 0.8,
					width = 0.8,
					x = 0.5,
					y = 0.5,
					-- Highlight group for floating window/border (see ':h winhl')
					border_hl = "FloatBorder",
					float_hl = "Normal",
					-- Transparency (see ':h winblend')
					blend = 0,
				},
				-- Filetype to use specific commands
				filetype = {
					javascript = "node",
					typescript = "deno run",
					java = {
						"cd $dir &&",
						"javac $fileName &&",
						"java $fileNameWithoutExt",
					},
					c = {
						"cd $dir &&",
						"gcc $fileName -o $fileNameWithoutExt &&",
						"$dir/$fileNameWithoutExt",
					},
					cpp = {
						"cd $dir &&",
						"g++ $fileName -o $fileNameWithoutExt &&",
						"$dir/$fileNameWithoutExt",
					},
					python = "python -u",
					rust = {
						"cd $dir &&",
						"rustc $fileName &&",
						"$dir/$fileNameWithoutExt",
					},
					go = "go run",
					lua = "lua",
					sh = "bash",
					zsh = "zsh",
					bash = "bash",
				},
				-- Predefined project commands
				project = {
					-- Example: running Django project
					["~/dev/django_project"] = {
						name = "Django Project",
						command = "cd ~/dev/django_project && python manage.py runserver",
					},
					-- Example: running React project
					["~/dev/react_project"] = {
						name = "React Project",
						command = "cd ~/dev/react_project && npm start",
					},
				},
			})
		end,
	},
}
