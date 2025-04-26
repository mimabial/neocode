-- lua/plugins/langs/php.lua
return {
	-- PHP development support will be configured here
	-- This is a minimal placeholder to avoid loading errors
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Add phpactor to ensure_installed
			if not opts.servers then
				opts.servers = {}
			end
			opts.servers.phpactor = {}
		end,
	},
}
