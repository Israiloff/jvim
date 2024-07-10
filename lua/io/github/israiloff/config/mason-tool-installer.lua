require("mason-tool-installer").setup({
	ensure_installed = {
		"java-debug-adapter",
		"java-test",
	},
	auto_update = true,
	run_on_start = true,
})
