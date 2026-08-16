-- `auto_update`/`run_on_start` used to hit the network on every single startup and
-- could kick off installs while you were trying to open a file. Tools are now
-- installed on demand with `:MasonToolsInstall` (or `:Mason`), and refreshed
-- deliberately with `:MasonToolsUpdate`.
local spring = require("io.github.israiloff.config.java.spring")

local ensure_installed = {
	"java-debug-adapter",
	"java-test",
	"stylua",
	"prettier",
}

-- Only listed when Spring Boot support is on: it is a ~100MB download that is
-- useless to anyone not writing Spring.
if spring.is_enabled() then
	table.insert(ensure_installed, spring.mason_package)
end

require("mason-tool-installer").setup({
	ensure_installed = ensure_installed,
	auto_update = false,
	run_on_start = false,
})
