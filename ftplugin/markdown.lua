local lspconfig = require("lspconfig")

lspconfig.marksman.setup({
	root_dir = lspconfig.util.root_pattern(".git", ".marksman.toml", "package.json", "pom.xml", ".settings"),
	filetypes = {
		"markdown",
		"markdown.mdx",
	},
})
