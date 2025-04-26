-- lua/plugins/langs/elixir.lua
return {
	-- Elixir development support will be configured here
	-- This is a minimal placeholder to avoid loading errors
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Add elixirls to ensure_installed
			if not opts.servers then
				opts.servers = {}
			end
			opts.servers.elixirls = {}
		end,
	},
}
