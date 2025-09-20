local M = {}

function M.setup()
  local links = {
    ["@keyword.function"] = "Keyword",
    ["@keyword.conditional"] = "Conditional",
    ["@keyword.repeat"] = "Repeat",
    ["@keyword.return"] = "Keyword",
    ["@punctuation.bracket"] = "Normal",
    ["@punctuation.delimiter"] = "Normal",
  }

  local function apply_links()
    for from, to in pairs(links) do
      vim.api.nvim_set_hl(0, from, { link = to })
    end
  end

  apply_links()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_links })
end

return M
