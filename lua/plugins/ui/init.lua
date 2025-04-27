--------------------------------------------------------------------------------
-- UI Components
--------------------------------------------------------------------------------
--
-- This module loads all UI-related components:
-- 1. Colorscheme (colorscheme.lua)
-- 2. Status line (statusline.lua)
-- 3. Dashboard (dashboard.lua)
-- 4. Notification system (notify.lua)
-- 5. Command line enhancements (noice.lua)
-- 6. UI input improvements (dressing.lua)
-- 7. Animations (animate.lua)
-- 8. Document headlines (headlines.lua)
-- 9. Minimap (codewindow.lua)
-- 10. Navigation breadcrumbs (navic.lua)
--
-- These plugins improve the visual appearance and interface of Neovim while
-- maintaining performance and responsiveness.
--------------------------------------------------------------------------------

return {
	-- Import UI modules
	{ import = "plugins.ui.colorscheme" }, -- Color themes
	{ import = "plugins.ui.statusline" }, -- Status line
	{ import = "plugins.ui.dashboard" }, -- Welcome screen
	{ import = "plugins.ui.notify" }, -- Notification system
	{ import = "plugins.ui.noice" }, -- Command line and messages
	{ import = "plugins.ui.dressing" }, -- Input UI
	{ import = "plugins.ui.animate" }, -- Smooth animations
	{ import = "plugins.ui.headlines" }, -- Document headlines
	{ import = "plugins.ui.codewindow" }, -- Minimap
	{ import = "plugins.ui.navic" }, -- Code context
	{ import = "plugins.ui.bufferline" }, -- buffer line
	-- File icons
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		opts = {
			strict = true,
			override_by_extension = {
				-- Custom icons for specific file extensions
				["json"] = {
					icon = "",
					color = "#cbcb41",
					name = "JSON",
				},
				["js"] = {
					icon = "",
					color = "#cbcb41",
					name = "JavaScript",
				},
				["ts"] = {
					icon = "ﯤ",
					color = "#519aba",
					name = "TypeScript",
				},
				["py"] = {
					icon = "",
					color = "#3572A5",
					name = "Python",
				},
				["go"] = {
					icon = "ﳑ",
					color = "#519aba",
					name = "Go",
				},
				["rs"] = {
					icon = "",
					color = "#dea584",
					name = "Rust",
				},
			},
			override_by_filename = {
				-- Custom icons for specific filenames
				[".gitignore"] = {
					icon = "",
					color = "#f1502f",
					name = "Gitignore",
				},
				["package.json"] = {
					icon = "",
					color = "#8bc34a",
					name = "PackageJson",
				},
				["tsconfig.json"] = {
					icon = "ﯤ",
					color = "#519aba",
					name = "TSConfig",
				},
				["dockerfile"] = {
					icon = "",
					color = "#458ee6",
					name = "Dockerfile",
				},
				["docker-compose.yml"] = {
					icon = "",
					color = "#458ee6",
					name = "DockerCompose",
				},
			},
		},
	},

	-- File explorer
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
				},
			},
			default_component_configs = {
				indent = {
					with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
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
			},
		},
	},

	-- Active indent guides and indent text objects
	{
		"echasnovski/mini.indentscope",
		version = false, -- wait till new 0.7.0 release to put it back on semver
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			symbol = "│",
			options = { try_as_border = true },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},

	-- Scrollbar with integration for diagnostics, search, git, etc.
	{
		"petertriho/nvim-scrollbar",
		event = "BufReadPost",
		opts = {
			show = true,
			handle = {
				text = " ",
				color = "#44475a",
				cterm = nil,
				highlight = "CursorColumn",
				hide_if_all_visible = true,
			},
			marks = {
				Search = {
					text = { "-", "=" },
					priority = 0,
					color = "#ff9e64",
				},
				Error = {
					text = { "-", "=" },
					priority = 1,
					color = "#f7768e",
				},
				Warn = {
					text = { "-", "=" },
					priority = 2,
					color = "#e0af68",
				},
				Info = {
					text = { "-", "=" },
					priority = 3,
					color = "#7aa2f7",
				},
				Hint = {
					text = { "-", "=" },
					priority = 4,
					color = "#1abc9c",
				},
				Misc = {
					text = { "-", "=" },
					priority = 5,
					color = "#9d7cd8",
				},
			},
			handlers = {
				cursor = true,
				diagnostic = true,
				gitsigns = true,
				handle = true,
				search = true,
			},
		},
	},

	-- Improved folds with pretty UI
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async",
			{
				"luukvbaal/statuscol.nvim",
				config = function()
					local builtin = require("statuscol.builtin")
					require("statuscol").setup({
						relculright = true,
						segments = {
							{ text = { builtin.foldfunc }, click = "v:lua.ScFa" },
							{ text = { "%s" }, click = "v:lua.ScSa" },
							{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
						},
					})
				end,
			},
		},
		event = "BufReadPost",
		opts = {
			provider_selector = function()
				return { "treesitter", "indent" }
			end,
			open_fold_hl_timeout = 150,
			preview = {
				win_config = {
					border = { "", "─", "", "", "", "─", "", "" },
					winhighlight = "Normal:Folded",
					winblend = 0,
				},
				mappings = {
					scrollU = "<C-u>",
					scrollD = "<C-d>",
					jumpTop = "[",
					jumpBot = "]",
				},
			},
		},
		init = function()
			vim.o.foldcolumn = "1"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
			vim.keymap.set("n", "K", function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end)
		end,
	},
}
