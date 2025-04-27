--------------------------------------------------------------------------------
-- AI Coding Assistance
--------------------------------------------------------------------------------
--
-- This module configures AI assistance for coding:
-- 1. Codeium for AI-powered completions
-- 2. Gen.nvim for more advanced AI operations
--
-- Features:
-- - AI-powered code completions
-- - Code explanation and documentation generation
-- - Smart refactoring suggestions
-- - Custom prompts for common coding tasks
--
-- The AI integration enhances coding efficiency while maintaining control.
--------------------------------------------------------------------------------

return {
	-- Codeium - Free alternative to Copilot with strong completion capabilities
	{
		"Exafunction/codeium.nvim",
		event = "InsertEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup({
				-- Enable the chat interface
				enable_chat = true,
				-- Store binaries in the proper location
				bin_path = vim.fn.stdpath("data") .. "/codeium/bin",
				-- Store configuration in the proper location
				config_path = vim.fn.stdpath("config") .. "/codeium",
				-- API connection settings
				api = {
					host = "server.codeium.com",
					port = "443",
				},
			})

			-- Register the codeium source with nvim-cmp
			local cmp = require("cmp")
			local compare = require("cmp.config.compare")

			-- Adjusting the nvim-cmp configuration to insert Codeium
			local cmp_config = cmp.get_config()
			table.insert(cmp_config.sources, 1, { name = "codeium", priority = 1200 })

			-- Prioritize Codeium over other sources
			cmp_config.sorting = {
				priority_weight = 2,
				comparators = {
					-- Prioritize codeium suggestions
					require("codeium.comparators").prioritize,
					-- Then use the default comparators
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
			}

			cmp.setup(cmp_config)

			-- Setup keymaps for Codeium
			vim.keymap.set("i", "<C-g>", function()
				return vim.fn["codeium#Accept"]()
			end, { expr = true, silent = true, desc = "Accept Codeium suggestion" })

			vim.keymap.set("i", "<C-n>", function()
				return vim.fn["codeium#CycleCompletions"](1)
			end, { expr = true, silent = true, desc = "Next Codeium suggestion" })

			vim.keymap.set("i", "<C-p>", function()
				return vim.fn["codeium#CycleCompletions"](-1)
			end, { expr = true, silent = true, desc = "Previous Codeium suggestion" })

			vim.keymap.set("i", "<C-x>", function()
				return vim.fn["codeium#Clear"]()
			end, { expr = true, silent = true, desc = "Clear Codeium suggestions" })

			-- Codeium chat commands
			vim.api.nvim_create_user_command("CodeiumChat", function()
				require("codeium.chat").open()
			end, { desc = "Open Codeium chat" })
		end,
	},

	-- Code explanation and AI tasks with Gen.nvim
	{
		"david-kunz/gen.nvim",
		cmd = { "Gen" },
		keys = {
			{ "<leader>aa", function() require("gen").select_model() end, desc = "AI Select Model" },
			{ "<leader>ae", "<cmd>Gen Explain<CR>",                       desc = "AI Explain Code",   mode = { "n", "v" } },
			{ "<leader>ar", "<cmd>Gen Refactor<CR>",                      desc = "AI Refactor Code",  mode = { "n", "v" } },
			{ "<leader>ad", "<cmd>Gen Doc<CR>",                           desc = "AI Generate Doc",   mode = { "n", "v" } },
			{ "<leader>at", "<cmd>Gen Tests<CR>",                         desc = "AI Generate Tests", mode = { "n", "v" } },
			{ "<leader>ao", "<cmd>Gen Optimize<CR>",                      desc = "AI Optimize Code",  mode = { "n", "v" } },
			{ "<leader>af", "<cmd>Gen FindBugs<CR>",                      desc = "AI Find Bugs",      mode = { "n", "v" } },
		},
		opts = {
			-- Default model to use
			model = "claude-3-opus-20240229",
			-- Display model responses in a floating window
			display_mode = "float",
			-- Hide the prompt in the output window
			show_prompt = false,
			-- Don't show the model name to save space
			show_model = false,
			-- Automatically close the window when done
			no_auto_close = false,
			-- Predefined prompts for common code operations
			prompts = {
				-- Explain code in detail
				Explain = {
					prompt = "Explain the following code in detail:\n$text",
					model = "claude-3-opus-20240229",
				},
				-- Generate comprehensive documentation
				Doc = {
					prompt =
					"Generate comprehensive documentation for this code including parameters, return values, exceptions, and examples:\n$text",
					model = "claude-3-opus-20240229",
				},
				-- Refactor code to improve quality
				Refactor = {
					prompt =
					"Refactor the following code to improve readability, performance, and maintainability. Explain the improvements you made:\n$text",
					model = "claude-3-opus-20240229",
				},
				-- Optimize code for performance
				Optimize = {
					prompt =
					"Optimize the following code for better performance while maintaining the same behavior. Explain your optimizations:\n$text",
					model = "claude-3-opus-20240229",
				},
				-- Find potential bugs and issues
				FindBugs = {
					prompt =
					"Analyze this code for potential bugs, edge cases, and maintenance issues. Suggest specific fixes for each problem you find:\n$text",
					model = "claude-3-opus-20240229",
				},
				-- Generate unit tests
				Tests = {
					prompt =
					"Generate comprehensive unit tests for the following code. Include tests for edge cases and potential error conditions:\n$text",
					model = "claude-3-opus-20240229",
				},
				-- Custom prompt for implementing a feature
				Implement = {
					prompt =
					"Implement the following feature based on the description. Generate well-structured, efficient code with appropriate error handling and comments:\n$text",
					model = "claude-3-opus-20240229",
				},
				-- Custom prompt for code review
				Review = {
					prompt =
					"Review the following code and suggest improvements for readability, maintainability, performance, and security:\n$text",
					model = "claude-3-opus-20240229",
				},
			},
		},
	},
}
