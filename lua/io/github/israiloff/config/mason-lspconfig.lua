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

log.info(logger_name, "Setting up Mason LSPConfig")

mason_lspconfig.setup({
    ensure_installed = {
        "lua_ls",
        "jdtls",
        "marksman",
        "jsonls",
    },
    automatic_installation = false,
})

local utils_status, utils = pcall(require, "io.github.israiloff.config.lsp-utils")

if not utils_status then
    log.error(
        logger_name,
        "'io.github.israiloff.config.lsp-utils' not found. Filetype auto resolve will not be configured."
    )
    return
end

local lspconfig_status, lspconfig = pcall(require, "lspconfig")

if not lspconfig_status then
    log.error(logger_name, "'lspconfig' not found. LSP auto installation will not be configured.")
    return
end

local cmp_status, cmp = pcall(require, "cmp_nvim_lsp")

if not cmp_status then
    log.error(logger_name, "'cmp_nvim_lsp' not found. LSP auto installation will not be configured.")
    return
end

local c_utils_status, c_utils = pcall(require, "io.github.israiloff.config.utils")

if not c_utils_status then
    log.error(
        logger_name,
        "'io.github.israiloff.config.utils' not found. Filetype auto resolve will not be configured."
    )
    return
end

local ignored_servers = {
    "jdtls",
    "marksman",
    "lemminx",
}

local ignored_filetypes = {
    "TelescopePrompt",
    "packer",
    "toggleterm",
    "lua",
    "json",
    "java",
    "xml",
    "markdown",
}

mason_lspconfig.setup_handlers({
    function(server_name)
        if vim.tbl_contains(ignored_servers, server_name) then
            log.debug(logger_name, "Ignoring server '" .. server_name .. "'")
            return
        end

        lspconfig[server_name].setup({
            on_attach = function(client, bufnr)
                vim.notify("LSP: " .. server_name .. " attached", vim.log.levels.INFO)
                utils.global_on_attach(client, bufnr)
            end,
            capabilities = cmp.default_capabilities(),
            flags = { debounce_text_changes = 200 },
            root_dir = utils.get_root_dir(),
        })
    end,
})

vim.list_extend(ignored_filetypes, c_utils.get_ftplugin_filetypes())

log.info(logger_name, "Setting up Mason LSPConfig filetype auto resolve")

vim.api.nvim_create_augroup("LSPAutoInstall", {
    clear = false,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = "LSPAutoInstall",
    callback = function()
        local filetype = vim.bo.filetype

        if c_utils.isempty(filetype) or vim.tbl_contains(ignored_filetypes, filetype) then
            log.warn(logger_name, "Ignoring filetype '" .. filetype .. "'")
            return
        end

        local availables = utils.get_available_servers({ filetype = filetype })

        log.info(logger_name, "Available servers for '" .. filetype .. "' : " .. vim.inspect(availables))

        if #availables == 0 or availables == nil then
            vim.notify("No available servers for [" .. filetype .. "]", vim.log.levels.WARN)
            log.warn(logger_name, "No available servers for " .. filetype)
            return
        end

        if utils.already_installed_all(availables) then
            log.info(logger_name, "Server for '" .. filetype .. "' already installed")
            return
        end

        local primary_server = filetype .. "-language-server"

        if utils.already_installed_single(primary_server) then
            log.info(logger_name, "Server for '" .. filetype .. "' already installed")
            return
        end

        if utils.install_package(primary_server) then
            log.info(logger_name, "Server for '" .. filetype .. "' installed successfully")
            return
        end

        for _, server in ipairs(availables) do
            log.info(logger_name, "Server: " .. vim.inspect(server))
            if utils.install_package(server) then
                log.info(logger_name, "Server for '" .. filetype .. "' installed successfully")
                break
            end
        end
    end,
})
