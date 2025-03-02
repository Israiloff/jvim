-- common
vim.g.mapleader = " "

-- window
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- buffer
vim.keymap.set("n", "<M-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "¬", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })                              -- Option + l
vim.keymap.set("n", "<M-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "˙", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })                          -- Option + h

-- LSP mappings
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Goto references", expr = true, silent = true })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "<M-p>", vim.lsp.buf.signature_help, { desc = "Signature help" })
vim.keymap.set("n", "π", vim.lsp.buf.signature_help, { desc = "Signature help" })                               -- Option + p
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
vim.keymap.set("n", "<M-i>", vim.lsp.buf.hover, { desc = "Show hover" })
vim.keymap.set("n", "ˆ", vim.lsp.buf.hover, { desc = "Show hover" })                                            -- Option + i

vim.keymap.set("n", "<M-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "∆", ":m .+1<CR>==", { desc = "Move line down" })                                           -- Option + j
vim.keymap.set("n", "<M-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "˚", ":m .-2<CR>==", { desc = "Move line up" })                                             -- Option + k

vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "∆", ":m '>+1<CR>gv=gv", { desc = "Move line down" })                                       -- Option + j
vim.keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
vim.keymap.set("v", "˚", ":m '<-2<CR>gv=gv", { desc = "Move line up" })                                         -- Option + k

vim.keymap.set("i", "<M-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
vim.keymap.set("i", "˚", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })                                      -- Option + k
vim.keymap.set("i", "<M-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
vim.keymap.set("i", "∆", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })                                    -- Option + j
