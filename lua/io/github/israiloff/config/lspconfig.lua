local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
		},
	},
})

lspconfig.jdtls.setup({
	jdtls = function()
		require("java").setup({})
	end,
})

require("lspconfig.ui.windows").default_options.border = "single"
