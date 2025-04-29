return {
  "turbio/bracey.vim",
  build = "npm install --prefix server",
  cmd = { "Bracey", "BraceyStop", "BraceyReload" },
  -- Fix for local changes issue
  init = function()
    local server_dir = vim.fn.stdpath("data") .. "/lazy/bracey.vim/server"
    if vim.fn.isdirectory(server_dir) == 1 then
      local lock_file = server_dir .. "/package-lock.json"
      if vim.fn.filereadable(lock_file) == 1 then
        local gitignore = server_dir .. "/.gitignore"
        if vim.fn.filereadable(gitignore) == 0 then
          vim.fn.writefile({ "package-lock.json" }, gitignore)
        else
          local lines = vim.fn.readfile(gitignore)
          local found = false
          for _, line in ipairs(lines) do
            if line == "package-lock.json" then
              found = true
              break
            end
          end
          if not found then
            table.insert(lines, "package-lock.json")
            vim.fn.writefile(lines, gitignore)
          end
        end
      end
    end
  end

}
