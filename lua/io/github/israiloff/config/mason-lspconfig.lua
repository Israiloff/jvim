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

local utils_status, utils = pcall(require, "io.github.israiloff.config.lsp-utils")

if not utils_status then
    log.error(logger_name, "'io.github.israiloff.config.lsp-utils' not found. LSP on_attach will not be configured.")
    return
end

local cmp_status, cmp = pcall(require, "cmp_nvim_lsp")

if not cmp_status then
    log.error(logger_name, "'cmp_nvim_lsp' not found. LSP completion capabilities will not be advertised.")
    return
end

-- Servers we start ourselves; mason-lspconfig must not `vim.lsp.enable()` them,
-- otherwise a second client is spawned alongside the hand-rolled one.
--
--   jdtls   -> started by nvim-jdtls in ftplugin/java.lua
--   lemminx -> started from the `lemminx-compiled` jar in config/lsp-servers.lua
--   stylua  -> nvim-lspconfig ships a `stylua --lsp` config and mason-lspconfig
--              maps the stylua *formatter* package onto it; the client dies on
--              startup and formatting already goes through none-ls.
local self_managed_servers = {
    "jdtls",
    "lemminx",
    "stylua",
}

log.info(logger_name, "Setting up Mason LSPConfig")

mason_lspconfig.setup({
    ensure_installed = {
        "lua_ls",
        "jdtls",
        "marksman",
        "jsonls",
        "yamlls",
        "dockerls",
    },
    automatic_enable = {
        exclude = self_managed_servers,
    },
})

-- Defaults shared by every server that Neovim starts through `vim.lsp.enable()`.
--
-- mason-lspconfig v2 dropped `setup_handlers`, so this is the only supported hook
-- point for cross-server defaults. Server-specific configs (`vim.lsp.config("x", ..)`)
-- are deep-merged on top of this one, so per-server overrides still win.
--
-- Note: `root_dir` is deliberately not set here. It used to be resolved once at
-- startup, which pinned every server to whatever directory Neovim happened to
-- start in; nvim-lspconfig's per-server root markers do a better job.
vim.lsp.config("*", {
    capabilities = cmp.default_capabilities(),
    on_attach = utils.global_on_attach,
})

log.info(logger_name, "Mason LSPConfig configured")
