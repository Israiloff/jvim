local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
	print("Error: 'io.github.israiloff.config.logger' not found. LSP will not be configured.")
	return
end

local logger_name = "io.github.israiloff.config.mason-lspconfig"

local lsp_status, mason_lspconfig = pcall(require, "mason-lspconfig")

if not lsp_status then
	log.error(logger_name, "'mason-lspconfig' not found. LSP auto installation will not be configured.")
	return
end

mason_lspconfig.setup({
	ensure_installed = {
		"lua_ls",
		"jdtls",
	},
	automatic_installation = {
		enabled = true,
		exclude = {
			"lemminx",
		},
	},
})
