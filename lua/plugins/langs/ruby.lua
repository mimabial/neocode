-- lua/plugins/langs/ruby.lua
return {
	-- Ruby development support will be configured here
	-- This is a minimal placeholder to avoid loading errors
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Add ruby_ls to ensure_installed
			if not opts.servers then
				opts.servers = {}
			end
			opts.servers.ruby_ls = {}
		end,
	},
}
