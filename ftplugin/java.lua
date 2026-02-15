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

local registry_status, _ = pcall(require, "mason-registry")
if not registry_status then
	logger.debug(logger_name, "JAVA: mason-registry not found, please install it and try again")
	return
end

local workspace_utils_status, workspace_utils = pcall(require, "io.github.israiloff.config.workspace-utils")
if not workspace_utils_status then
	logger.debug(
		logger_name,
		"JAVA: io.github.israiloff.config.workspace-utils not found, please install it and try again"
	)
	return
end

local lsp_utils_status, lsp_utils = pcall(require, "io.github.israiloff.config.lsp-utils")
if not lsp_utils_status then
	logger.debug(logger_name, "JAVA: io.github.israiloff.config.lsp-utils not found, please install it and try again")
	return
end

-- ---------------------------------------------------------------------------
-- Root + Workspace (single source of truth)
-- ---------------------------------------------------------------------------
local config_dir = vim.fn.stdpath("config")
local data_dir = vim.fn.stdpath("data")

local root_dir = workspace_utils.find_java_root()
local project_id = workspace_utils.workspace_name_from_path(root_dir)
local workspace_dir = data_dir .. "/workspace/java/" .. project_id
utils.create_dirs(workspace_dir)

logger.info(logger_name, "JAVA: root_dir      : " .. root_dir)
logger.info(logger_name, "JAVA: workspace_dir : " .. workspace_dir)

-- ---------------------------------------------------------------------------
-- Bundles (debug + test)
-- ---------------------------------------------------------------------------
local uv = vim.uv or vim.loop

local function add_bundle(t, p)
	if p and p ~= "" and uv.fs_stat(p) then
		table.insert(t, p)
	end
end

logger.info(logger_name, "JAVA: forming bundles...")
local bundles = {}

add_bundle(
	bundles,
	vim.fn.glob(
		vim.fn.expand("$MASON/packages/java-debug-adapter/extension/server") .. "/com.microsoft.java.debug.plugin-*.jar"
	)
)

for _, jar in
	ipairs(vim.split(vim.fn.glob(vim.fn.expand("$MASON/packages/java-test/extension/server") .. "/*.jar"), "\n"))
do
	add_bundle(bundles, jar)
end

logger.info(logger_name, "JAVA: bundles count: " .. tostring(#bundles))

-- ---------------------------------------------------------------------------
-- JDTLS paths
-- ---------------------------------------------------------------------------
local jdtls_path = vim.fn.expand("$MASON/packages/jdtls")
logger.debug(logger_name, "JAVA: jdtls path: " .. jdtls_path)

-- pick launcher jar (stable)
local launcher_jars = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar", false, true)
table.sort(launcher_jars) -- last is usually newest by version in filename
local launcher_jar = launcher_jars[#launcher_jars]

if not launcher_jar or launcher_jar == "" then
	logger.error(logger_name, "JAVA: equinox launcher jar not found under: " .. jdtls_path .. "/plugins")
	return
end

-- OS config directory (NO arch suffix)
local os_name = require("io.github.israiloff.config.os").get_current_os()
local config_path = jdtls_path .. "/config_" .. os_name
if not uv.fs_stat(config_path) then
	logger.error(logger_name, "JAVA: JDTLS config dir not found: " .. config_path)
	logger.error(
		logger_name,
		"JAVA: available config dirs: " .. table.concat(vim.fn.glob(jdtls_path .. "/config_*", false, true), ", ")
	)
	return
end

-- Java binary
local java_bin = utils.get_java_path() or "java"
logger.info(logger_name, "JAVA: java bin: " .. tostring(java_bin))

-- Lombok
local lombok = require("io.github.israiloff.config.java.lombok")
local lombok_ok, lombok_path = lombok.setup()

-- Formatter
local java_format_file_path = "file://" .. config_dir .. "/lua/io/github/israiloff/config/java/java-style.xml"
logger.debug(logger_name, "JAVA: formatter file path: " .. java_format_file_path)

-- ---------------------------------------------------------------------------
-- Config
-- ---------------------------------------------------------------------------
local cmd = {
	java_bin,
	"-Declipse.application=org.eclipse.jdt.ls.core.id1",
	"-Dosgi.bundles.defaultStartLevel=4",
	"-Declipse.product=org.eclipse.jdt.ls.core.product",
	"-Dlog.protocol=true",
	"-Dlog.level=ALL",
	"-Xms512m",
	"-Xmx2048m",
	"--add-modules=ALL-SYSTEM",
	"--add-opens",
	"java.base/java.util=ALL-UNNAMED",
	"--add-opens",
	"java.base/java.lang=ALL-UNNAMED",
}

if lombok_ok and lombok_path and lombok_path ~= "" then
	table.insert(cmd, "-javaagent:" .. lombok_path)
end

vim.list_extend(cmd, {
	"-jar",
	launcher_jar,
	"-configuration",
	config_path,
	"-data",
	workspace_dir,
})

local config = {
	cmd = cmd,
	root_dir = root_dir,

	flags = {
		debounce_text_changes = 150,
	},

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

		-- keymaps (includes test + debug + remote attach preset below)
		require("io.github.israiloff.config.java.keymap")

		-- DAP
		jdtls.setup_dap({
			hotcodereplace = "auto",
			config_overrides = { vmArgs = "-Dspring.profiles.active=local" },
		})
		require("jdtls.dap").setup_dap_main_class_configs({
			config_overrides = { vmArgs = "-Dspring.profiles.active=local" },
		})

		-- Remote attach preset (Docker/K8s): port-forward/ssh -L 5005:localhost:5005 then attach
		local ok_dap, dap = pcall(require, "dap")
		if ok_dap then
			dap.configurations.java = dap.configurations.java or {}
			table.insert(dap.configurations.java, 1, {
				type = "java",
				request = "attach",
				name = "Attach to remote JVM :5005",
				hostName = "127.0.0.1",
				port = 5005,
			})
		end

		-- if semantic tokens cause lag/conflicts, disable (optionally put behind a flag)
		client.server_capabilities.semanticTokensProvider = nil
	end,

	settings = {
		java = {
			signatureHelp = { enabled = true },
			saveActions = { organizeImports = false },

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

			format = {
				enabled = true,
				settings = {
					url = java_format_file_path,
				},
			},

			eclipse = { downloadSources = true },
			maven = { downloadSources = true },

			configuration = {
				updateBuildConfiguration = "interactive",
			},

			implementationsCodeLens = { enabled = true },
			referencesCodeLens = { enabled = true },
			references = { includeDecompiledSources = true },

			inlayHints = {
				parameterNames = { enabled = "all" },
			},

			trace = { server = "verbose" },
		},
	},
}

logger.debug(logger_name, "JAVA: configuration formed")
jdtls.start_or_attach(config)
logger.debug(logger_name, "JAVA: configuration applied")
