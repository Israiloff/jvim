require("lvim.lsp.manager").setup("marksman", {
	root_dir = require("lspconfig").util.root_pattern(".git", ".marksman.toml", "package.json", "pom.xml", ".settings"),
	filetypes = {
		"markdown",
		"markdown.mdx",
	},
})
