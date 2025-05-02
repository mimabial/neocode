-- lua/config/keymaps.lua
-- Centralized keymap definitions: buffer management, Snacks picker, explorer, and stack commands

local M = {}

function M.setup()
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- keep selection when indenting in visual mode
  map("v", ">", ">gv", vim.tbl_extend("force", opts, { desc = "Indent and keep selection" }))
  map("v", "<", "<gv", vim.tbl_extend("force", opts, { desc = "Outdent and keep selection" }))

  -- 1) Buffer management
  local buffer_maps = {
    { "n", "<leader>bb", "<cmd>e #<cr>", "Switch to Other Buffer" },
    { "n", "<leader>bd", "<cmd>bdelete<cr>", "Delete Buffer" },
    { "n", "<leader>bf", "<cmd>bfirst<cr>", "First Buffer" },
    { "n", "<leader>bl", "<cmd>blast<cr>", "Last Buffer" },
    { "n", "<leader>bn", "<cmd>bnext<cr>", "Next Buffer" },
    { "n", "<leader>bp", "<cmd>bprevious<cr>", "Previous Buffer" },
    { "n", "<leader>be", "<cmd>Oil<cr>", "Buffer Explorer (Oil)" },
    { "n", "-", "<cmd>Oil<cr>", "Buffer Explorer Parent Dir. (Oil)" },
    { "n", "_", "<cmd>Oil .<cr>", "Buffer Explorer Root Dir. (Oil)" },
    -- buffer navigation with Shift
    { "n", "<S-h>", "<cmd>bprevious<cr>", "Previous Buffer" },
    { "n", "<S-l>", "<cmd>bnext<cr>", "Next Buffer" },
  }
  for _, m in ipairs(buffer_maps) do
    map(m[1], m[2], m[3], vim.tbl_extend("force", opts, { desc = m[4] }))
  end

  -- 2) Snacks picker mappings
  local ok_picker, picker = pcall(require, "snacks.picker")
  if ok_picker then
    local snack_maps = {
      {
        "n",
        "<leader>ff",
        function()
          picker.files()
        end,
        "Find Files",
      },
      {
        "n",
        "<leader>fg",
        function()
          picker.grep()
        end,
        "Find Text (Grep)",
      },
      {
        "n",
        "<leader>fb",
        function()
          picker.buffers()
        end,
        "Find Buffers",
      },
      {
        "n",
        "<leader>fh",
        function()
          picker.help()
        end,
        "Find Help",
      },
      {
        "n",
        "<leader>fr",
        function()
          picker.recent()
        end,
        "Recent Files",
      },
      {
        "n",
        "<leader>fR",
        function()
          picker.smart()
        end,
        "Frecent Files",
      },
      {
        "n",
        "<leader>fp",
        function()
          picker.projects()
        end,
        "Find Projects",
      },
      {
        "n",
        "<leader>fc",
        function()
          picker.commands()
        end,
        "Commands",
      },
      {
        "n",
        "<leader>fk",
        function()
          picker.keymaps()
        end,
        "Keymaps",
      },
      {
        "n",
        "<leader>f/",
        function()
          picker.lines()
        end,
        "Buffer Fuzzy Find",
      },
      {
        "n",
        "<leader>f.",
        function()
          picker.resume()
        end,
        "Resume Search",
      },
      -- git integration
      {
        "n",
        "<leader>gc",
        function()
          picker.git_log()
        end,
        "Git Commits",
      },
      {
        "n",
        "<leader>gb",
        function()
          picker.git_branches()
        end,
        "Git Branches",
      },
      -- lsp integration
      {
        "n",
        "<leader>fd",
        function()
          picker.diagnostics({ bufnr = 0 })
        end,
        "Doc Diagnostics",
      },
      {
        "n",
        "<leader>fD",
        function()
          picker.diagnostics()
        end,
        "Workspace Diagnostics",
      },
      {
        "n",
        "<leader>fs",
        function()
          picker.lsp_symbols()
        end,
        "Doc Symbols",
      },
      {
        "n",
        "<leader>fS",
        function()
          picker.lsp_workspace_symbols()
        end,
        "Workspace Symbols",
      },
    }
    for _, m in ipairs(snack_maps) do
      map(m[1], m[2], m[3], vim.tbl_extend("force", opts, { desc = m[4] }))
    end
  end

  -- 3) Snacks explorer (wrapped as function to satisfy keymap API)
  local ok_snacks, snacks = pcall(require, "snacks")
  if ok_snacks then
    map("n", "<leader>e", function()
      snacks.explorer()
    end, vim.tbl_extend("force", opts, { desc = "Snacks Explorer" }))
  end

  -- 4) Stack switching + dashboard
  map("n", "<leader>usg", function()
    vim.cmd("StackFocus goth")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, vim.tbl_extend("force", opts, { desc = "Focus GOTH Stack + Dashboard" }))
  map("n", "<leader>usn", function()
    vim.cmd("StackFocus nextjs")
    if package.loaded["snacks.dashboard"] then
      require("snacks.dashboard").open()
    end
  end, vim.tbl_extend("force", opts, { desc = "Focus Next.js Stack + Dashboard" }))

  -- 5) Oil filetype navigation
  local ok_oil, oil = pcall(require, "oil")
  if ok_oil then
    -- Oil file explorer navigation (FileType = oil)
    local group = vim.api.nvim_create_augroup("OilExplorerKeymaps", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "oil",
      desc = "Oil-specific navigation keymaps",
      callback = function()
        local buf_opts = { buffer = 0, noremap = true, silent = true }
        vim.keymap.set("n", "R", function()
          oil.refresh()
        end, buf_opts)
        vim.keymap.set("n", "~", function()
          oil.open(vim.loop.cwd())
        end, buf_opts)
      end,
    })
  end
end

return M
