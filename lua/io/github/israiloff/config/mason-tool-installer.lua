-- `auto_update`/`run_on_start` used to hit the network on every single startup and
-- could kick off installs while you were trying to open a file. Tools are now
-- installed on demand with `:MasonToolsInstall` (or `:Mason`), and refreshed
-- deliberately with `:MasonToolsUpdate`.
require("mason-tool-installer").setup({
	ensure_installed = {
		"java-debug-adapter",
		"java-test",
		"stylua",
		"prettier",
	},
	auto_update = false,
	run_on_start = false,
})
