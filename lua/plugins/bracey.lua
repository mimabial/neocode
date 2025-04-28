return {
  "turbio/bracey.vim",
  build = "npm install --prefix server",
  cmd = { "Bracey", "BraceyStop", "BraceyReload" },
  -- Fix for local changes issue
  init = function()
    -- Create the directory if it doesn't exist
    local server_dir = vim.fn.stdpath("data") .. "/lazy/bracey.vim/server"
    if vim.fn.isdirectory(server_dir) == 1 then
      -- Check if package-lock.json exists and has local changes
      local lock_file = server_dir .. "/package-lock.json"
      if vim.fn.filereadable(lock_file) == 1 then
        -- Add to gitignore if needed
        local gitignore = server_dir .. "/.gitignore"
        if vim.fn.filereadable(gitignore) == 0 then
          local f = io.open(gitignore, "w")
          if f then
            f:write("package-lock.json\n")
            f:close()
          end
        else
          -- Append to existing gitignore if package-lock.json is not there
          local has_lockfile = false
          for line in io.lines(gitignore) do
            if line == "package-lock.json" then
              has_lockfile = true
              break
            end
          end
          
          if not has_lockfile then
            local f = io.open(gitignore, "a")
            if f then
              f:write("\npackage-lock.json\n")
              f:close()
            end
          end
        end
      end
    end
  end,
}
