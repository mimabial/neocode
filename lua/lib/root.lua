-- Project-root resolver.
--
-- Walks up from the given path looking for a .git directory first (most
-- reliable), then a list of language root markers, falling back to the path
-- itself. Used by formatter scope resolution, mason-tool-installer, and any
-- caller that needs a stable project root.

local M = {}

M.markers = {
  "go.mod",
  "go.work",
  "package.json",
  "pyproject.toml",
  "requirements.txt",
  "Cargo.toml",
  "pom.xml",
  "build.gradle",
  "build.gradle.kts",
  "composer.json",
  "Gemfile",
  "CMakeLists.txt",
  "compile_commands.json",
  ".terraform.lock.hcl",
}

function M.get(path)
  path = path or vim.fn.getcwd()
  local git_dir = vim.fs.find({ ".git" }, { path = path, upward = true })[1]
  if git_dir then
    return vim.fs.dirname(git_dir)
  end
  local marker = vim.fs.find(M.markers, { path = path, upward = true })[1]
  if marker then
    return vim.fs.dirname(marker)
  end
  return path
end

return M
