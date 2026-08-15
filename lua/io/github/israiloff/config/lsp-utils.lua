local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
    print("Error: 'io.github.israiloff.config.logger' not found. LSP will not be configured.")
    return
end

local logger_name = "io.github.israiloff.config.lsp-utils"

local workspace_utils_status, workspace_utils = pcall(require, "io.github.israiloff.config.workspace-utils")

if not workspace_utils_status then
    log.error(logger_name, "'workspace-utils' not found. LSP will not be configured.")
    return
end

local M = {}

local function setup_codelens_refresh(client, bufnr)
    local status_ok, codelens_supported = pcall(function()
        return client:supports_method("textDocument/codeLens")
    end)
    if not status_ok or not codelens_supported then
        return
    end
    local group = "LSPCmOnAttach"
    local cl_events = { "BufEnter", "InsertLeave" }
    local ok, cl_autocmds = pcall(vim.api.nvim_get_autocmds, {
        group = group,
        buffer = bufnr,
        event = cl_events,
    })
    if ok and #cl_autocmds > 0 then
        return
    end
    local cb = function()
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_is_valid(bufnr) then
            vim.lsp.codelens.refresh({ bufnr = bufnr })
        end
    end
    vim.api.nvim_create_augroup(group, { clear = false })
    vim.api.nvim_create_autocmd(cl_events, {
        group = group,
        buffer = bufnr,
        callback = cb,
    })
    vim.lsp.codelens.refresh({ bufnr = bufnr })
end

local function setup_navic(client, bufnr)
    local navic_status, navic = pcall(require, "io.github.israiloff.config.nvim-navic")

    if not navic_status then
        return
    end

    local status, ds_supported = pcall(function()
        return client:supports_method("textDocument/documentSymbol")
    end)

    if not status or not ds_supported then
        return
    end

    navic.attach(client, bufnr)
end

function M.global_on_attach(client, bufnr)
    setup_codelens_refresh(client, bufnr)
    setup_navic(client, bufnr)
end

function M.get_root_dir()
    return workspace_utils.find_java_root()
end

return M
