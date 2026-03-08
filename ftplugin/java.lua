local logger_status, logger = pcall(require, "io.github.israiloff.config.logger")
if not logger_status then
	print("JAVA: io.github.israiloff.config.logger not found, please install it and try again")
	return
end

local logger_name = "ftplugin.java"
logger.debug(logger_name, "JAVA: starting configuration forming...")

local function safe_require(module_name, error_message)
	local ok, mod = pcall(require, module_name)
	if not ok then
		logger.debug(logger_name, error_message)
		return nil
	end
	return mod
end

local jdtls = safe_require("jdtls", "JAVA: jdtls not found, please install it and try again")
if not jdtls then
	return
end

if not safe_require("mason", "JAVA: mason not found, please install it and try again") then
	return
end

if not safe_require("mason-registry", "JAVA: mason-registry not found, please install it and try again") then
	return
end

local utils = safe_require(
	"io.github.israiloff.config.utils",
	"JAVA: io.github.israiloff.config.utils not found, please install it and try again"
)
if not utils then
	return
end

local workspace_utils = safe_require(
	"io.github.israiloff.config.workspace-utils",
	"JAVA: io.github.israiloff.config.workspace-utils not found, please install it and try again"
)
if not workspace_utils then
	return
end

local lsp_utils = safe_require(
	"io.github.israiloff.config.lsp-utils",
	"JAVA: io.github.israiloff.config.lsp-utils not found, please install it and try again"
)
if not lsp_utils then
	return
end

local os_mod = safe_require(
	"io.github.israiloff.config.os",
	"JAVA: io.github.israiloff.config.os not found, please install it and try again"
)
if not os_mod then
	return
end

local arch = safe_require(
	"io.github.israiloff.config.arch",
	"JAVA: io.github.israiloff.config.arch not found, please install it and try again"
)
if not arch then
	return
end

local lombok = safe_require(
	"io.github.israiloff.config.java.lombok",
	"JAVA: lombok module not found, please install it and try again"
)
if not lombok then
	return
end

local properties = safe_require(
	"io.github.israiloff.config.properties",
	"JAVA: io.github.israiloff.config.properties not found, please install it and try again"
)

local jdtls_jvm_config = properties and properties.jdtls and properties.jdtls.jvm or { xms = "256M", xmx = "1G" }

local uv = vim.uv or vim.loop
local config_dir = vim.fn.stdpath("config")
local data_dir = vim.fn.stdpath("data")

-- ---------------------------------------------------------------------------
-- Root + Workspace
-- ---------------------------------------------------------------------------
local root_dir = workspace_utils.find_java_root()
if not root_dir or root_dir == "" then
	logger.debug(logger_name, "JAVA: root_dir not found, skip jdtls start")
	return
end

local project_id = workspace_utils.workspace_name_from_path(root_dir)
if not project_id or project_id == "" then
	project_id = tostring(vim.fn.sha256(root_dir)):sub(1, 12)
end

local workspace_dir = data_dir .. "/workspace/java/" .. project_id
utils.create_dirs(workspace_dir)

logger.info(logger_name, "JAVA: root_dir      : " .. root_dir)
logger.info(logger_name, "JAVA: workspace_dir : " .. workspace_dir)

-- ---------------------------------------------------------------------------
-- Cache
-- ---------------------------------------------------------------------------
vim.g.jdtls_cache = vim.g.jdtls_cache or {}
local cache = vim.g.jdtls_cache

local function path_exists(path)
	return path and path ~= "" and uv.fs_stat(path) ~= nil
end

local function glob_first(pattern)
	local matches = vim.fn.glob(pattern, false, true)
	if type(matches) == "table" and #matches > 0 then
		return matches[1]
	end
	return nil
end

local function add_unique(tbl, seen, value)
	if path_exists(value) and not seen[value] then
		seen[value] = true
		table.insert(tbl, value)
	end
end

