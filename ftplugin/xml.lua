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

local lsp_utils_status, lsp_utils = pcall(require, "io.github.israiloff.config.lsp-utils")

if not lsp_utils_status then
    log.error(logger_name, "'io.github.israiloff.config.lsp-utils' not found. lemminx will not be configured.")
    return
end

local cmp_status, cmp = pcall(require, "cmp_nvim_lsp")

if not cmp_status then
    log.error(logger_name, "'cmp_nvim_lsp' not found. lemminx will not be configured.")
    return
end

lsp_config.lemminx.setup({
    cmd = {
        "java",
        "-jar",
        lemminx_path,
    },
    capabilities = cmp.default_capabilities(),
    filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
    on_attach = lsp_utils.global_on_attach,
})

log.debug(logger_name, "LSP for XML configured. Starting LSP server...")
vim.cmd("LspStart lemminx")
