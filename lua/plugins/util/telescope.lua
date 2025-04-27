--------------------------------------------------------------------------------
-- Telescope Configuration
--------------------------------------------------------------------------------
--
-- This module configures Telescope, a highly extensible fuzzy finder.
--
-- Features:
-- 1. Fuzzy finding for files, buffers, and text
-- 2. LSP integration for symbols and references
-- 3. Git integration for branches, commits, and status
-- 4. Native speed with fzf-native
-- 5. Advanced filtering with live grep arguments
-- 6. UI customization with borders and icons
--
-- Telescope is the central navigation tool in this configuration.
--------------------------------------------------------------------------------

return {
	-- Main Telescope plugin
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		version = false, -- Use latest release
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Faster sorter
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			-- UI for vim.ui.select
			"nvim-telescope/telescope-ui-select.nvim",
			-- Advanced grep with arguments
			"nvim-telescope/telescope-live-grep-args.nvim",
			-- File browser
			"nvim-telescope/telescope-file-browser.nvim",
			-- Project management
			"nvim-telescope/telescope-project.nvim",
		},
		keys = {
			-- File operations
			{ "<leader>ff", "<cmd>Telescope find_files<cr>",                                                             desc = "Find Files" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>",                                                               desc = "Recent Files" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>",                                                                desc = "Buffers" },
			{ "<leader>fs", "<cmd>Telescope live_grep<cr>",                                                              desc = "Find Text" },
			{ "<leader>fc", "<cmd>Telescope grep_string<cr>",                                                            desc = "Find Word" },
			{ "<leader>fF", function() require("telescope.builtin").find_files({ hidden = true, no_ignore = true }) end, desc = "Find All Files" },
			{ "<leader>fw", function() require("telescope.builtin").live_grep({ grep_open_files = true }) end,           desc = "Find in Open Files" },
			{ "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>",                                              desc = "Find in Buffer" },

			-- Git operations
			{ "<leader>gc", "<cmd>Telescope git_commits<cr>",                                                            desc = "Git Commits" },
			{ "<leader>gs", "<cmd>Telescope git_status<cr>",                                                             desc = "Git Status" },
			{ "<leader>gb", "<cmd>Telescope git_branches<cr>",                                                           desc = "Git Branches" },
			{ "<leader>gf", "<cmd>Telescope git_files<cr>",                                                              desc = "Git Files" },

			-- LSP operations
			{ "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>",                                                   desc = "Document Symbols" },
			{ "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",                                          desc = "Workspace Symbols" },
			{ "<leader>lr", "<cmd>Telescope lsp_references<cr>",                                                         desc = "References" },
			{ "<leader>ld", "<cmd>Telescope diagnostics bufnr=0<cr>",                                                    desc = "Document Diagnostics" },
			{ "<leader>lD", "<cmd>Telescope diagnostics<cr>",                                                            desc = "Workspace Diagnostics" },

			-- Utilities
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>",                                                              desc = "Help Tags" },
			{ "<leader>fk", "<cmd>Telescope keymaps<cr>",                                                                desc = "Keymaps" },
			{ "<leader>fm", "<cmd>Telescope marks<cr>",                                                                  desc = "Jump to Mark" },
			{ "<leader>fn", "<cmd>Telescope notify<cr>",                                                                 desc = "Notifications" },
			{ "<leader>fp", "<cmd>Telescope projects<cr>",                                                               desc = "Projects" },
			{ "<leader>fB", "<cmd>Telescope file_browser<cr>",                                                           desc = "File Browser" },
			{ "<leader>ft", "<cmd>Telescope filetypes<cr>",                                                              desc = "Filetypes" },
			{
				"<leader>fg",
				function() require("telescope").extensions.live_grep_args.live_grep_args() end,
				desc = "Find Text (with Args)"
			},
			{ "<leader>fR", "<cmd>Telescope resume<cr>", desc = "Resume Last Search" },
		},
		opts = {
			defaults = {
				-- Appearance
				prompt_prefix = "   ",
				selection_caret = "  ",
				entry_prefix = "   ",
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},

				-- Behavior
				path_display = { "truncate" },
				dynamic_preview_title = true,

				-- UI elements
				winblend = 0,
				border = true,
				borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				color_devicons = true,

				-- File operations
				file_sorter = require("telescope.sorters").get_fuzzy_file,
				file_ignore_patterns = {
					"^.git/",
					"^./.git/",
					"^node_modules/",
					"^dist/",
					"^build/",
					"^target/",
					"%.lock",
					"%.min.js",
					"%.map",
					"^vendor/",
					"%.jpeg$",
					"%.jpg$",
					"%.png$",
					"%.svg$",
					"%.webp$",
					"%.pdf$",
					"%.zip$",
					"%.tar$",
					"%.gz$",
				},

				-- Text operations
				generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,

				-- Mappings
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
						["<Down>"] = "move_selection_next",
						["<Up>"] = "move_selection_previous",
						["<C-n>"] = "cycle_history_next",
						["<C-p>"] = "cycle_history_prev",
						["<C-c>"] = "close",
						["<C-u>"] = "preview_scrolling_up",
						["<C-d>"] = "preview_scrolling_down",
						["<C-f>"] = "preview_scrolling_down",
						["<C-b>"] = "preview_scrolling_up",
						["<C-q>"] = "send_to_qflist",
						["<M-q>"] = "send_selected_to_qflist",
						["<C-l>"] = "complete_tag",
						["<C-h>"] = "which_key",
						["<Tab>"] = "toggle_selection + move_selection_next",
						["<S-Tab>"] = "toggle_selection + move_selection_previous",
						["<C-s>"] = "select_horizontal",
						["<C-v>"] = "select_vertical",
						["<C-t>"] = "select_tab",
					},
					n = {
						["<Esc>"] = "close",
						["q"] = "close",
						["<CR>"] = "select_default",
						["<C-s>"] = "select_horizontal",
						["<C-v>"] = "select_vertical",
						["<C-t>"] = "select_tab",
						["<C-q>"] = "send_to_qflist",
						["<M-q>"] = "send_selected_to_qflist",
						["j"] = "move_selection_next",
						["k"] = "move_selection_previous",
						["H"] = "move_to_top",
						["M"] = "move_to_middle",
						["L"] = "move_to_bottom",
						["<Down>"] = "move_selection_next",
						["<Up>"] = "move_selection_previous",
						["gg"] = "move_to_top",
						["G"] = "move_to_bottom",
						["<C-u>"] = "preview_scrolling_up",
						["<C-d>"] = "preview_scrolling_down",
						["?"] = "which_key",
						["<Tab>"] = "toggle_selection + move_selection_next",
						["<S-Tab>"] = "toggle_selection + move_selection_previous",
					},
				},

				-- ripgrep options
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
					"--glob=!.git/",
				},
			},

			-- Configure pickers
			pickers = {
				find_files = {
					hidden = true,
					find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" },
				},
				live_grep = {
					additional_args = function()
						return { "--hidden", "--glob=!.git/" }
					end,
				},
				buffers = {
					show_all_buffers = true,
					sort_lastused = true,
					mappings = {
						i = {
							["<C-d>"] = "delete_buffer",
						},
						n = {
							["dd"] = "delete_buffer",
						},
					},
				},
				colorscheme = {
					enable_preview = true,
				},
			},

			-- Configure extensions
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
				live_grep_args = {
					auto_quoting = true,
					mappings = {
						i = {
							["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
							["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt({ postfix = " --iglob " }),
						},
					},
				},
				["ui-select"] = {
					require("telescope.themes").get_dropdown({
						previewer = false,
						initial_mode = "normal",
						sorting_strategy = "ascending",
						layout_config = {
							horizontal = {
								width = 0.5,
								height = 0.4,
								preview_width = 0.6,
							},
							vertical = {
								width = 0.5,
								height = 0.4,
								preview_height = 0.5,
							},
						},
					}),
				},
				file_browser = {
					theme = "dropdown",
					hijack_netrw = true,
					mappings = {
						i = {
							["<C-w>"] = function() vim.cmd("normal vbd") end,
						},
						n = {
							["h"] = require("telescope._extensions.file_browser.actions").goto_parent_dir,
							["l"] = "select_default",
						},
					},
				},
			},
		},
		config = function(_, opts)
			-- Setup telescope
			local telescope = require("telescope")
			telescope.setup(opts)

			-- Load extensions
			telescope.load_extension("fzf")
			telescope.load_extension("ui-select")
			telescope.load_extension("live_grep_args")
			telescope.load_extension("file_browser")
			telescope.load_extension("project")

			-- Try to load optional extensions
			local optional_extensions = {
				"notify",   -- For nvim-notify
				"projects", -- For project.nvim
				"harpoon",  -- For harpoon
				"frecency", -- For frequency-based sorting
				"dap",      -- For debugging
				"yank_history", -- For yank history
			}

			for _, ext in ipairs(optional_extensions) do
				pcall(telescope.load_extension, ext)
			end
		end,
	},

	-- Faster sorter for Telescope
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		lazy = true,
	},

	-- Project management
	{
		"ahmedkhalf/project.nvim",
		event = "VeryLazy",
		config = function()
			require("project_nvim").setup({
				detection_methods = { "pattern", "lsp" },
				patterns = { ".git", "Makefile", "package.json", "pyproject.toml", "Cargo.toml" },
				silent_chdir = true,
				show_hidden = false,
			})
		end,
	},

	-- Enhanced undo tree with Telescope integration
	{
		"debugloop/telescope-undo.nvim",
		keys = {
			{ "<leader>fu", "<cmd>Telescope undo<cr>", desc = "Undo History" },
		},
		config = function()
			require("telescope").load_extension("undo")
		end,
	},
}
