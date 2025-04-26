-- lua/plugins/langs/kotlin.lua
return {
	-- Kotlin development support will be configured here
	-- This is a minimal placeholder to avoid loading errors
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Add kotlin_language_server to ensure_installed
			if not opts.servers then
				opts.servers = {}
			end
			opts.servers.kotlin_language_server = {}
		end,
	},
}
