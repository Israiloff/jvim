-- Process-wide cache for the Java (jdtls) setup.
--
-- `ftplugin/java.lua` is re-executed for every Java buffer, so anything that is
-- expensive (globbing Mason jars, resolving the launcher) or must happen exactly
-- once (DAP configuration, which-key registration) has to live outside of it.
--
-- This used to be stored in `vim.g.jdtls_cache`, which silently never worked:
-- reading `vim.g.<name>` returns a *copy* of the variable, so mutating that copy
-- was never visible to the next buffer. A plain module works because `require`
-- caches the returned table for the lifetime of the Neovim process.
local M = {
	-- Resolved java-debug-adapter / java-test bundle jars.
	bundles = nil,
	-- Resolved jdtls paths: { jdtls_path, launcher_jar, config_path }.
	paths = nil,
	-- Whether jdtls.setup_dap() and friends have already run.
	dap_initialized = false,
	-- Whether the Java which-key mappings have already been registered.
	keymaps_initialized = false,
}

return M
