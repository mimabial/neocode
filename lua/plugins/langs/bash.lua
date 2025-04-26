-- lua/plugins/langs/bash.lua
return {
	-- Bash/Shell development support will be configured here
	-- This is a minimal placeholder to avoid loading errors
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Add bashls to ensure_installed
			if not opts.servers then
				opts.servers = {}
			end
			opts.servers.bashls = {}
		end,
	},
}
