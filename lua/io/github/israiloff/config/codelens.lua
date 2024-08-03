vim.api.nvim_create_augroup("lsp_codelens", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
	group = "lsp_codelens",
	pattern = "*",
	callback = function()
		local clients = vim.lsp.get_active_clients()
		for _, client in pairs(clients) do
			if client.server_capabilities.codeLensProvider then
				vim.lsp.codelens.refresh()
			end
		end
	end,
})

vim.g.codelens_auto = 1
