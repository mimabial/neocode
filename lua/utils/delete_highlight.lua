-- lua/utils/delete_highlight.lua
-- Highlight text before deletion for better visual feedback

local M = {}

-- Namespace for highlight
M.ns_id = vim.api.nvim_create_namespace("DeleteHighlight")

-- Duration to show highlight before deleting (milliseconds)
M.highlight_duration = 200 -- Adjust this value to control how long the highlight shows

-- Apply delete highlight
function M.highlight_region(start_pos, end_pos)
  -- Clear any existing highlights
  vim.api.nvim_buf_clear_namespace(0, M.ns_id, 0, -1)

  -- Apply highlight
  vim.highlight.range(
    0, -- Current buffer
    M.ns_id, -- Namespace
    "DeleteHighlight", -- Highlight group
    start_pos, -- Start position
    end_pos, -- End position
    { inclusive = true }
  )

  -- Force redraw to show highlight immediately
  vim.cmd("redraw")
end

-- Highlight then delete for operators
function M.delete_with_highlight(motion)
  -- Set opfunc for the next command
  vim.o.operatorfunc = "v:lua.require'utils.delete_highlight'.operator_callback"

  -- Execute the operator-pending command
  return "g@" .. (motion or "")
end

-- Callback for operator
function M.operator_callback(type)
  local start_pos, end_pos

  -- Get region based on motion type
  if type == "char" then
    -- Character-wise motion
    start_pos = vim.api.nvim_buf_get_mark(0, "[")
    end_pos = vim.api.nvim_buf_get_mark(0, "]")
  elseif type == "line" then
    -- Line-wise motion
    start_pos = { vim.api.nvim_buf_get_mark(0, "[")[1], 0 }
    end_pos = { vim.api.nvim_buf_get_mark(0, "]")[1], 999999 }
  elseif type == "block" then
    -- Block-wise motion (simplified)
    start_pos = vim.api.nvim_buf_get_mark(0, "[")
    end_pos = vim.api.nvim_buf_get_mark(0, "]")
  end

  -- Highlight the region
  M.highlight_region(start_pos, end_pos)

  -- Wait for the highlight duration
  vim.defer_fn(function()
    -- Perform the deletion
    vim.cmd("normal! d" .. type)

    -- Clear highlight
    vim.api.nvim_buf_clear_namespace(0, M.ns_id, 0, -1)
  end, M.highlight_duration)
end

-- Visual mode deletion with highlight
function M.visual_delete_with_highlight()
  -- Temporarily exit visual mode to capture the selection
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)

  -- Get the visual selection marks
  local start_pos = vim.api.nvim_buf_get_mark(0, "<")
  local end_pos = vim.api.nvim_buf_get_mark(0, ">")

  -- Highlight the region
  M.highlight_region(start_pos, end_pos)

  -- Wait for the highlight duration, then delete
  vim.defer_fn(function()
    -- Restore visual selection then delete
    vim.cmd('normal! gv"_d')

    -- Clear highlight
    vim.api.nvim_buf_clear_namespace(0, M.ns_id, 0, -1)
  end, M.highlight_duration)

  -- Return empty string for expr mapping
  return ""
end

-- Setup keymaps and highlights
function M.setup()
  -- Create highlight group with a bright red background
  vim.api.nvim_set_hl(0, "DeleteHighlight", { bg = "#FF3333", fg = "#FFFFFF" })

  -- Define keymaps for normal mode
  vim.keymap.set("n", "d", function()
    return M.delete_with_highlight()
  end, { expr = true, desc = "Delete with highlight" })
  vim.keymap.set("n", "dd", function()
    return M.delete_with_highlight("_")
  end, { expr = true, desc = "Delete line with highlight" })
  vim.keymap.set("n", "D", function()
    return M.delete_with_highlight("$")
  end, { expr = true, desc = "Delete to end with highlight" })

  -- Define keymap for visual mode
  vim.keymap.set("x", "d", function()
    return M.visual_delete_with_highlight()
  end, { expr = true, desc = "Delete selection with highlight" })

  -- Ensure the highlight is removed when leaving buffers
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    callback = function()
      vim.api.nvim_buf_clear_namespace(0, M.ns_id, 0, -1)
    end,
  })

  -- Update highlight color when colorscheme changes
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      local colors = _G.get_ui_colors()
      vim.api.nvim_set_hl(0, "DeleteHighlight", { bg = colors.red, fg = "#FFFFFF", blend = 30 })
    end,
  })
end

return M
