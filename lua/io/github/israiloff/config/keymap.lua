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

-- LSP mappings
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Goto references", expr = true, silent = true })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "<M-p>", vim.lsp.buf.signature_help, { desc = "Signature help" })
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
vim.keymap.set("n", "<M-i>", vim.lsp.buf.hover, { desc = "Show hover" })
