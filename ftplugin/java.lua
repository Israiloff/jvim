local logger_status, logger = pcall(require, "io.github.israiloff.config.logger")
if not logger_status then
	print("JAVA: io.github.israiloff.config.logger not found, please install it and try again")
	return
end

local file_name = vim.fn.expand("<sfile>:p")

logger.debug(file_name, "JAVA: starting configuration forming...")

local mason_status, _ = pcall(require, "mason")
if not mason_status then
	logger.debug(file_name, "JAVA: mason not found, please install it and try again")
	return
end

local jdtls_status, jdtls = pcall(require, "jdtls")

logger.debug(file_name, "JAVA: jdtls status: " .. tostring(jdtls_status))

if not jdtls_status then
	logger.debug(file_name, "JAVA: jdtls not found, please install it and try again")
	return
end

local utils_status, utils = pcall(require, "io.github.israiloff.config.utils")
if not utils_status then
	logger.debug(file_name, "JAVA: io.github.israiloff.config.utils not found, please install it and try again")
	return
end

local registry_status, mason_registry = pcall(require, "mason-registry")

if not registry_status then
	logger.debug(file_name, "JAVA: mason.registry not found, please install it and try again")
	return
end

local share_dir = os.getenv("HOME") .. "/.local/share"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = share_dir .. "/nvim/java/" .. project_name

utils.create_dirs(workspace_dir)

logger.debug(file_name, "JAVA: forming bundles...")

local bundles = {
	vim.fn.glob(
		mason_registry.get_package("java-debug-adapter"):get_install_path()
			.. "/extension/server/com.microsoft.java.debug.plugin-*.jar"
	),
}

logger.debug(file_name, "JAVA: bundles formed: " .. table.concat(bundles, ", "))

vim.list_extend(
	bundles,
	vim.split(
		vim.fn.glob(mason_registry.get_package("java-test"):get_install_path() .. "/extension/server/*.jar"),
		"\n"
	)
)

local jdtls_path = mason_registry.get_package("jdtls"):get_install_path()

logger.debug(file_name, "JAVA: jdtls path: " .. jdtls_path)

local lombok = require("io.github.israiloff.config.java.lombok")
lombok.setup()

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

	on_attach = function(client)
		if client.name == "jdtls" then
			local which_key_status, which_key = pcall(require, "which-key")
			if which_key_status then
				local icons = require("io.github.israiloff.config.icons")
				which_key.register({
					j = {
						name = icons.ui.Java .. " Java",
						o = { "<Cmd>lua require('jdtls').organize_imports()<CR>", "Organize Imports" },
						v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
						c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
						t = { "<Cmd>lua require('jdtls').test_nearest_method()<CR>", "Test Method" },
						T = { "<Cmd>lua require('jdtls').test_class()<CR>", "Test Class" },
						u = { "<Cmd>lua require('jdtls').update_project_config()<CR>", "Update Config" },
					},
				}, {
					prefix = "<leader>",
					mode = "n",
				})
				which_key.register({
					j = {
						name = icons.ui.Java .. " Java",
						v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
						c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
						m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
					},
				}, {
					prefix = "<leader>",
					mode = "v",
				})
			end
			jdtls = require("jdtls")
			jdtls.setup_dap({ hotcodereplace = "auto" })
			require("jdtls.dap").setup_dap_main_class_configs({
				config_overrides = {
					vmArgs = "-Dspring.profiles.active=local",
				},
			})
		end
	end,
	settings = {
		java = {
			signatureHelp = {
				enabled = true,
			},
			saveActions = {
				organizeImports = true,
			},
			completion = {
				maxResults = 20,
				favoriteStaticMembers = {
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.hamcrest.CoreMatchers.*",
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
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
		},
	},
}

logger.debug(file_name, "JAVA: configuration formed")

jdtls.start_or_attach(config)

logger.debug(file_name, "JAVA: configuration applied")
