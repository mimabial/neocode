-- lua/plugins/langs/sql.lua
return {
	-- SQL development support will be configured here
	-- This is a minimal placeholder to avoid loading errors
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Add sqlls to ensure_installed
			if not opts.servers then
				opts.servers = {}
			end
			opts.servers.sqlls = {}
		end,
	},
}
