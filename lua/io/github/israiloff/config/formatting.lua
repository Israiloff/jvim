vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.api.nvim_create_user_command("CmFormat", function()
	vim.lsp.buf.format({ async = true })
end, {})