-- ---------------------------------------------------------------------------
-- Bundles
-- ---------------------------------------------------------------------------
local function get_bundles()
	if cache.bundles then
		return cache.bundles
	end

	logger.info(logger_name, "JAVA: forming bundles...")

	local bundles = {}
	local seen = {}

	local debug_jar = glob_first(
		vim.fn.expand("$MASON/packages/java-debug-adapter/extension/server") .. "/com.microsoft.java.debug.plugin-*.jar"
	)
	add_unique(bundles, seen, debug_jar)

	local test_jars = vim.fn.glob(vim.fn.expand("$MASON/packages/java-test/extension/server") .. "/*.jar", false, true)

	for _, jar in ipairs(test_jars) do
		add_unique(bundles, seen, jar)
	end

	cache.bundles = bundles
	logger.info(logger_name, "JAVA: bundles count: " .. tostring(#bundles))
	return bundles
end

-- ---------------------------------------------------------------------------
-- JDTLS paths
-- ---------------------------------------------------------------------------
local function resolve_jdtls_paths()
	if cache.paths then
		return cache.paths
	end

	local jdtls_path = vim.fn.expand("$MASON/packages/jdtls")
	logger.debug(logger_name, "JAVA: jdtls path: " .. jdtls_path)

	local launcher_jars = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar", false, true)
	table.sort(launcher_jars)
	local launcher_jar = launcher_jars[#launcher_jars]

	if not launcher_jar or launcher_jar == "" then
		logger.error(logger_name, "JAVA: equinox launcher jar not found under: " .. jdtls_path .. "/plugins")
		return nil
	end

	local os_name = os_mod.get_current_os()
	local config_name = "config_" .. os_name

	if arch.get_architecture() == arch.ARM then
		config_name = config_name .. "_" .. arch.ARM
	end

	local config_path = jdtls_path .. "/" .. config_name

	if not path_exists(config_path) then
		logger.error(logger_name, "JAVA: JDTLS config dir not found: " .. config_path)
		logger.error(
			logger_name,
			"JAVA: available config dirs: " .. table.concat(vim.fn.glob(jdtls_path .. "/config_*", false, true), ", ")
		)
		return nil
	end

	cache.paths = {
		jdtls_path = jdtls_path,
		launcher_jar = launcher_jar,
		config_path = config_path,
	}
	return cache.paths
end

local paths = resolve_jdtls_paths()
if not paths then
	return
end

-- ---------------------------------------------------------------------------
-- Runtime / Formatter
-- ---------------------------------------------------------------------------
local java_bin = utils.get_java_path() or "java"
logger.info(logger_name, "JAVA: java bin: " .. tostring(java_bin))

local lombok_ok, lombok_path = lombok.setup()

local java_format_file_path = "file://" .. config_dir .. "/lua/io/github/israiloff/config/java/java-style.xml"
logger.debug(logger_name, "JAVA: formatter file path: " .. java_format_file_path)

-- ---------------------------------------------------------------------------
-- One-time helpers
-- ---------------------------------------------------------------------------
local function ensure_java_remote_attach_config()
	local ok_dap, dap = pcall(require, "dap")
	if not ok_dap then
		return
	end

	dap.configurations.java = dap.configurations.java or {}

	for _, cfg in ipairs(dap.configurations.java) do
		if cfg.name == "Attach to remote JVM :5005" then
			return
		end
	end

	table.insert(dap.configurations.java, 1, {
		type = "java",
		request = "attach",
		name = "Attach to remote JVM :5005",
		hostName = "127.0.0.1",
		port = 5005,
	})
end

local function setup_dap_once()
	if cache.dap_initialized then
		return
	end

	jdtls.setup_dap({
		hotcodereplace = "auto",
		config_overrides = {
			vmArgs = "-Dspring.profiles.active=local",
		},
	})

	require("jdtls.dap").setup_dap_main_class_configs({
		config_overrides = {
			vmArgs = "-Dspring.profiles.active=local",
		},
	})

	ensure_java_remote_attach_config()
	cache.dap_initialized = true
end

local function setup_keymaps_once()
	if cache.keymaps_initialized then
		return
	end

	require("io.github.israiloff.config.java.keymap")
	cache.keymaps_initialized = true
end

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------
local cmd = {
	java_bin,
	"-Declipse.application=org.eclipse.jdt.ls.core.id1",
	"-Dosgi.bundles.defaultStartLevel=4",
	"-Declipse.product=org.eclipse.jdt.ls.core.product",
	"-Dlog.protocol=false",
	"-Dlog.level=ERROR",
	"-Xms" .. jdtls_jvm_config.xms,
	"-Xmx" .. jdtls_jvm_config.xmx,
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
	paths.launcher_jar,
	"-configuration",
	paths.config_path,
	"-data",
	workspace_dir,
})

-- ---------------------------------------------------------------------------
-- Config
-- ---------------------------------------------------------------------------
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
		bundles = get_bundles(),
	},

	capabilities = jdtls.extendedClientCapabilities,

	on_attach = function(client, bufnr)
		lsp_utils.global_on_attach(client, bufnr)
		setup_keymaps_once()
		setup_dap_once()
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

			trace = { server = "off" },
		},
	},
}

logger.debug(logger_name, "JAVA: configuration formed")
jdtls.start_or_attach(config)
logger.debug(logger_name, "JAVA: configuration applied")
