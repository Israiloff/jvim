local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
	print("Error: 'io.github.israiloff.config.logger' not found. LSP will not be configured.")
	return
end

local logger_name = "io.github.israiloff.config.lspconfig"

local lsp_status, lspconfig = pcall(require, "lspconfig")

if not lsp_status then
	log.error(logger_name, "'lspconfig' not found. LSP will not be configured.")
	return
end

log.debug(logger_name, "Configuring LSP")

lspconfig.lua_ls.setup({
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
		},
	},
})

require("lspconfig.ui.windows").default_options.border = "single"
