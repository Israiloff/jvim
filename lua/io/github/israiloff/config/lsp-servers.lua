-- Declarative configuration for the language servers we do not let
-- mason-lspconfig enable on its own.
--
-- This used to live in `ftplugin/markdown.lua` / `ftplugin/xml.lua`, which was
-- racy: mason-lspconfig v2 enables servers through `vim.lsp.enable()`, whose
-- FileType hook can fire before the ftplugin has had a chance to register the
-- config. Registering here, at startup, means the config is always in place
-- before the first matching buffer is opened.
--
-- `capabilities` and `on_attach` are inherited from the `vim.lsp.config("*")`
-- defaults set in `config/mason-lspconfig.lua`.
local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
	print("Error: 'io.github.israiloff.config.logger' not found. Language servers will not be configured.")
	return
end

local logger_name = "io.github.israiloff.config.lsp-servers"

local utils_status, utils = pcall(require, "io.github.israiloff.config.utils")

if not utils_status then
	log.error(logger_name, "'io.github.israiloff.config.utils' not found. Language servers will not be configured.")
	return
end

-- ---------------------------------------------------------------------------
-- marksman (markdown)
--
-- Installed and enabled by mason-lspconfig; we only refine the defaults.
-- ---------------------------------------------------------------------------
vim.lsp.config("marksman", {
	filetypes = { "markdown", "markdown.mdx" },
	root_markers = { ".marksman.toml", ".git" },
})

-- ---------------------------------------------------------------------------
-- lemminx (XML)
--
-- Served from the `Israiloff/lemminx-compiled` uber-jar rather than the Mason
-- package, so it is excluded from mason-lspconfig's automatic_enable and started
-- here instead.
-- ---------------------------------------------------------------------------
local lemminx_jar = vim.fn.glob(vim.fn.stdpath("data") .. "/lazy/lemminx-compiled/org.eclipse.lemminx-uber.jar")

if utils.isempty(lemminx_jar) then
	log.error(logger_name, "lemminx uber-jar not found; XML language server will not be started.")
	return
end

local java_bin = utils.get_java_path()

if not java_bin then
	log.error(logger_name, "Java not found; XML language server will not be started.")
	return
end

log.debug(logger_name, "lemminx jar resolved: " .. lemminx_jar)

vim.lsp.config("lemminx", {
	cmd = { java_bin, "-jar", lemminx_jar },
	filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
	root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".git" },
})

vim.lsp.enable("lemminx")

log.debug(logger_name, "Language servers configured")
