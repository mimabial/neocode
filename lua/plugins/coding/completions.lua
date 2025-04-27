--------------------------------------------------------------------------------
-- Code Completion Configuration
--------------------------------------------------------------------------------
--
-- This module configures intelligent code completion with:
-- 1. nvim-cmp - Main completion engine
-- 2. LuaSnip - Snippet engine
-- 3. Various completion sources (LSP, snippets, buffer, path, etc.)
-- 4. UI customization for the completion menu
-- 5. Enhanced documentation display
--
-- The completion system prioritizes:
-- - LSP suggestions (with documentation and signatures)
-- - Snippets for common patterns
-- - AI completions (from Codeium)
-- - Context-aware completions from the current buffer
-- - File paths and environment variables
--------------------------------------------------------------------------------

return {
	-- Main completion plugin
	{
		"hrsh7th/nvim-cmp",
		version = false, -- Using the latest version
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			-- Snippet engine
			"L3MON4D3/LuaSnip",

			-- LSP completion source
			"hrsh7th/cmp-nvim-lsp",

			-- Buffer completions
			"hrsh7th/cmp-buffer",

			-- Path completions
			"hrsh7th/cmp-path",

			-- Command line completions
			"hrsh7th/cmp-cmdline",

			-- Neovim Lua API completions
			"hrsh7th/cmp-nvim-lua",

			-- Snippet completions
			"saadparwaiz1/cmp_luasnip",

			-- Function parameter completions
			"hrsh7th/cmp-nvim-lsp-signature-help",

			-- Document symbol completions
			"hrsh7th/cmp-nvim-lsp-document-symbol",

			-- VS Code-like pictograms
			"onsails/lspkind.nvim",

			-- Tailwind CSS colors in completion
			"roobert/tailwindcss-colorizer-cmp.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			local compare = require("cmp.config.compare")

			-- Configure Tailwind CSS integration
			require("tailwindcss-colorizer-cmp").setup({ color_square_width = 2 })

			-- Helper function to check for text before cursor
			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
						and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			-- Main nvim-cmp configuration
			cmp.setup({
				-- Use LuaSnip as the snippet engine
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				-- Customize the completion windows
				window = {
					completion = cmp.config.window.bordered({
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
						col_offset = -3,
						side_padding = 0,
					}),
					documentation = cmp.config.window.bordered({
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
					}),
				},

				-- Customize the completion menu
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						local kind = lspkind.cmp_format({
							mode = "symbol_text",
							maxwidth = 50,
							ellipsis_char = "...",
							show_labelDetails = true,
							menu = {
								buffer = "[Buffer]",
								nvim_lsp = "[LSP]",
								luasnip = "[Snippet]",
								nvim_lua = "[Lua]",
								path = "[Path]",
								codeium = "[AI]",
								calc = "[Calc]",
							},
							before = function(_, vim_item)
								-- Colorize Tailwind CSS classes
								return require("tailwindcss-colorizer-cmp").formatter(_, vim_item)
							end,
						})(entry, vim_item)

						return kind
					end,
				},

				-- Configure key mappings for completion menu interaction
				mapping = cmp.mapping.preset.insert({
					-- Scroll the documentation window
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Open/close the completion menu
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),

					-- Accept the selected completion item
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = false, -- Only confirm explicitly selected items
					}),

					-- Navigate completion items
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				-- Configure the sources for completions (in order of priority)
				sources = cmp.config.sources({
					{ name = "nvim_lsp",                priority = 1000 },
					{ name = "nvim_lsp_signature_help", priority = 900 },
					{ name = "luasnip",                 priority = 800 },
					-- AI completion source (Codeium) will be inserted by the AI module
					{
						name = "buffer",
						priority = 700,
						option = {
							get_bufnrs = function()
								return vim.api.nvim_list_bufs()
							end,
							keyword_length = 3,
						},
					},
					{ name = "path",       priority = 600 },
					{ name = "nvim_lua",   priority = 500 },
					{ name = "calc",       priority = 400 },
					{ name = "emoji",      priority = 300 },
					{ name = "treesitter", priority = 200 },
				}),

				-- Configure sorting for completion items
				sorting = {
					priority_weight = 2,
					comparators = {
						-- Deprioritize snippets under other completion items
						function(entry1, entry2)
							local kind1 = entry1:get_kind()
							local kind2 = entry2:get_kind()
							if kind1 == kind2 then
								return nil
							end
							if kind1 == cmp.lsp_item_kind.Snippet then
								return false
							end
							if kind2 == cmp.lsp_item_kind.Snippet then
								return true
							end
							return nil
						end,
						compare.offset,
						compare.exact,
						compare.score,
						compare.recently_used,
						compare.locality,
						compare.kind,
						compare.sort_text,
						compare.length,
						compare.order,
					},
				},

				-- Experimental features
				experimental = {
					ghost_text = {
						hl_group = "Comment",
					},
				},
			})

			-- Set up completion for command mode (`:`)
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
					{ name = "cmdline" },
				}),
				formatting = {
					fields = { "abbr", "kind" },
					format = function(_, vim_item)
						vim_item.kind = ""
						return vim_item
					end,
				},
			})

			-- Set up completion for search mode (`/`)
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
				formatting = {
					fields = { "abbr", "kind" },
					format = function(_, vim_item)
						vim_item.kind = ""
						return vim_item
					end,
				},
			})

			-- Auto pairs integration
			local autopairs_ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
			if autopairs_ok then
				local handlers = require("nvim-autopairs.completion.handlers")

				cmp.event:on(
					"confirm_done",
					cmp_autopairs.on_confirm_done({
						filetypes = {
							-- Disable for specific filetypes
							["*"] = {
								["("] = {
									kind = {
										cmp.lsp_item_kind.Function,
										cmp.lsp_item_kind.Method,
									},
									handler = handlers["*"],
								},
							},
							-- Disable for specific languages
							tex = false,
							markdown = false,
						},
					})
				)
			end
		end,
	},

	-- Auto pairs for brackets, quotes, etc.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,                           -- Use treesitter to check for pairs
				ts_config = {
					lua = { "string", "source" },            -- Don't add pairs in lua string treesitter nodes
					javascript = { "string", "template_string" }, -- Don't add pairs in javascript template_string
				},
				fast_wrap = {
					map = "<M-e>", -- Mapping to wrap with pairs
					chars = { "{", "[", "(", '"', "'" },
					pattern = [=[[%'%"%>%]%)%}%,]]=],
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					manual_position = false,
					highlight = "Search",
					highlight_grey = "Comment",
				},
				disable_filetype = { "TelescopePrompt", "vim" },
			})
		end,
	},

	-- Auto completion for HTML/JSX tags
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		ft = {
			"html",
			"xml",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"svelte",
			"vue",
			"tsx",
			"jsx",
			"rescript",
			"php",
			"markdown",
			"astro",
			"handlebars",
			"hbs",
			"glimmer",
		},
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	-- Comment generation
	{
		"danymat/neogen",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("neogen").setup({
				enabled = true,
				input_after_comment = true, -- Positions cursor inside a generated comment
				snippet_engine = "luasnip", -- Use LuaSnip for templates
				languages = {
					python = {
						template = {
							annotation_convention = "google_docstrings", -- Can be: reST, numpydoc, google_docstrings, sphinx
						},
					},
					typescript = {
						template = {
							annotation_convention = "tsdoc", -- Can be: tsdoc, jsdoc
						},
					},
					javascript = {
						template = {
							annotation_convention = "jsdoc",
						},
					},
					lua = {
						template = {
							annotation_convention = "emmylua",
						},
					},
					rust = {
						template = {
							annotation_convention = "rustdoc",
						},
					},
					java = {
						template = {
							annotation_convention = "javadoc",
						},
					},
					c = {
						template = {
							annotation_convention = "doxygen",
						},
					},
					cpp = {
						template = {
							annotation_convention = "doxygen",
						},
					},
					go = {
						template = {
							annotation_convention = "godoc",
						},
					},
				},
			})

			-- Add keymaps for generating documentation
			vim.keymap.set("n", "<leader>cd", require("neogen").generate, { desc = "Generate Documentation" })

			-- Add additional keymaps for specific type of documentation
			vim.keymap.set("n", "<leader>cdf", function()
				require("neogen").generate({ type = "func" })
			end, { desc = "Generate Function Doc" })

			vim.keymap.set("n", "<leader>cdc", function()
				require("neogen").generate({ type = "class" })
			end, { desc = "Generate Class Doc" })

			vim.keymap.set("n", "<leader>cdt", function()
				require("neogen").generate({ type = "type" })
			end, { desc = "Generate Type Doc" })

			vim.keymap.set("n", "<leader>cff", function()
				require("neogen").generate({ type = "file" })
			end, { desc = "Generate File Doc" })
		end,
	},
}
