--------------------------------------------------------------------------------
-- File Explorer
--------------------------------------------------------------------------------
--
-- This module provides a consolidated file navigation experience using:
-- 1. Neo-tree as the primary file tree explorer
-- 2. Oil.nvim for minimal, buffer-based file navigation
--
-- Features:
-- 1. Tree-based file explorer with rich features
-- 2. Floating and split view options
-- 3. Git integration to show file status
-- 4. Inline file manipulation and renaming
-- 5. Minimal buffer-based file editing
--
-- Keymaps:
-- * <leader>e - Toggle tree file explorer
-- * - (dash) - Open parent directory in buffer view
--------------------------------------------------------------------------------

return {
	-- Primary file explorer - Neo-tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{
				"<leader>e",
				function()
					require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
				end,
				desc = "Explorer NeoTree (cwd)",
			},
			{
				"<leader>fe",
				"<cmd>Neotree toggle<cr>",
				desc = "Explorer NeoTree",
			},
			{
				"<leader>fE",
				function()
					require("neo-tree.command").execute({ action = "focus", dir = vim.loop.cwd() })
				end,
				desc = "Explorer NeoTree (focus)",
			},
		},
		opts = {
			sources = { "filesystem", "buffers", "git_status", "document_symbols" },
			open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
			filesystem = {
				bind_to_cwd = false,
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
				filtered_items = {
					visible = false,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_hidden = false,
					hide_by_name = {
						".git",
						"node_modules",
						".cache",
					},
					never_show = {
						".DS_Store",
						"__pycache__",
					},
				},
			},
			window = {
				position = "left",
				width = 30,
				mappings = {
					["<space>"] = "none",
					["o"] = "open",
					["H"] = "navigate_up",
					["-"] = "open_with_window_picker",
					["/"] = "fuzzy_finder",
					["#"] = "fuzzy_sorter",
					["h"] = function(state)
						local node = state.tree:get_node()
						if node.type == "directory" and node:is_expanded() then
							require("neo-tree.sources.filesystem").toggle_directory(state, node)
						else
							require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
						end
					end,
					["l"] = function(state)
						local node = state.tree:get_node()
						if node.type == "directory" then
							if not node:is_expanded() then
								require("neo-tree.sources.filesystem").toggle_directory(state, node)
							elseif node:has_children() then
								require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
							end
						else
							require("neo-tree.actions.custom").open(state)
						end
					end,
					["<tab>"] = function(state)
						local node = state.tree:get_node()
						if node.type == "file" then
							require("neo-tree.sources.filesystem.commands").open(state)
						elseif node.type == "directory" then
							require("neo-tree.sources.filesystem").toggle_directory(state, node)
						end
					end,
				},
			},
			default_component_configs = {
				indent = {
					with_expanders = true,
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "",
					default = "",
				},
				git_status = {
					symbols = {
						added = "",
						modified = "",
						deleted = "✖",
						renamed = "➜",
						untracked = "★",
						ignored = "◌",
						unstaged = "✗",
						staged = "✓",
						conflict = "",
					},
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
					highlight = "NeoTreeFileName",
				},
				modified = {
					symbol = "●",
					highlight = "NeoTreeModified",
				},
			},
			commands = {
				-- Custom commands can be added here
				system_open = function(state)
					local node = state.tree:get_node()
					local path = node:get_id()
					-- Open file with system application based on OS
					if vim.fn.has("mac") == 1 then
						vim.fn.jobstart({ "open", path }, { detach = true })
					elseif vim.fn.has("unix") == 1 then
						vim.fn.jobstart({ "xdg-open", path }, { detach = true })
					elseif vim.fn.has("win32") == 1 then
						vim.fn.jobstart({ "cmd.exe", "/c", "start", "", path }, { detach = true })
					end
				end,
			},
		},
	},

	-- Buffer-based file explorer - Oil.nvim
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "Oil",
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
		},
		opts = {
			-- Oil configuration
			columns = {
				"icon",
				"permissions",
				"size",
				"mtime",
			},
			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},
			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "n",
			},
			default_file_explorer = true,
			restore_win_options = true,
			skip_confirm_for_simple_edits = false,
			delete_to_trash = true,
			prompt_save_on_select_new_entry = true,
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-v>"] = "actions.select_vsplit",
				["<C-s>"] = "actions.select_split",
				["<C-t>"] = "actions.select_tab",
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-r>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = "actions.tcd",
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["g\\"] = "actions.toggle_trash",
			},
			use_default_keymaps = true,
			view_options = {
				show_hidden = false,
				is_hidden_file = function(name)
					return vim.startswith(name, ".")
				end,
				sort = {
					-- sort order: directories, files, symlinks
					func = "name",
					reverse = false,
				},
			},
			float = {
				padding = 2,
				max_width = 80,
				max_height = 30,
				border = "rounded",
				win_options = {
					winblend = 10,
				},
			},
			preview = {
				max_width = 0.7,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = 0.8,
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
			},
		},
		config = function(_, opts)
			require("oil").setup(opts)

			-- Add command to toggle between float and normal modes
			vim.api.nvim_create_user_command("OilFloat", function()
				require("oil").open_float()
			end, { desc = "Open Oil in float mode" })

			-- Add keybinding for the float mode
			vim.keymap.set("n", "<leader>fo", "<cmd>OilFloat<cr>", { desc = "Float File Explorer" })
		end,
	},

	-- Window picker for Neo-tree
	{
		"s1n7ax/nvim-window-picker",
		name = "window-picker",
		event = "VeryLazy",
		version = "2.*",
		config = function()
			require("window-picker").setup({
				filter_rules = {
					include_current_win = false,
					autoselect_one = true,
					-- filter using buffer options
					bo = {
						-- if the file type is one of following, the window will be ignored
						filetype = { "neo-tree", "neo-tree-popup", "notify" },
						-- if the buffer type is one of following, the window will be ignored
						buftype = { "terminal", "quickfix" },
					},
				},
				highlights = {
					statusline = {
						focused = {
							fg = "#ededed",
							bg = "#e35e4f",
							bold = true,
						},
						unfocused = {
							fg = "#ededed",
							bg = "#44cc41",
							bold = true,
						},
					},
				},
			})
		end,
	},
}
