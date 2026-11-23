-- Bigfile detection.
--
-- Detect oversized or minified-line files early and short-circuit expensive
-- plugin behavior to keep the editor responsive. The mechanism:
--
--   1. A BufReadPost autocmd, registered before filetype detection exists, sets
--      the synthetic filetype "bigfile" when the file is over the size threshold
--      or contains very long lines; detection's :setfiletype then keeps it. Most
--      plugins gate themselves on filetype via denylists/excludes and opt out.
--
--   2. A FileType=bigfile autocmd sets vim.b.bigfile = true for plugins that
--      don't gate on filetype, and disables buffer-local features that aren't
--      already handled by the filetype switch (swapfile, undo, spell, list,
--      foldmethod, syntax, treesitter).
--
-- Public API:
--   require("lib.bigfile").setup({ size = 1572864, line_length = 1000 })
--   require("lib.bigfile").is_big(bufnr)  -- predicate for plugin gates

local M = {}
local LINES_PER_SCAN_CHUNK = 1024

M.config = {
  -- File-size threshold in bytes.
  size = 1.5 * 1024 * 1024,
  -- Single-line length threshold (catches minified bundles that are not huge
  -- by size but still trip treesitter's parser).
  line_length = 1000,
  -- Notify the user when a file is treated as big.
  notify = true,
}

function M.is_big(buf)
  return vim.b[buf or 0].bigfile == true
end

local function has_long_line(buf)
  for first = 0, vim.api.nvim_buf_line_count(buf) - 1, LINES_PER_SCAN_CHUNK do
    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, first, first + LINES_PER_SCAN_CHUNK, false)) do
      if #line > M.config.line_length then
        return true
      end
    end
  end
  return false
end

local function detect(buf)
  local path = vim.api.nvim_buf_get_name(buf)
  if path == "" or path:find("://") then
    return false
  end
  local stat = vim.uv.fs_stat(path)
  return stat and stat.size > M.config.size or has_long_line(buf)
end

local function disable(buf)
  vim.b[buf].bigfile = true
  vim.bo[buf].swapfile = false
  vim.bo[buf].undolevels = -1
  if vim.api.nvim_get_current_buf() == buf then
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.spell = false
    vim.opt_local.list = false
  end

  -- Defer heavy work so the buffer finishes loading first; otherwise some
  -- plugins re-attach between BufReadPost and FileType.
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    pcall(vim.treesitter.stop, buf)
    vim.bo[buf].syntax = ""
    if M.config.notify then
      local kb = math.floor(vim.fn.getfsize(vim.api.nvim_buf_get_name(buf)) / 1024)
      vim.notify(
        ("Big file (%d KB): LSP, treesitter and decorations disabled."):format(kb),
        vim.log.levels.INFO,
        { title = "bigfile" }
      )
    end
  end)
end

local function restore(buf)
  vim.b[buf].bigfile = nil
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("setlocal swapfile< undolevels< foldmethod< spell< list<")
  end)
end

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})

  local group = vim.api.nvim_create_augroup("BigFile", { clear = true })
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(args)
      if detect(args.buf) then
        vim.bo[args.buf].filetype = "bigfile"
      elseif M.is_big(args.buf) then
        restore(args.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "bigfile",
    callback = function(args)
      disable(args.buf)
    end,
  })
end

return M
