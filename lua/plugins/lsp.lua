-- Function to determine which picker to use
local function get_picker()
  if vim.g.default_picker == "snacks" and package.loaded["snacks.picker"] then
    return require("snacks.picker")
  elseif package.loaded["telescope.builtin"] then
    return require("telescope.builtin")
  else
    -- Fallback to builtin functionality if neither is available
    return nil
  end
end

-- Set up LSP keymaps when an LSP attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Skip attaching keymaps for certain clients
    if client.name == "copilot" then
      return
    end

    -- Create buffer-local keymaps
    local opts = { buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    
    -- Get the appropriate picker
    local picker = get_picker()
    
    -- Set LSP-related keymaps based on available picker
    if picker then
      vim.keymap.set("n", "gr", function() picker.lsp_references() end, opts)
      vim.keymap.set("n", "<leader>ds", function() picker.lsp_document_symbols() end, opts)
      vim.keymap.set("n", "<leader>ws", function() picker.lsp_dynamic_workspace_symbols() end, opts)
    else
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    end
    
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, opts)
    vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>cq", vim.diagnostic.setqflist, opts)
    
    -- Apply stack-specific settings
    local filetype = vim.bo[bufnr].filetype
    
    -- For GOTH stack
    if filetype == "go" or filetype == "templ" then
      -- Set appropriate options for Go
      if filetype == "go" then
        if package.loaded["go"] then
          -- Special Go actions using ray-x/go.nvim if available
          vim.keymap.set("n", "<leader>sgi", "<cmd>GoImports<cr>", { buffer = true, desc = "Go Imports" })
          vim.keymap.set("n", "<leader>sgc", "<cmd>GoCoverage<cr>", { buffer = true, desc = "Go Coverage" })
          vim.keymap.set("n", "<leader>sgt", "<cmd>GoTest<cr>", { buffer = true, desc = "Go Test" })
          vim.keymap.set("n", "<leader>sgm", "<cmd>GoModTidy<cr>", { buffer = true, desc = "Go Mod Tidy" })
        else
          -- Fallback to gopls commands
          vim.keymap.set("n", "<leader>sgi", function()
            vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
          end, { buffer = true, desc = "Go Imports" })
        end
      end
      
      -- For Templ files
      if filetype == "templ" then
        -- Add Templ-specific commands
        vim.api.nvim_buf_create_user_command(bufnr, "TemplFmt", function()
          -- Check if conform.nvim is available
          if package.loaded["conform"] then
            require("conform").format({ bufnr = bufnr, formatters = { "templ" } })
          else
            vim.cmd("!templ fmt " .. vim.fn.expand("%"))
            vim.cmd("e!") -- Reload the file
          end
        end, { desc = "Format Templ file" })
        
        vim.keymap.set("n", "<leader>stf", "<cmd>TemplFmt<cr>", { buffer = true, desc = "Templ Format" })
      end
    end
    
    -- For Next.js stack
    if filetype == "javascript" or filetype == "typescript" or filetype == "javascriptreact" or filetype == "typescriptreact" then
      -- Add Next.js specific commands
      if client.name == "tsserver" or client.name == "typescript-tools" then
        if package.loaded["typescript-tools"] then
          vim.keymap.set("n", "<leader>sno", function() require("typescript-tools.api").organize_imports() end, { buffer = true, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>snr", function() require("typescript-tools.api").rename_file() end, { buffer = true, desc = "Rename File" })
          vim.keymap.set("n", "<leader>sni", function() require("typescript-tools.api").add_missing_imports() end, { buffer = true, desc = "Add Missing Imports" })
          vim.keymap.set("n", "<leader>snu", function() require("typescript-tools.api").remove_unused() end, { buffer = true, desc = "Remove Unused" })
          vim.keymap.set("n", "<leader>snf", function() require("typescript-tools.api").fix_all() end, { buffer = true, desc = "Fix All" })
        else
          -- Fallback to standard tsserver commands
          vim.keymap.set("n", "<leader>sno", function()
            vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
          end, { buffer = true, desc = "Organize Imports" })
        end
      end
    end

    -- Add formatting capability if supported
    if client.supports_method("textDocument/formatting") then
      -- Create a command to manually format
      vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end, { desc = "Format buffer with LSP" })
    end
  end,
})
