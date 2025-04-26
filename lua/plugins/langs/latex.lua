-- lua/plugins/langs/latex.lua
return {
	-- LaTeX support will be configured here
	-- This is a minimal placeholder to avoid loading errors
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Add texlab to ensure_installed
			if not opts.servers then
				opts.servers = {}
			end
			opts.servers.texlab = {}
		end,
	},
}
