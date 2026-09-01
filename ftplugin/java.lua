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

local ai = safe_require(
	"io.github.israiloff.config.ai",
	"JAVA: io.github.israiloff.config.ai not found, please install it and try again"
)

local jdtls_jvm_config = properties and properties.jdtls and properties.jdtls.jvm or { xms = "256M", xmx = "1G" }

-- LSP client capabilities advertised to jdtls.
--
-- These must be *protocol* capabilities. `jdtls.extendedClientCapabilities` is a
-- jdtls-specific extension table and belongs in `init_options`, not here; putting
-- it in `capabilities` used to silently drop nvim-cmp's completion capabilities
-- (snippetSupport, resolveSupport, labelDetails, ...).
--
-- Neovim force-merges this on top of `vim.lsp.protocol.make_client_capabilities()`,
-- so returning only the cmp overrides is enough.
local cmp_nvim_lsp = safe_require(
	"cmp_nvim_lsp",
	"JAVA: cmp_nvim_lsp not found, falling back to default LSP client capabilities"
)

local capabilities = cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities()
	or vim.lsp.protocol.make_client_capabilities()

local extended_client_capabilities = jdtls.extendedClientCapabilities
extended_client_capabilities.resolveAdditionalTextEditsSupport = true

local copilot_utils = nil
if ai and ai.is(ai.providers.COPILOT) then
	copilot_utils = safe_require(
		"io.github.israiloff.config.copilot-utils",
		"JAVA: io.github.israiloff.config.copilot-utils not found, please install it if you use Copilot and want to ensure workspace folder is registered"
	)
end

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

-- ----------------------------------------------------------------------------
-- Copilot setup
-- ----------------------------------------------------------------------------
if copilot_utils then
	logger.debug(logger_name, "Ensuring Copilot workspace folder is set for: " .. root_dir)
	copilot_utils.ensure_copilot_workspace_folder(root_dir)
end

-- ---------------------------------------------------------------------------
-- Cache
-- ---------------------------------------------------------------------------
local cache = safe_require(
	"io.github.israiloff.config.java.cache",
	"JAVA: io.github.israiloff.config.java.cache not found, please install it and try again"
)
if not cache then
	return
end

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

---The jars among `paths` that Equinox can actually load.
---
---Everything JDTLS is handed as a bundle has to declare itself one, and the
---java-test package ships two jars that do not: `jacocoagent.jar` is a Java
---agent attached to the JVM a test runs in, and the test runner goes on that
---JVM's classpath. Neither belongs in the language server's framework, and
---JDTLS logs an error for each of them on every single start.
---
---Only the manifest says which jar is which, so the manifests are read. The
---reads are started together and collected afterwards because one process per
---jar in sequence costs seven times as much for the same answer.
---
---A jar whose manifest cannot be read at all is kept: dropping a real bundle
---costs a feature, keeping a plain jar costs the log line this exists to
---remove.
---@param paths string[]
---@return string[]
local function osgi_bundles(paths)
	if vim.fn.executable("unzip") ~= 1 then
		logger.debug(logger_name, "JAVA: unzip not found, every jar is passed to jdtls as-is")
		return paths
	end

	local readers = {}
	for _, path in ipairs(paths) do
		readers[path] = vim.system({ "unzip", "-p", path, "META-INF/MANIFEST.MF" }, { text = true })
	end

	local bundles = {}

	for _, path in ipairs(paths) do
		local read_ok, result = pcall(function()
			return readers[path]:wait(5000)
		end)

		-- A jar with no manifest at all exits non-zero and still hands back an
		-- empty string, so the exit code is what separates "not a bundle" from
		-- "could not tell".
		local manifest = (read_ok and result.code == 0) and result.stdout or nil

		-- A header only ever starts a line; a continuation line starts with a
		-- space, so the name itself is never split across one.
		if not manifest then
			logger.debug(logger_name, "JAVA: manifest unreadable, kept anyway: " .. path)
			table.insert(bundles, path)
		elseif manifest:find("^Bundle%-SymbolicName:") or manifest:find("\nBundle%-SymbolicName:") then
			table.insert(bundles, path)
		else
			logger.debug(logger_name, "JAVA: not an OSGi bundle, left out: " .. path)
		end
	end

	return bundles
end

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

	-- Spring Boot LS reads the type model out of jdtls through these extension
	-- jars; without them it can parse a repository interface but cannot resolve
	-- the entity's fields. Returns an empty list when the feature is off.
	local spring = safe_require("io.github.israiloff.config.java.spring", "JAVA: spring module not found")
	if spring then
		for _, jar in ipairs(spring.java_extensions()) do
			add_unique(bundles, seen, jar)
		end
	end

	cache.bundles = osgi_bundles(bundles)
	logger.info(logger_name, "JAVA: bundles count: " .. tostring(#cache.bundles))
	return cache.bundles
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

---The Java menus for `bufnr`.
---
---The shared entries are registered the first time the module is required and
---`require` caches, so they land once. The build-tool menu is per buffer: which
---of Maven and Gradle applies is a property of the project the file belongs to,
---and both kinds are routinely open in the same session.
local function setup_keymaps(bufnr)
	local keymap = safe_require("io.github.israiloff.config.java.keymap", "JAVA: java keymap module not found")

	-- The module returns nothing when it gives up on a missing dependency, and
	-- `require` turns that into `true`.
	if type(keymap) == "table" and keymap.setup_buffer then
		keymap.setup_buffer(bufnr)
	end
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
		extendedClientCapabilities = extended_client_capabilities,
	},

	capabilities = capabilities,

	on_attach = function(client, bufnr)
		lsp_utils.global_on_attach(client, bufnr)
		setup_keymaps(bufnr)
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

			-- Gradle is imported the way the project describes itself.
			--
			-- `wrapper.enabled` makes JDTLS honour `gradle/wrapper/*.properties`
			-- and build the model with the Gradle version the project pins,
			-- instead of whatever version JDTLS happens to bundle — the same
			-- version the build runner uses when it calls `./gradlew`, so the
			-- editor and the terminal cannot disagree about the project.
			--
			-- `annotationProcessing` is what makes Lombok work in a Gradle
			-- project: the generated getters exist only after the processors
			-- have run, and without this JDTLS reports every one of them as an
			-- unresolved symbol.
			import = {
				gradle = {
					enabled = true,
					wrapper = { enabled = true },
					annotationProcessing = { enabled = true },
				},
				maven = { enabled = true },
			},

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
