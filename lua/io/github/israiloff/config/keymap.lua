-- common
vim.g.mapleader = " "

-- window
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- buffer
vim.keymap.set("n", "<M-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<M-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
