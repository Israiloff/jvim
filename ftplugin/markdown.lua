local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
    print("Error: 'io.github.israiloff.config.logger' not found. LSP will not be configured.")
    return
end

local logger_name = "ftplugin.markdown"

local lspconfig_status, lspconfig = pcall(require, "lspconfig")

if not lspconfig_status then
    log.error(logger_name, "'lspconfig' not found. Marksman LSP will not be configured.")
    return
end

local lsp_utils_status, lsp_utils = pcall(require, "io.github.israiloff.config.lsp-utils")

if not lsp_utils_status then
    log.error(logger_name, "'lsp-utils' not found. Marksman LSP will not be configured.")
    return
end

local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

if not cmp_nvim_lsp_status then
    log.error(logger_name, "'cmp_nvim_lsp' not found. Marksman LSP will not be configured.")
    return
end

lspconfig.marksman.setup({
    root_dir = lsp_utils.get_root_dir(),
    on_attach = lsp_utils.global_on_attach,
    capabilities = cmp_nvim_lsp.default_capabilities(),
    filetypes = {
        "markdown",
        "markdown.mdx",
    },
})
