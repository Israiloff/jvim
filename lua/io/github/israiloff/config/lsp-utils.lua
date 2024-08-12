local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
    print("Error: 'io.github.israiloff.config.logger' not found. LSP will not be configured.")
    return
end

local logger_name = "io.github.israiloff.config.lsp-utils"

Utils = {}

local reg_status, registry = pcall(require, "mason-registry")
local ml_status, mason_lspconfig = pcall(require, "mason-lspconfig")

function Utils.install_package(package_name)
    log.info(logger_name, "install_package started for package '" .. package_name .. "'.")

    if not reg_status then
        log.error(logger_name, "'mason-registry' not found. Aborting install_package.")
        return false
    end

    if not registry.has_package(package_name) then
        vim.notify("Package [" .. package_name .. "] is not available in the Mason registry.", vim.log.levels.ERROR)
        return false
    end

    local pkg = registry.get_package(package_name)

    if pkg.is_installed(pkg) then
        vim.notify("Package [" .. package_name .. "] is already installed.", vim.log.levels.INFO)
        return true
    end

    vim.notify("Installing package [" .. package_name .. "]...", vim.log.levels.INFO)

    local install_status, _ = pcall(function()
        pkg.install(pkg)
    end)

    return install_status
end

function Utils.get_available_servers(filter)
    if not reg_status then
        log.error(logger_name, "'mason-registry' not found. Aborting get_supported_servers.")
        return
    end

    if not ml_status then
        log.error(logger_name, "'mason-lspconfig' not found. Aborting get_supported_servers.")
        return
    end

    registry.refresh()

    local ss_status, supported_servers = pcall(function()
        return mason_lspconfig.get_available_servers(filter)
    end)

    if not ss_status or not supported_servers then
        log.error(logger_name, "Error getting supported servers.")
        return {}
    end

    return supported_servers
end

function Utils.already_installed_all(available)
    if not reg_status then
        log.error(logger_name, "'mason-registry' not found. Aborting already_installed.")
        return false
    end

    for _, server in ipairs(available) do
        if registry.is_installed(server) then
            return true
        end
    end
    return false
end

local lspconfig_status, lspconfig = pcall(require, "lspconfig")

function Utils.get_installed_servers_names()
    if not lspconfig_status then
        log.error(logger_name, "'lspconfig' not found. Aborting get_all_available_servers.")
        return {}
    end

    return lspconfig.util.available_servers()
end

function Utils.already_installed_single(server_name)
    if not reg_status then
        log.error(logger_name, "'mason-registry' not found. Aborting already_installed_single.")
        return false
    end

    return registry.is_installed(server_name)
end

local function setup_codelens_refresh(client, bufnr)
    local status_ok, codelens_supported = pcall(function()
        return client.supports_method("textDocument/codeLens")
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
        return client.supports_method("textDocument/documentSymbol")
    end)

    if not status or not ds_supported then
        return
    end

    navic.attach(client, bufnr)
end

function Utils.global_on_attach(client, bufnr)
    setup_codelens_refresh(client, bufnr)
    setup_navic(client, bufnr)
end

function Utils.get_root_dir()
    return lspconfig.util.root_pattern(
        ".git",
        ".marksman.toml",
        "package.json",
        "pom.xml",
        ".settings",
        "biome.json",
        "biome.jsonc",
        ".marksman.toml",
        ".settings"
    )
end

return Utils
