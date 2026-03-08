local log_status, log = pcall(require, "io.github.israiloff.config.logger")
if not log_status then
    print("Error: 'io.github.israiloff.config.logger' not found. LSP will not be configured.")
    return
end

local logger_name = "io.github.israiloff.config.lspconfig"

local lsp_status, _ = pcall(require, "lspconfig")
if not lsp_status then
    log.error(logger_name, "'lspconfig' not found. LSP will not be configured.")
    return
end

log.debug(logger_name, "Configuring LSP")

do
    local orig = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "single"
        return orig(contents, syntax, opts, ...)
    end
end

local icons_status, icons = pcall(require, "io.github.israiloff.config.icons")
if not icons_status then
    log.error(logger_name, "'io.github.israiloff.config.icons' not found. Default icons for diagnostics will be used.")
    return
end

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.Warning,
            [vim.diagnostic.severity.INFO] = icons.diagnostics.Information,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
        },
    },
})
