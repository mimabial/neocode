-- lua/plugins/langs/markdown.lua
return {
	-- Markdown support will be configured here
	-- This is a minimal placeholder to avoid loading errors
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Add marksman to ensure_installed
			if not opts.servers then
				opts.servers = {}
			end
			opts.servers.marksman = {}
		end,
	},
}
