local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
	print("Error: 'io.github.israiloff.config.logger' not found. LSP will not be configured.")
	return
end

local logger_name = "ftplugin.xml"

local lsp_status, lsp_config = pcall(require, "lspconfig")

if not lsp_status then
	log.error(logger_name, "'lspconfig' not found. LSP will not be configured.")
	return
end

log.debug(logger_name, "Resolving Lemminx path...")

local lemminx_path =
	vim.fn.glob(vim.env.HOME .. "/.local/share/nvim/lazy/lemminx-compiled/org.eclipse.lemminx-uber.jar")

log.debug(logger_name, "Lemminx path resolved: " .. lemminx_path)

local utils_status, utils = pcall(require, "io.github.israiloff.config.utils")

if not utils_status then
	log.error(logger_name, "'io.github.israiloff.config.utils' not found. lemminx will not be configured.")
	return
end

local java_path = utils.get_java_path()

print("Java path: " .. java_path)

lsp_config.lemminx.setup({
	cmd = {
		java_path,
		"-jar",
		lemminx_path,
	},

	-- Enable LSP-based auto-completion
	capabilities = require("cmp_nvim_lsp").default_capabilities(),

	-- Other possible configurations like filetypes, root_dir, etc.
	filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
})

log.debug(logger_name, "LSP for XML configured. Starting LSP server...")
vim.cmd("LspStart lemminx")
