-- lua/plugins/langs/devops.lua
return {
	-- DevOps tools support will be configured here
	-- This is a minimal placeholder to avoid loading errors
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Add dockerls and yamlls to ensure_installed
			if not opts.servers then
				opts.servers = {}
			end
			opts.servers.dockerls = {}
			opts.servers.yamlls = {}
		end,
	},
}
