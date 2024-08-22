local logger_status, logger = pcall(require, "io.github.israiloff.config.logger")
if not logger_status then
    print("JAVA: io.github.israiloff.config.logger not found, please install it and try again")
    return
end

local logger_name = "ftplugin.java"

logger.debug(logger_name, "JAVA: starting configuration forming...")

local mason_status, _ = pcall(require, "mason")
if not mason_status then
    logger.debug(logger_name, "JAVA: mason not found, please install it and try again")
    return
end

local jdtls_status, jdtls = pcall(require, "jdtls")

logger.debug(logger_name, "JAVA: jdtls status: " .. tostring(jdtls_status))

if not jdtls_status then
    logger.debug(logger_name, "JAVA: jdtls not found, please install it and try again")
    return
end

local utils_status, utils = pcall(require, "io.github.israiloff.config.utils")
if not utils_status then
    logger.debug(logger_name, "JAVA: io.github.israiloff.config.utils not found, please install it and try again")
    return
end

local registry_status, mason_registry = pcall(require, "mason-registry")

if not registry_status then
    logger.debug(logger_name, "JAVA: mason.registry not found, please install it and try again")
    return
end

local home = os.getenv("HOME")
local share_dir = home .. "/.local/share"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = share_dir .. "/nvim/java/" .. project_name

utils.create_dirs(workspace_dir)

logger.debug(logger_name, "JAVA: forming bundles...")

local bundles = {
    vim.fn.glob(
        mason_registry.get_package("java-debug-adapter"):get_install_path()
        .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"
    ),
}

logger.debug(logger_name, "JAVA: bundles formed: " .. table.concat(bundles, ", "))

vim.list_extend(
    bundles,
    vim.split(
        vim.fn.glob(mason_registry.get_package("java-test"):get_install_path() .. "/extension/server/*.jar"),
        "\n"
    )
)

local jdtls_path = mason_registry.get_package("jdtls"):get_install_path()

logger.debug(logger_name, "JAVA: jdtls path: " .. jdtls_path)

local lombok = require("io.github.israiloff.config.java.lombok")
lombok.setup()

local java_format_file_path = "file://" .. home .. "/.config/nvim/lua/io/github/israiloff/config/java/java-style.xml"

logger.debug(logger_name, "JAVA: formatter file path: " .. java_format_file_path)

local lsp_utils_status, lsp_utils = pcall(require, "io.github.israiloff.config.lsp-utils")

if not lsp_utils_status then
    logger.debug(logger_name, "JAVA: io.github.israiloff.config.lsp-utils not found, please install it and try again")
    return
end

local config = {
    cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-javaagent:" .. lombok.lombok_path,
        "-Xms512m",
        "-Xmx2048m",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-jar",
        vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
        "-configuration",
        jdtls_path .. "/config_linux",
        "-data",
        workspace_dir,
    },
    flags = {
        debounce_text_changes = 150,
        allow_incremental_sync = true,
    },
    root_dir = jdtls.setup.find_root({ ".metadata", ".git", "pom.xml" }),

    on_init = function(client)
        if client.config.settings then
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
    end,

    init_options = {
        bundles = bundles,
    },
    capabilities = jdtls.extendedClientCapabilities,

    on_attach = function(client, bufnr)
        lsp_utils.global_on_attach(client, bufnr)
        require("io.github.israiloff.config.java.keymap")
        jdtls.setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs({
            config_overrides = {
                vmArgs = "-Dspring.profiles.active=local",
            },
        })
        client.server_capabilities.semanticTokensProvider = nil
    end,
    settings = {
        java = {
            signatureHelp = {
                enabled = true,
            },
            saveActions = {
                organizeImports = false,
            },
            completion = {
                maxResults = 20,
                favoriteStaticMembers = {
                    "org.junit.jupiter.api.Assertions.*",
                    "org.mockito.Mockito.*",
                },
            },
            sources = {
                organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                },
            },
            codeGeneration = {
                toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
            },
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            inlayHints = {
                parameterNames = {
                    enabled = "all", -- literals, all, none
                },
            },
            format = {
                enabled = true,
                settings = {
                    profile = "GoogleStyle",
                    url = java_format_file_path,
                },
            },
        },
    },
}

logger.debug(logger_name, "JAVA: configuration formed")

jdtls.start_or_attach(config)

logger.debug(logger_name, "JAVA: configuration applied")
