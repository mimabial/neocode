return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = true },
    defaults = {
      mode = { "n", "v" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    -- Register key groups
    wk.add({
      g = { name = "+goto" },
      gs = { name = "+surround" },
      ["]"] = { name = "+next" },
      ["["] = { name = "+prev" },
      ["<leader>b"] = { name = "+buffer" },
      ["<leader>c"] = { name = "+code" },
      ["<leader>f"] = { name = "+file/find" },
      ["<leader>g"] = { name = "+git" },
      ["<leader>h"] = { name = "+hunks" },
      ["<leader>q"] = { name = "+quit/session" },
      ["<leader>s"] = { name = "+search" },
      ["<leader>u"] = { name = "+ui" },
      ["<leader>w"] = { name = "+windows" },
      ["<leader>x"] = { name = "+diagnostics/quickfix" },
    })

    -- Basic keymaps
    vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

    -- Better up/down
    vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
    vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

    -- Better window navigation
    vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
    vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
    vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
    vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

    -- Resize window using <ctrl> arrow keys
    vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
    vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
    vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
    vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
    -- Move Lines
    vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
    vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
    vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
    vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
    vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
    vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

    -- Buffers
    vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
    vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
    vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
    vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
    vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
    vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })

    -- Clear search with <esc>
    vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

    -- Clear search, diff update and redraw
    vim.keymap.set(
      "n",
      "<leader>ur",
      "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
      { desc = "Redraw / clear hlsearch / diff update" }
    )

    -- Save file
    vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

    -- Better indenting
    vim.keymap.set("v", "<", "<gv")
    vim.keymap.set("v", ">", ">gv")

    -- Paste over currently selected text without yanking it
    vim.keymap.set("v", "p", '"_dP', { desc = "Better paste" })

    -- Cancel search highlighting with ESC
    vim.keymap.set("n", "<ESC>", "<cmd>nohlsearch<Bar>echo<CR>")

    -- Move to window using the <ctrl> hjkl keys
    vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
    vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
    vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
    vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

    -- Diagnostic keymaps
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
    vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

    -- Lazygit
    vim.keymap.set("n", "<leader>gg", function()
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = {
          border = "curved",
        },
      })
      lazygit:toggle()
    end, { desc = "Lazygit" })
  end,
}
