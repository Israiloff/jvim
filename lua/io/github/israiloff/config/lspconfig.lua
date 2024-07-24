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

-- Set up a custom handler for hover and signature tooltips with borders

-- Define the border style
local border = {
	{ "╭", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "╮", "FloatBorder" },
	{ "│", "FloatBorder" },
	{ "╯", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "╰", "FloatBorder" },
	{ "│", "FloatBorder" },
}

-- Set up a custom handler for hover with a border
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = border,
})

-- Set up a custom handler for signature help with a border
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = border,
})

local icons_status, icons = pcall(require, "io.github.israiloff.config.icons")

if not icons_status then
	log.error(logger_name, "'io.github.israiloff.config.icons' not found. Default icons for diagnostics will be used.")
	return
end

-- Set up a custom handler for diagnostics with custom signs
vim.fn.sign_define("DiagnosticSignError", { text = icons.diagnostics.Error, texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = icons.diagnostics.Warning, texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = icons.diagnostics.Information, texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = icons.diagnostics.Hint, texthl = "DiagnosticSignHint" })
