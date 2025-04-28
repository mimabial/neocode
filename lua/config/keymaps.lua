-- This file only contains keymaps that aren't registered by which-key in plugin files
-- Most keymaps are now managed in lua/plugins/which-key.lua

-- Set space as leader key (should remain here since it's needed before lazy.nvim loads)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Basic movement improvements
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Add command to reload config
vim.keymap.set("n", "<leader>cr", "<cmd>ReloadConfig<cr>", { desc = "Reload Config" })

-- Text editing convenience
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines (maintain cursor position)" })

-- Better navigation with center
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half a page and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half a page and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Preserve visual selection when indenting
vim.keymap.set("v", "<", "<gv", { desc = "Unindent line" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent line" })

-- Better paste in visual mode (doesn't replace yank register)
vim.keymap.set("v", "p", '"_dP', { desc = "Better paste" })

-- Quick ESC and save
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Diagnostic keymaps (these are low-level and should remain)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
