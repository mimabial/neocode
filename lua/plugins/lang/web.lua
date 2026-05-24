-- JSON, YAML, ESLint, plus optional node-based servers (tailwindcss, etc).
return {
  { "b0o/SchemaStore.nvim", lazy = true },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "b0o/SchemaStore.nvim" },
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "jsonls", "yamlls", "eslint" })

      opts.servers.jsonls = {
        filetypes = { "json", "jsonc" },
        settings = { json = { schemas = require("schemastore").json.schemas() } },
      }

      opts.servers.yamlls = {
        settings = {
          yaml = {
            schemas = require("schemastore").yaml.schemas(),
            schemaStore = { enable = false, url = "" },
          },
        },
      }

	      opts.servers.eslint = { settings = { packageManager = "npm" } }

	      if vim.fn.executable("node") == 1 then
	        vim.list_extend(opts.ensure_installed, {
	          "tailwindcss", "emmet_ls", "vuels", "svelte", "astro",
	        })

	        local tailwind_root_files = {
	          -- Generic
	          "tailwind.config.js",
	          "tailwind.config.cjs",
	          "tailwind.config.mjs",
	          "tailwind.config.ts",
	          "postcss.config.js",
	          "postcss.config.cjs",
	          "postcss.config.mjs",
	          "postcss.config.ts",
	          -- Django
	          "theme/static_src/tailwind.config.js",
	          "theme/static_src/tailwind.config.cjs",
	          "theme/static_src/tailwind.config.mjs",
	          "theme/static_src/tailwind.config.ts",
	          "theme/static_src/postcss.config.js",
	        }

	        local function file_contains(path, pattern)
	          local ok, lines = pcall(vim.fn.readfile, path)
	          if not ok then
	            return false
	          end

	          for _, line in ipairs(lines) do
	            if line:find(pattern, 1, true) then
	              return true
	            end
	          end

	          return false
	        end

	        opts.servers.tailwindcss = {
	          -- nvim-lspconfig falls back to .git for Tailwind v4 projects. That
	          -- is too broad for this setup: config repos and theme files can make
	          -- the server index huge trees and OOM. Require a real Tailwind marker.
	          root_dir = function(bufnr, on_dir)
	            local fname = vim.api.nvim_buf_get_name(bufnr)
	            if fname == "" then
	              return
	            end

	            local marker = vim.fs.find(tailwind_root_files, {
	              path = fname,
	              upward = true,
	              type = "file",
	              limit = 1,
	            })[1]
	            if marker then
	              on_dir(vim.fs.dirname(marker))
	              return
	            end

	            for _, package_json in ipairs(vim.fs.find({ "package.json", "package.json5" }, {
	              path = fname,
	              upward = true,
	              type = "file",
	            })) do
	              if file_contains(package_json, '"tailwindcss"') or file_contains(package_json, '"@tailwindcss/') then
	                on_dir(vim.fs.dirname(package_json))
	                return
	              end
	            end

	            for _, lockfile in ipairs(vim.fs.find({ "mix.lock", "Gemfile.lock" }, {
	              path = fname,
	              upward = true,
	              type = "file",
	            })) do
	              if file_contains(lockfile, "tailwind") then
	                on_dir(vim.fs.dirname(lockfile))
	                return
	              end
	            end
	          end,
	        }
	      end

	      return opts
	    end,
  },
}
